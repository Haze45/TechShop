import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../data/datasources/admin_product_creation_datasource.dart';
import '../../data/repositories/admin_product_creation_repository_impl.dart';
import '../../domain/repositories/admin_product_creation_repository.dart';

final adminProductCreationDataSourceProvider =
    Provider<AdminProductCreationDataSource>((ref) {
      return AdminProductCreationDataSource(ref.watch(supabaseProvider));
    });

final adminProductCreationRepositoryProvider =
    Provider<AdminProductCreationRepository>((ref) {
      return AdminProductCreationRepositoryImpl(
        ref.watch(adminProductCreationDataSourceProvider),
      );
    });

final adminCategoriesProvider = FutureProvider<List<Map<String, dynamic>>>((
  ref,
) {
  return ref.watch(adminProductCreationRepositoryProvider).getCategories();
});

final adminBrandsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(adminProductCreationRepositoryProvider).getBrands();
});
