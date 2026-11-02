import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  Future<CartEntity?> call(String userId) {
    return repository.getCart(userId);
  }
}