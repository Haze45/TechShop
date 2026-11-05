import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/admin_product_remote_datasource.dart';
import '../../data/repositories/admin_product_repository_impl.dart';
import '../../domain/repositories/admin_product_repository.dart';
import '../../domain/usecases/get_all_admin_products.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../products/domain/entities/product_entity.dart';

final adminProductRemoteDataSourceProvider =
    Provider<AdminProductRemoteDataSource>((ref) {
      return AdminProductRemoteDataSource(ref.watch(supabaseProvider));
    });

final adminProductRepositoryProvider = Provider<AdminProductRepository>((ref) {
  return AdminProductRepositoryImpl(
    ref.watch(adminProductRemoteDataSourceProvider),
  );
});

final getAllAdminProductsProvider = Provider<GetAllAdminProducts>((ref) {
  return GetAllAdminProducts(ref.watch(adminProductRepositoryProvider));
});

final adminProductsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  return ref.watch(getAllAdminProductsProvider).call();
});
