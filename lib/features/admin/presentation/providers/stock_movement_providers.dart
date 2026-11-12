import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../data/datasources/stock_movement_remote_datasource.dart';
import '../../data/repositories/stock_movement_repository_impl.dart';

import '../../domain/entities/stock_movement_entity.dart';
import '../../domain/repositories/stock_movement_repository.dart';

// Remote Data Source
final stockMovementRemoteDataSourceProvider =
    Provider<StockMovementRemoteDataSource>((ref) {
      return StockMovementRemoteDataSource(ref.watch(supabaseProvider));
    });

// Repository
final stockMovementRepositoryProvider = Provider<StockMovementRepository>((
  ref,
) {
  return StockMovementRepositoryImpl(
    ref.watch(stockMovementRemoteDataSourceProvider),
  );
});

// All stock movements
final allStockMovementsProvider = FutureProvider<List<StockMovementEntity>>((
  ref,
) {
  return ref.watch(stockMovementRepositoryProvider).getAllStockMovements();
});

// Product-specific stock movements
final productStockMovementsProvider =
    FutureProvider.family<List<StockMovementEntity>, String>((ref, productId) {
      return ref
          .watch(stockMovementRepositoryProvider)
          .getProductStockMovements(productId);
    });

final inventoryProductsProvider = FutureProvider<List<ProductEntity>>((ref) {
  return ref.watch(stockMovementRepositoryProvider).getInventoryProducts();
});
