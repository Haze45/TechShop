import '../repositories/cart_repository.dart';

class GetOrCreateCartUseCase {
  final CartRepository repository;

  GetOrCreateCartUseCase(this.repository);

  Future<String> call(String userId) {
    return repository.getOrCreateCart(userId);
  }
}
