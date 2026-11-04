
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function jsonResponse(
  data: Record<string, unknown>,
  status = 200,
) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed." }, 405);
  }

  try {
    // 1. Read environment variables
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const supabaseServiceKey =
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const razorpayKeyId = Deno.env.get("RAZORPAY_KEY_ID");
    const razorpayKeySecret = Deno.env.get("RAZORPAY_KEY_SECRET");

    if (!razorpayKeyId || !razorpayKeySecret) {
      throw new Error("Razorpay credentials are not configured.");
    }

    // 2. Verify the authenticated user
    const authorization = req.headers.get("Authorization");

    if (!authorization?.startsWith("Bearer ")) {
      return jsonResponse({ error: "Authentication required." }, 401);
    }

    const supabaseAuth = createClient(
      supabaseUrl,
      supabaseAnonKey,
      {
        global: {
          headers: {
            Authorization: authorization,
          },
        },
        auth: {
          persistSession: false,
          autoRefreshToken: false,
        },
      },
    );

    const {
      data: { user },
      error: authError,
    } = await supabaseAuth.auth.getUser();

    if (authError || !user) {
      return jsonResponse({ error: "Invalid authentication." }, 401);
    }

    // 3. Read the requested TechShop order ID
    const body = await req.json();
    const techShopOrderId = body.order_id;

    if (
      typeof techShopOrderId !== "string" ||
      !techShopOrderId.trim()
    ) {
      return jsonResponse({ error: "Invalid order ID." }, 400);
    }

    // 4. Create trusted Supabase client for database operations
    const supabaseAdmin = createClient(
      supabaseUrl,
      supabaseServiceKey,
      {
        auth: {
          persistSession: false,
          autoRefreshToken: false,
        },
      },
    );

    // 5. Fetch order and verify ownership
    const { data: order, error: orderError } = await supabaseAdmin
      .from("orders")
      .select(`
        id,
        order_number,
        user_id,
        status,
        payment_method,
        payment_status,
        total_amount,
        razorpay_order_id
      `)
      .eq("id", techShopOrderId)
      .eq("user_id", user.id)
      .maybeSingle();

    if (orderError) {
      throw orderError;
    }

    if (!order) {
      return jsonResponse({ error: "Order not found." }, 404);
    }

    // 6. Validate order eligibility
    if (
      order.payment_method !== "razorpay" ||
      order.payment_status !== "pending" ||
      order.status !== "pending"
    ) {
      return jsonResponse({
        error: "This order is not eligible for online payment.",
      }, 400);
    }

    // 7. Return an existing Razorpay order if already created
    if (order.razorpay_order_id) {
      return jsonResponse({
        razorpay_order_id: order.razorpay_order_id,
        amount: Math.round(Number(order.total_amount) * 100),
        currency: "INR",
      });
    }

    // 8. Calculate amount from the database order
    const amount = Math.round(Number(order.total_amount) * 100);

    if (!Number.isSafeInteger(amount) || amount < 100) {
      return jsonResponse({ error: "Invalid payment amount." }, 400);
    }

    // 9. Create Razorpay order
    const razorpayResponse = await fetch(
      "https://api.razorpay.com/v1/orders",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          Authorization:
            `Basic ${btoa(`${razorpayKeyId}:${razorpayKeySecret}`)}`,
        },
        body: JSON.stringify({
          amount,
          currency: "INR",
          receipt: order.order_number,
          notes: {
            techshop_order_id: order.id,
            customer_id: user.id,
          },
        }),
      },
    );

    const razorpayData = await razorpayResponse.json();

    if (!razorpayResponse.ok) {
      console.error("Razorpay API error:", razorpayData);

      return jsonResponse({
        error: "Unable to create Razorpay payment order.",
      }, 502);
    }

    // 10. Save Razorpay order ID in TechShop database
    const { data: updatedOrder, error: updateError } =
      await supabaseAdmin
        .from("orders")
        .update({
          razorpay_order_id: razorpayData.id,
          payment_gateway: "razorpay",
        })
        .eq("id", order.id)
        .eq("user_id", user.id)
        .is("razorpay_order_id", null)
        .select("razorpay_order_id")
        .maybeSingle();

    if (updateError) {
      throw updateError;
    }

    // Handle a concurrent request that saved another Razorpay order
    if (!updatedOrder) {
      const { data: latestOrder, error: latestError } =
        await supabaseAdmin
          .from("orders")
          .select("razorpay_order_id")
          .eq("id", order.id)
          .eq("user_id", user.id)
          .maybeSingle();

      if (latestError || !latestOrder?.razorpay_order_id) {
        throw new Error("Unable to save Razorpay order reference.");
      }

      return jsonResponse({
        razorpay_order_id: latestOrder.razorpay_order_id,
        amount,
        currency: "INR",
      });
    }

    // 11. Return payment details to Flutter
    return jsonResponse({
      razorpay_order_id: razorpayData.id,
      amount: razorpayData.amount,
      currency: razorpayData.currency,
    });

  } catch (error) {
    console.error("Create Razorpay order error:", error);

    return jsonResponse({
      error: "Unable to create payment order.",
    }, 500);
  }
});
