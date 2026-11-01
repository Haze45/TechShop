import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';

import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

import '../../domain/usecases/sign_in_usecase.dart';
import '../../domain/usecases/sign_up_usecase.dart';
import '../../domain/usecases/sign_out_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/watch_auth_state_usecase.dart';
import '../viewmodels/auth_viewmodel.dart';

// =========================================
// 1. REMOTE DATA SOURCE PROVIDER
// =========================================

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final supabase = ref.watch(supabaseProvider);

  return AuthRemoteDataSource(supabase);
});

// =========================================
// 2. REPOSITORY PROVIDER
// =========================================

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);

  return AuthRepositoryImpl(remoteDataSource);
});

// =========================================
// 3. SIGN IN USE CASE PROVIDER
// =========================================

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});

// =========================================
// 4. SIGN UP USE CASE PROVIDER
// =========================================

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

// =========================================
// 5. SIGN OUT USE CASE PROVIDER
// =========================================

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});

// =========================================
// 6. RESET PASSWORD USE CASE PROVIDER
// =========================================

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  return ResetPasswordUseCase(ref.watch(authRepositoryProvider));
});

// =========================================
// 7. GET CURRENT USER USE CASE PROVIDER
// =========================================

final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return GetCurrentUserUseCase(ref.watch(authRepositoryProvider));
});

// =========================================
// 8. WATCH AUTH STATE USE CASE PROVIDER
// =========================================

final watchAuthStateUseCaseProvider = Provider<WatchAuthStateUseCase>((ref) {
  return WatchAuthStateUseCase(ref.watch(authRepositoryProvider));
});

// =========================================
// AUTH VIEWMODEL PROVIDER
// =========================================

final authViewModelProvider =
AsyncNotifierProvider<AuthViewModel, UserEntity?>(
  AuthViewModel.new,
);
