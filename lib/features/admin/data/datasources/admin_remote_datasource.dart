import 'package:supabase_flutter/supabase_flutter.dart';

class AdminRemoteDataSource {
  final SupabaseClient supabaseClient;

  AdminRemoteDataSource(this.supabaseClient);

  Future<bool> isAdmin() async {
    final user = supabaseClient.auth.currentUser;

    if (user == null) {
      return false;
    }

    final result = await supabaseClient.rpc('is_admin');

    return result == true;
  }
}
