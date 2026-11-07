import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/device_token_service.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_providers.dart';

class AuthViewModel extends AsyncNotifier<UserEntity?> {
  StreamSubscription<UserEntity?>? _authSubscription;

  @override
  FutureOr<UserEntity?> build() {
    // Get the currently authenticated user.
    final currentUser = ref.read(getCurrentUserUseCaseProvider)();

    // Listen for authentication changes.
    _authSubscription = ref
        .read(watchAuthStateUseCaseProvider)()
        .listen(
          (user) {
            state = AsyncData(user);
          },
          onError: (Object error, StackTrace stackTrace) {
            state = AsyncError(error, stackTrace);
          },
        );

    // Cancel the subscription when the provider is disposed.
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    return currentUser;
  }

  // =========================================
  // 1. REGISTER
  // =========================================

  Future<UserEntity?> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final user = await ref.read(signUpUseCaseProvider)(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
      );

      return user;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // =========================================
  // 2. LOGIN
  // =========================================

  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    try {
      final user = await ref.read(signInUseCaseProvider)(
        email: email,
        password: password,
      );

      state = AsyncData(user);

      return user;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // =========================================
  // 3. LOGOUT
  // =========================================

  Future<void> signOut() async {
    state = const AsyncLoading();

    try {
      try {
        await DeviceTokenService.instance.removeCurrentDeviceToken();
      } catch (error, stackTrace) {
        debugPrint('FCM token removal failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      }

      await ref.read(signOutUseCaseProvider)();

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // =========================================
  // 4. PASSWORD RESET
  // =========================================

  Future<void> resetPassword({
    required String email,
    String? redirectTo,
  }) async {
    try {
      await ref.read(resetPasswordUseCaseProvider)(
        email: email,
        redirectTo: redirectTo,
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updatePassword({required String newPassword}) async {
    try {
      await ref.read(updatePasswordUseCaseProvider)(newPassword: newPassword);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    try {
      await ref
          .read(authRepositoryProvider)
          .updateProfile(fullName: fullName, phone: phone);

      // Refresh the current authenticated user.
      state = AsyncData(ref.read(authRepositoryProvider).getCurrentUser());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<String> uploadAvatar({
    required Uint8List imageBytes,
    required String fileName,
  }) async {
    try {
      return await ref
          .read(authRepositoryProvider)
          .uploadAvatar(imageBytes: imageBytes, fileName: fileName);
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    state = const AsyncLoading();

    try {
      // Remove the current device's FCM token first.
      try {
        await DeviceTokenService.instance.removeCurrentDeviceToken();
      } catch (error) {
        debugPrint('FCM token removal failed: $error');
      }

      await ref.read(authRepositoryProvider).deleteAccount();

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // =========================================
  // 5. GET CURRENT USER
  // =========================================

  UserEntity? get currentUser {
    return state.value;
  }
}
