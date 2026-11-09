import 'package:flutter_riverpod/flutter_riverpod.dart';

class ComparisonNotifier extends Notifier<List<String>> {
  static const int maxProducts = 4;

  int? _selectedCategoryId;

  @override
  List<String> build() {
    _selectedCategoryId = null;
    return [];
  }

  void addProduct(String productId, {required int categoryId}) {
    if (state.contains(productId)) return;

    if (state.length >= maxProducts) {
      throw Exception('You can compare a maximum of $maxProducts products.');
    }

    if (_selectedCategoryId != null && _selectedCategoryId != categoryId) {
      throw Exception('You can only compare products from the same category.');
    }

    _selectedCategoryId ??= categoryId;

    state = [...state, productId];
  }

  void removeProduct(String productId) {
    state = state.where((id) => id != productId).toList();

    if (state.isEmpty) {
      _selectedCategoryId = null;
    }
  }

  void clearComparison() {
    state = [];
    _selectedCategoryId = null;
  }

  bool isSelected(String productId) {
    return state.contains(productId);
  }

  bool get canAddMore => state.length < maxProducts;
}

final comparisonProvider = NotifierProvider<ComparisonNotifier, List<String>>(
  ComparisonNotifier.new,
);
