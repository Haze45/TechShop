import '../repositories/cart_repository.dart';

class ClearCartUseCase {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  Future<void> call(String userId) {
    return repository.clearCart(userId);
  }
}