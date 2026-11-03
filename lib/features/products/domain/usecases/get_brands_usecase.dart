import '../repositories/product_repository.dart';

class GetBrandsUseCase {
  final ProductRepository repository;

  GetBrandsUseCase(this.repository);

  Future<List<Map<String, dynamic>>> call() {
    return repository.getBrands();
  }
}
