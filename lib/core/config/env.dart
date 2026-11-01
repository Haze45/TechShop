class Env {
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  static void validate() {
    if (supabaseUrl.isEmpty || supabasePublishableKey.isEmpty) {
      throw Exception(
        'Supabase configuration is missing. '
            'Run the app with --dart-define-from-file=env.json',
      );
    }
  }
}