import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_model.dart';

class AuthRemoteDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSource(this.supabase);

  // =========================================
  // 1. REGISTER
  // =========================================

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );

    final user = response.user;

    if (user == null) return null;

    return UserModel.fromSupabaseUser(user);
  }

  // =========================================
  // 2. LOGIN
  // =========================================

  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;

    if (user == null) {
      throw const AuthException('Unable to retrieve authenticated user.');
    }

    return UserModel.fromSupabaseUser(user);
  }

  // =========================================
  // 3. LOGOUT
  // =========================================

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // =========================================
  // 4. PASSWORD RESET
  // =========================================

  Future<void> resetPassword({
    required String email,
    String? redirectTo,
  }) async {
    await supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  }

  // =========================================
  // 5. GET CURRENT USER
  // =========================================

  UserModel? getCurrentUser() {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    return UserModel.fromSupabaseUser(user);
  }

  Future<void> updatePassword({
    required String newPassword,
  }) async {
    await supabase.auth.updateUser(
      UserAttributes(
        password: newPassword,
      ),
    );
  }

  // =========================================
  // 6. AUTH STATE CHANGES
  // =========================================

  Stream<UserModel?> get authStateChanges {
    return supabase.auth.onAuthStateChange.map((authState) {
      final user = authState.session?.user;

      if (user == null) return null;

      return UserModel.fromSupabaseUser(user);
    });
  }
}