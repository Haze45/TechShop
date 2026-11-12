import '../../domain/entities/stock_movement_entity.dart';

class StockMovementModel extends StockMovementEntity {
  const StockMovementModel({
    required super.id,
    required super.productId,
    super.changedBy,
    required super.changeType,
    required super.quantityChange,
    required super.previousStock,
    required super.newStock,
    super.reason,
    super.referenceOrderId,
    required super.createdAt,
  });

  factory StockMovementModel.fromJson(Map<String, dynamic> json) {
    return StockMovementModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      changedBy: json['changed_by'] as String?,
      changeType: json['change_type'] as String,
      quantityChange: (json['quantity_change'] as num).toInt(),
      previousStock: (json['previous_stock'] as num).toInt(),
      newStock: (json['new_stock'] as num).toInt(),
      reason: json['reason'] as String?,
      referenceOrderId: json['reference_order_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
