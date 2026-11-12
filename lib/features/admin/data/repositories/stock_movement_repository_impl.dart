import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/stock_movement_entity.dart';
import '../../domain/repositories/stock_movement_repository.dart';
import '../datasources/stock_movement_remote_datasource.dart';

class StockMovementRepositoryImpl implements StockMovementRepository {
  final StockMovementRemoteDataSource remoteDataSource;

  StockMovementRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<StockMovementEntity>> getAllStockMovements() {
    return remoteDataSource.getAllStockMovements();
  }

  @override
  Future<List<StockMovementEntity>> getProductStockMovements(String productId) {
    return remoteDataSource.getProductStockMovements(productId);
  }

  @override
  Future<String> adjustProductStock({
    required String productId,
    required int quantityChange,
    String? reason,
  }) {
    return remoteDataSource.adjustProductStock(
      productId: productId,
      quantityChange: quantityChange,
      reason: reason,
    );
  }

  @override
  Future<List<ProductEntity>> getInventoryProducts() {
    return remoteDataSource.getInventoryProducts();
  }
}
