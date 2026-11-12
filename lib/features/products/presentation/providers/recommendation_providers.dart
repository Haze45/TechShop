import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/recommendation_remote_datasource.dart';
import '../../data/repositories/recommendation_repository_impl.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/recommendation_repository.dart';

final recommendationRemoteDataSourceProvider =
    Provider<RecommendationRemoteDataSource>((ref) {
      return RecommendationRemoteDataSource(ref.watch(supabaseProvider));
    });

final recommendationRepositoryProvider = Provider<RecommendationRepository>((
  ref,
) {
  return RecommendationRepositoryImpl(
    ref.watch(recommendationRemoteDataSourceProvider),
  );
});

final personalizedRecommendationsProvider = FutureProvider<List<ProductEntity>>(
  (ref) {
    // Re-fetch recommendations when the authenticated user changes.
    ref.watch(recommendationUserIdProvider);

    return ref
        .watch(recommendationRepositoryProvider)
        .getPersonalizedRecommendations(limit: 10);
  },
);

final recommendationUserIdProvider = StreamProvider<String?>((ref) {
  return ref
      .watch(supabaseProvider)
      .auth
      .onAuthStateChange
      .map((authState) => authState.session?.user.id)
      .distinct();
});
