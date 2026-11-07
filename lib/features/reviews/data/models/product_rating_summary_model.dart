import '../../domain/entities/product_rating_summary_entity.dart';

class ProductRatingSummaryModel extends ProductRatingSummaryEntity {
  const ProductRatingSummaryModel({
    required super.productId,
    required super.averageRating,
    required super.reviewCount,
  });

  factory ProductRatingSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProductRatingSummaryModel(
      productId: json['product_id'] as String,
      averageRating: (json['average_rating'] as num).toDouble(),
      reviewCount: (json['review_count'] as num).toInt(),
    );
  }
}
