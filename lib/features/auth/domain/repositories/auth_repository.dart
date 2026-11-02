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
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  // Logout
  Future<void> signOut();

  // Password reset
  Future<void> resetPassword({
    required String email,
    String? redirectTo,
  });

  // Current user
  UserEntity? getCurrentUser();

  Future<void> updatePassword({
    required String newPassword,
  });

  // Authentication state
  Stream<UserEntity?> get authStateChanges;

}