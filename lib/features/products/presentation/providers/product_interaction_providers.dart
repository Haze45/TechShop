import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/product_interaction_remote_datasource.dart';
import '../../data/repositories/product_interaction_repository_impl.dart';
import '../../domain/repositories/product_interaction_repository.dart';

final productInteractionRemoteDataSourceProvider =
    Provider<ProductInteractionRemoteDataSource>((ref) {
      return ProductInteractionRemoteDataSource(ref.watch(supabaseProvider));
    });

final productInteractionRepositoryProvider =
    Provider<ProductInteractionRepository>((ref) {
      return ProductInteractionRepositoryImpl(
        ref.watch(productInteractionRemoteDataSourceProvider),
      );
    });
