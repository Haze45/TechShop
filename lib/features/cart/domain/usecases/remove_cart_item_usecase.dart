import '../repositories/cart_repository.dart';

class RemoveCartItemUseCase {
  final CartRepository repository;

  RemoveCartItemUseCase(this.repository);

  Future<void> call(String itemId) {
    return repository.removeCartItem(itemId);
  }
}