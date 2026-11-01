import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class WatchAuthStateUseCase {
  final AuthRepository repository;

  WatchAuthStateUseCase(this.repository);

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}