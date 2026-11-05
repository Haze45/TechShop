import '../repositories/admin_repository.dart';

class CheckAdminRole {
  final AdminRepository repository;

  CheckAdminRole(this.repository);

  Future<bool> call() {
    return repository.isAdmin();
  }
}
