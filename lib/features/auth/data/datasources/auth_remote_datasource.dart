import 'dart:typed_data';

import 'package:mime/mime.dart';
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
    await supabase.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  // =========================================
  // 5. GET CURRENT USER
  // =========================================

  UserModel? getCurrentUser() {
    final user = supabase.auth.currentUser;

    if (user == null) return null;

    return UserModel.fromSupabaseUser(user);
  }

  Future<void> updatePassword({required String newPassword}) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    // Update the profiles table.
    await supabase.from('profiles').upsert({
      'id': user.id,
      'full_name': fullName.trim(),
      'phone': phone.trim(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    // Keep Supabase Auth metadata synchronized.
    await supabase.auth.updateUser(
      UserAttributes(
        data: {'full_name': fullName.trim(), 'phone': phone.trim()},
      ),
    );
  }

  Future<String> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User is not logged in.');
    }

    final extension = fileName.split('.').last.toLowerCase();

    const allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

    if (!allowedExtensions.contains(extension)) {
      throw Exception('Only JPG, PNG and WEBP images are allowed.');
    }

    final mimeType = lookupMimeType(fileName);

    if (mimeType == null) {
      throw Exception('Unable to determine image format.');
    }

    final filePath =
        '${user.id}/avatar_${DateTime.now().millisecondsSinceEpoch}.$extension';

    await supabase.storage
        .from('user-avatars')
        .uploadBinary(
          filePath,
          imageBytes,
          fileOptions: FileOptions(contentType: mimeType, upsert: false),
        );

    // Save the storage path in the profiles table.
    await supabase.from('profiles').upsert({
      'id': user.id,
      'avatar_url': filePath,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });

    // Synchronize the Auth metadata with the storage path.
    await supabase.auth.updateUser(
      UserAttributes(data: {'avatar_url': filePath}),
    );

    // Return a temporary URL for displaying the image.
    return supabase.storage
        .from('user-avatars')
        .createSignedUrl(filePath, 60 * 60);
  }

  Future<String?> getAvatarSignedUrl() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return null;
    }

    final response = await supabase
        .from('profiles')
        .select('avatar_url')
        .eq('id', user.id)
        .maybeSingle();

    final filePath = response?['avatar_url'] as String?;

    if (filePath == null || filePath.isEmpty) {
      return null;
    }

    return supabase.storage
        .from('user-avatars')
        .createSignedUrl(filePath, 60 * 60);
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
