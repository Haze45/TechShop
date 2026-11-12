import '../../../products/domain/entities/product_entity.dart';
import '../entities/stock_movement_entity.dart';

abstract class StockMovementRepository {
  Future<List<StockMovementEntity>> getAllStockMovements();

  Future<List<StockMovementEntity>> getProductStockMovements(String productId);

  Future<String> adjustProductStock({
    required String productId,
    required int quantityChange,
    String? reason,
  });

  Future<List<ProductEntity>> getInventoryProducts();
}
