import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentlyViewedNotifier extends Notifier<List<String>> {
  static const int maxProducts = 10;
  static const String _storageKey = 'recently_viewed_products';

  bool _hasUserChanges = false;

  @override
  List<String> build() {
    _loadHistory();
    return [];
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedProducts = prefs.getStringList(_storageKey) ?? [];

      // Merge saved history with any products viewed
      // while SharedPreferences was loading.
      final mergedProducts = [
        ...state,
        ...savedProducts.where((id) => !state.contains(id)),
      ];

      if (!_hasUserChanges || mergedProducts.isNotEmpty) {
        state = mergedProducts.take(maxProducts).toList();
      }
    } catch (error) {
      // Keep the in-memory history if loading fails.
    }
  }

  void addProduct(String productId) {
    _hasUserChanges = true;

    state = [
      productId,
      ...state.where((id) => id != productId),
    ].take(maxProducts).toList();

    unawaited(_saveHistory());
  }

  void removeProduct(String productId) {
    _hasUserChanges = true;

    state = state.where((id) => id != productId).toList();

    unawaited(_saveHistory());
  }

  void clearHistory() {
    _hasUserChanges = true;
    state = [];

    unawaited(_saveHistory());
  }

  Future<void> _saveHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, state);
    } catch (error) {
      // The current session still works if saving fails.
    }
  }
}

final recentlyViewedProvider =
    NotifierProvider<RecentlyViewedNotifier, List<String>>(
      RecentlyViewedNotifier.new,
    );
