import { createClient } from "npm:@supabase/supabase-js@2";

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Method not allowed" }),
      {
        status: 405,
        headers: { "Content-Type": "application/json" },
      },
    );
  }

  try {
    // 1. Read the authenticated user's access token.
    const authHeader = req.headers.get("Authorization");

    if (!authHeader?.startsWith("Bearer ")) {
      return new Response(
        JSON.stringify({ error: "Authentication required" }),
        {
          status: 401,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    const token = authHeader.substring(7);

    // 2. Initialize Supabase configuration.
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const anonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    // 3. Verify the user's identity using their access token.
    const authClient = createClient(supabaseUrl, anonKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });

    const {
      data: { user },
      error: authError,
    } = await authClient.auth.getUser(token);

    if (authError || !user) {
      return new Response(
        JSON.stringify({ error: "Invalid or expired session" }),
        {
          status: 401,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // 4. Initialize the administrative client.
    const adminClient = createClient(supabaseUrl, serviceRoleKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });

    // Check whether the user has existing orders.
    const { data: existingOrders, error: orderError } = await adminClient
      .from("orders")
      .select("id")
      .eq("user_id", user.id)
      .limit(1);

    if (orderError) {
      throw new Error("Unable to check existing orders.");
    }

    if (existingOrders && existingOrders.length > 0) {
      return new Response(
        JSON.stringify({
          error:
            "This account has existing orders. Please contact support to request account deletion.",
        }),
        {
          status: 409,
          headers: { "Content-Type": "application/json" },
        },
      );
    }

    // Remove the user's profile pictures before deleting the Auth user.
    const bucket = adminClient.storage.from("user-avatars");

    let offset = 0;
    const limit = 1000;

    while (true) {
      const { data: files, error: listError } = await bucket.list(
        user.id,
        {
          limit,
          offset,
        },
      );

      if (listError) {
        throw new Error("Unable to list user avatar files.");
      }

      if (!files || files.length === 0) {
        break;
      }

      const filePaths = files.map(
        (file) => `${user.id}/${file.name}`,
      );

      const { error: removeError } = await bucket.remove(filePaths);

      if (removeError) {
        throw new Error("Unable to remove user avatar files.");
      }

      if (files.length < limit) {
        break;
      }

      offset += files.length;
    }

    // 5. Delete only the authenticated user's account.
    const { error: deleteError } =
      await adminClient.auth.admin.deleteUser(user.id);

    if (deleteError) {
      throw deleteError;
    }

    return new Response(
      JSON.stringify({
        success: true,
        message: "Account deleted successfully",
      }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      },
    );
  } catch (error) {
    console.error("Account deletion failed:", error);

    return new Response(
      JSON.stringify({
        error: "Unable to delete account",
      }),
      {
        status: 500,
        headers: { "Content-Type": "application/json" },
      },
    );
  }
});