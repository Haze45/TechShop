
import { importPKCS8, SignJWT } from "npm:jose@5.9.6";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type, x-webhook-secret",
};

const allowedStatuses = [
  "confirmed",
  "processing",
  "shipped",
  "delivered",
  "cancelled",
];

const messages: Record<string, { title: string; body: string }> = {
  confirmed: {
    title: "Order Confirmed! 🎉",
    body: "Your TechShop order has been confirmed.",
  },
  processing: {
    title: "Order Processing",
    body: "We're preparing your TechShop order.",
  },
  shipped: {
    title: "Order Shipped! 🚚",
    body: "Your TechShop order is on its way.",
  },
  delivered: {
    title: "Order Delivered! 📦",
    body: "Your TechShop order has been delivered.",
  },
  cancelled: {
    title: "Order Cancelled",
    body: "Your TechShop order has been cancelled.",
  },
};

interface WebhookPayload {
  type?: string;
  table?: string;
  schema?: string;
  record?: Record<string, unknown>;
  old_record?: Record<string, unknown>;
}

interface FirebaseServiceAccount {
  project_id: string;
  client_email: string;
  private_key: string;
}

async function getFirebaseAccessToken(
  serviceAccount: FirebaseServiceAccount,
): Promise<string> {
  const privateKey = await importPKCS8(
    serviceAccount.private_key,
    "RS256",
  );

  const now = Math.floor(Date.now() / 1000);

  const assertion = await new SignJWT({
    scope: "https://www.googleapis.com/auth/firebase.messaging",
  })
    .setProtectedHeader({ alg: "RS256", typ: "JWT" })
    .setIssuer(serviceAccount.client_email)
    .setSubject(serviceAccount.client_email)
    .setAudience("https://oauth2.googleapis.com/token")
    .setIssuedAt(now)
    .setExpirationTime(now + 3600)
    .sign(privateKey);

  const response = await fetch(
    "https://oauth2.googleapis.com/token",
    {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: new URLSearchParams({
        grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
        assertion,
      }),
    },
  );

  const result = await response.json();

  if (!response.ok) {
    throw new Error(
      `Firebase authentication failed: ${JSON.stringify(result)}`,
    );
  }

  return result.access_token;
}

function getNotificationMessage(status: string) {
  return messages[status] ?? {
    title: "TechShop Order Update",
    body: "Your order status has been updated.",
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return new Response(
        JSON.stringify({ error: "Method not allowed" }),
        {
          status: 405,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    // Verify the database webhook's shared secret.
    const expectedSecret = Deno.env.get(
      "ORDER_NOTIFICATION_WEBHOOK_SECRET",
    );

    const receivedSecret = req.headers.get("x-webhook-secret");

    if (
      !expectedSecret ||
      !receivedSecret ||
      receivedSecret !== expectedSecret
    ) {
      return new Response(
        JSON.stringify({ error: "Unauthorized" }),
        {
          status: 401,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    const payload: WebhookPayload = await req.json();

    if (
      payload.schema !== "public" ||
      payload.table !== "orders" ||
      payload.type !== "UPDATE"
    ) {
      return new Response(
        JSON.stringify({ message: "Ignored event" }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    const order = payload.record;
    const oldOrder = payload.old_record;

    if (!order || !oldOrder) {
      throw new Error("Order webhook record is missing.");
    }

    const status = String(order.status ?? "");
    const previousStatus = String(oldOrder.status ?? "");

    // Send only when the order status actually changes.
    if (status === previousStatus || !allowedStatuses.includes(status)) {
      return new Response(
        JSON.stringify({ message: "No notification required" }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    const userId = String(order.user_id ?? "");
    const orderId = String(order.id ?? "");

    if (!userId || !orderId) {
      throw new Error("Order user ID or order ID is missing.");
    }

    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
    const serviceAccountJson = Deno.env.get(
      "FIREBASE_SERVICE_ACCOUNT",
    );

    if (!supabaseUrl || !serviceRoleKey || !serviceAccountJson) {
      throw new Error("Required Supabase or Firebase secrets are missing.");
    }

    const serviceAccount = JSON.parse(
      serviceAccountJson,
    ) as FirebaseServiceAccount;

    const tokenResponse = await fetch(
      `${supabaseUrl}/rest/v1/device_tokens?user_id=eq.${encodeURIComponent(userId)}&select=token`,
      {
        headers: {
          apikey: serviceRoleKey,
          Authorization: `Bearer ${serviceRoleKey}`,
        },
      },
    );

    if (!tokenResponse.ok) {
      throw new Error("Unable to retrieve customer device tokens.");
    }

    const devices = await tokenResponse.json();

    if (!Array.isArray(devices) || devices.length === 0) {
      return new Response(
        JSON.stringify({
          message: "No registered devices for this customer.",
        }),
        {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
          },
        },
      );
    }

    const accessToken = await getFirebaseAccessToken(serviceAccount);

    const notification = getNotificationMessage(status);

    const orderNumber = String(
      order.order_number ?? order.id,
    );

    const results = await Promise.all(
      devices.map(async (device: { token: string }) => {
        const response = await fetch(
          `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
          {
            method: "POST",
            headers: {
              Authorization: `Bearer ${accessToken}`,
              "Content-Type": "application/json",
            },
            body: JSON.stringify({
              message: {
                token: device.token,
                notification: {
                  title: notification.title,
                  body: notification.body,
                },
                data: {
                  order_id: orderId,
                  order_number: orderNumber,
                  type: `order_${status}`,
                  status,
                },
                android: {
                  priority: "high",
                  notification: {
                    channel_id: "techshop_orders",
                  },
                },
              },
            }),
          },
        );

        const result = await response.json();

        return {
          success: response.ok,
          result: response.ok ? "sent" : result,
        };
      }),
    );

    const successful = results.filter((r) => r.success).length;
    const failed = results.length - successful;

    return new Response(
      JSON.stringify({
        message: "Order notification processing completed.",
        status,
        successful,
        failed,
      }),
      {
        status: 200,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  } catch (error) {
    console.error("Order notification error:", error);

    return new Response(
      JSON.stringify({
        error: error instanceof Error
          ? error.message
          : "Unexpected error",
      }),
      {
        status: 500,
        headers: {
          ...corsHeaders,
          "Content-Type": "application/json",
        },
      },
    );
  }
});
