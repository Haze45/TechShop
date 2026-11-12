import '../../domain/repositories/product_interaction_repository.dart';
import '../datasources/product_interaction_remote_datasource.dart';

class ProductInteractionRepositoryImpl implements ProductInteractionRepository {
  final ProductInteractionRemoteDataSource remoteDataSource;

  ProductInteractionRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> recordInteraction({
    required String productId,
    required String interactionType,
  }) {
    return remoteDataSource.recordInteraction(
      productId: productId,
      interactionType: interactionType,
    );
  }
}
