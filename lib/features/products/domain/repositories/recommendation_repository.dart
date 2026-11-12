import '../entities/product_entity.dart';

abstract class RecommendationRepository {
  Future<List<ProductEntity>> getPersonalizedRecommendations({int limit = 10});
}
