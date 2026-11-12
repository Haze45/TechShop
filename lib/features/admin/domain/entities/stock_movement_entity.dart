class StockMovementEntity {
  final String id;
  final String productId;
  final String? changedBy;
  final String changeType;
  final int quantityChange;
  final int previousStock;
  final int newStock;
  final String? reason;
  final String? referenceOrderId;
  final DateTime createdAt;

  const StockMovementEntity({
    required this.id,
    required this.productId,
    this.changedBy,
    required this.changeType,
    required this.quantityChange,
    required this.previousStock,
    required this.newStock,
    this.reason,
    this.referenceOrderId,
    required this.createdAt,
  });
}
