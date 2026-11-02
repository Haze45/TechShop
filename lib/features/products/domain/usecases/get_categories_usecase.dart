
import '../repositories/product_repository.dart';

class GetCategoriesUseCase {
  final ProductRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getCategories();
  }
}
