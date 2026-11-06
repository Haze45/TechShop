import '../repositories/cart_repository.dart';

class UpdateCartItemQuantityUseCase {
  final CartRepository repository;

  UpdateCartItemQuantityUseCase(this.repository);

  Future<void> call({required String itemId, required int quantity}) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }

    return repository.updateCartItemQuantity(
      itemId: itemId,
      quantity: quantity,
    );
  }
}
