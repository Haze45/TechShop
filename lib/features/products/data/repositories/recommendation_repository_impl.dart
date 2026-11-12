import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/recommendation_repository.dart';
import '../datasources/recommendation_remote_datasource.dart';

class RecommendationRepositoryImpl implements RecommendationRepository {
  final RecommendationRemoteDataSource remoteDataSource;

  RecommendationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProductEntity>> getPersonalizedRecommendations({int limit = 10}) {
    return remoteDataSource.getPersonalizedRecommendations(limit: limit);
  }
}
