import 'dart:typed_data';

import '../entities/user_entity.dart';

abstract class AuthRepository {
  // Register
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  });

  // Login
  Future<UserEntity> signIn({required String email, required String password});

  // Logout
  Future<void> signOut();

  // Password reset
  Future<void> resetPassword({required String email, String? redirectTo});

  // Current user
  UserEntity? getCurrentUser();

  Future<void> updatePassword({required String newPassword});

  Future<void> updateProfile({
    required String fullName,
    required String phone,
  });

  Future<String> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  });

  Future<String?> getAvatarSignedUrl();

  Future<void> deleteAccount();

  // Authentication state
  Stream<UserEntity?> get authStateChanges;
}
