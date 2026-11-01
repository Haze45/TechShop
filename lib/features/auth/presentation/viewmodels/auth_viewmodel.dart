import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/user_entity.dart';
import '../providers/auth_providers.dart';

class AuthViewModel extends AsyncNotifier<UserEntity?> {
  StreamSubscription<UserEntity?>? _authSubscription;

  @override
  FutureOr<UserEntity?> build() {
    // Get the currently authenticated user.
    final currentUser = ref.read(getCurrentUserUseCaseProvider)();

    // Listen for authentication changes.
    _authSubscription =
        ref.read(watchAuthStateUseCaseProvider)().listen(
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

  // =========================================
  // 5. GET CURRENT USER
  // =========================================

  UserEntity? get currentUser {
    return state.value;
  }
}