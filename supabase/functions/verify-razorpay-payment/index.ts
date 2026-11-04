
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

// Convert bytes to hexadecimal
function toHex(buffer: ArrayBuffer): string {
  return Array.from(new Uint8Array(buffer))
    .map((byte) => byte.toString(16).padStart(2, "0"))
    .join("");
}

// Constant-time comparison
function safeCompare(a: string, b: string): boolean {
  if (a.length !== b.length) return false;

  let result = 0;

  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }

  return result === 0;
}

// Generate Razorpay HMAC SHA-256 signature
async function generateSignature(
  orderId: string,
  paymentId: string,
  secret: string,
): Promise<string> {
  const encoder = new TextEncoder();

  const key = await crypto.subtle.importKey(
    "raw",
    encoder.encode(secret),
    {
      name: "HMAC",
      hash: "SHA-256",
    },
    false,
    ["sign"],
  );

  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    encoder.encode(`${orderId}|${paymentId}`),
  );

  return toHex(signature);
}

Deno.serve(async (req: Request) => {
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

    // 2. Authenticate customer
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

    // 3. Read payment verification details
    const body = await req.json();

    const techShopOrderId = body.order_id;
    const razorpayOrderId = body.razorpay_order_id;
    const razorpayPaymentId = body.razorpay_payment_id;
    const razorpaySignature = body.razorpay_signature;

    if (
      typeof techShopOrderId !== "string" ||
      typeof razorpayOrderId !== "string" ||
      typeof razorpayPaymentId !== "string" ||
      typeof razorpaySignature !== "string" ||
      !techShopOrderId.trim() ||
      !razorpayOrderId.trim() ||
      !razorpayPaymentId.trim() ||
      !razorpaySignature.trim()
    ) {
      return jsonResponse({
        error: "Invalid payment verification details.",
      }, 400);
    }

    // 4. Create trusted Supabase client
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

    // 5. Fetch TechShop order and verify ownership
    const { data: order, error: orderError } =
      await supabaseAdmin
        .from("orders")
        .select(`
          id,
          user_id,
          status,
          payment_method,
          payment_status,
          total_amount,
          razorpay_order_id,
          razorpay_payment_id
        `)
        .eq("id", techShopOrderId)
        .eq("user_id", user.id)
        .maybeSingle();

    if (orderError) throw orderError;

    if (!order) {
      return jsonResponse({ error: "Order not found." }, 404);
    }

    // 6. Validate order details
    if (
      order.payment_method !== "razorpay" ||
      order.razorpay_order_id !== razorpayOrderId
    ) {
      return jsonResponse({
        error: "Payment does not match this order.",
      }, 400);
    }

    // 7. Verify Razorpay signature
    const expectedSignature = await generateSignature(
      razorpayOrderId,
      razorpayPaymentId,
      razorpayKeySecret,
    );

    if (!safeCompare(expectedSignature, razorpaySignature)) {
      return jsonResponse({
        error: "Invalid Razorpay payment signature.",
      }, 400);
    }

    // 8. Retrieve payment directly from Razorpay
    const paymentResponse = await fetch(
      `https://api.razorpay.com/v1/payments/${encodeURIComponent(razorpayPaymentId)}`,
      {
        method: "GET",
        headers: {
          Authorization:
            `Basic ${btoa(`${razorpayKeyId}:${razorpayKeySecret}`)}`,
        },
      },
    );

    const payment = await paymentResponse.json();

    if (!paymentResponse.ok) {
      console.error("Razorpay payment lookup failed.");

      return jsonResponse({
        error: "Unable to retrieve payment details.",
      }, 502);
    }

    // 9. Verify payment against the database order
    const expectedAmount = Math.round(
      Number(order.total_amount) * 100,
    );

    if (
      payment.id !== razorpayPaymentId ||
      payment.order_id !== razorpayOrderId ||
      payment.amount !== expectedAmount ||
      payment.currency !== "INR" ||
      payment.status !== "captured"
    ) {
      return jsonResponse({
        error: "Payment details could not be verified.",
      }, 400);
    }

    // 10. Handle an already verified payment
    if (order.payment_status === "paid") {
      if (order.razorpay_payment_id === razorpayPaymentId) {
        return jsonResponse({ verified: true });
      }

      return jsonResponse({
        error: "This order has already been paid.",
      }, 409);
    }

    if (order.payment_status !== "pending") {
      return jsonResponse({
        error: "Order payment is not pending.",
      }, 409);
    }

    if (order.status !== "pending") {
      return jsonResponse({
        error: "Order cannot be confirmed in its current status.",
      }, 409);
    }

    // 11. Update order only if payment is still pending
    // 11. Update order only if payment is still pending
    const { data: updatedOrder, error: updateError } =
      await supabaseAdmin
        .from("orders")
        .update({
          status: "confirmed",
          payment_status: "paid",
          razorpay_payment_id: razorpayPaymentId,
          payment_verified_at: new Date().toISOString(),
        })
        .eq("id", techShopOrderId)
        .eq("user_id", user.id)
        .eq("payment_status", "pending")
        .eq("razorpay_order_id", razorpayOrderId)
        .eq("status", "pending")
        .select("id")
        .maybeSingle();

    if (updateError) throw updateError;

    if (!updatedOrder) {
      // Handle a repeated request for the same verified payment
      const { data: latestOrder, error: latestError } =
        await supabaseAdmin
          .from("orders")
          .select("payment_status, razorpay_payment_id")
          .eq("id", techShopOrderId)
          .eq("user_id", user.id)
          .maybeSingle();

      if (
        !latestError &&
        latestOrder?.payment_status === "paid" &&
        latestOrder.razorpay_payment_id === razorpayPaymentId
      ) {
        return jsonResponse({ verified: true });
      }

      return jsonResponse({
        error: "Order payment status could not be updated.",
      }, 409);
    }

    return jsonResponse({
      verified: true,
      message: "Payment verified successfully.",
    });

  } catch (error) {
    console.error("Payment verification error:", error);

    return jsonResponse({
      error: "Unable to verify payment.",
    }, 500);
  }
});
