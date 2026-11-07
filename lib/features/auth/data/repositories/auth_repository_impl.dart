import 'dart:typed_data';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  // =========================================
  // 1. REGISTER
  // =========================================

  @override
  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) {
    return remoteDataSource.signUp(
      email: email,
      password: password,
      fullName: fullName,
      phone: phone,
    );
  }

  // =========================================
  // 2. LOGIN
  // =========================================

  @override
  Future<UserEntity> signIn({required String email, required String password}) {
    return remoteDataSource.signIn(email: email, password: password);
  }

  // =========================================
  // 3. LOGOUT
  // =========================================

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }

  // =========================================
  // 4. PASSWORD RESET
  // =========================================

  @override
  Future<void> resetPassword({required String email, String? redirectTo}) {
    return remoteDataSource.resetPassword(email: email, redirectTo: redirectTo);
  }

  // =========================================
  // 5. CURRENT USER
  // =========================================

  @override
  UserEntity? getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<void> updatePassword({required String newPassword}) {
    return remoteDataSource.updatePassword(newPassword: newPassword);
  }

  @override
  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) {
    return remoteDataSource.updateProfile(fullName: fullName, phone: phone);
  }

  @override
  Future<String> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  }) {
    return remoteDataSource.uploadAvatar(
      imageBytes: imageBytes,
      fileName: fileName,
    );
  }

  @override
  Future<String?> getAvatarSignedUrl() {
    return remoteDataSource.getAvatarSignedUrl();
  }

  @override
  Future<void> deleteAccount() {
    return remoteDataSource.deleteAccount();
  }

  // =========================================
  // 6. AUTH STATE CHANGES
  // =========================================

  @override
  Stream<UserEntity?> get authStateChanges {
    return remoteDataSource.authStateChanges;
  }
}
