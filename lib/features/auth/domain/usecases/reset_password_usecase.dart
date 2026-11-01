import '../repositories/auth_repository.dart';

class ResetPasswordUseCase {
  final AuthRepository repository;

  ResetPasswordUseCase(this.repository);

  Future<void> call({
    required String email,
    String? redirectTo,
  }) {
    return repository.resetPassword(
      email: email,
      redirectTo: redirectTo,
    );
  }
}