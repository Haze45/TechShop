import '../repositories/cart_repository.dart';

class AddToCartUseCase {
  final CartRepository repository;

  AddToCartUseCase(this.repository);

  Future<void> call({
    required String userId,
    required String productId,
    int quantity = 1,
  }) {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }

    return repository.addToCart(
      userId: userId,
      productId: productId,
      quantity: quantity,
    );
  }
}
