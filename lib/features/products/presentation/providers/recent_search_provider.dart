import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentSearchNotifier extends Notifier<List<String>> {
  static const String _storageKey = 'techshop_recent_searches';
  static const int maxSearches = 8;

  @override
  List<String> build() {
    _loadSearches();
    return [];
  }

  Future<void> _loadSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSearches = prefs.getStringList(_storageKey) ?? [];

      final merged = [
        ...state,
        ...savedSearches.where((item) => !state.contains(item)),
      ];

      state = merged.take(maxSearches).toList();
    } catch (_) {
      // Keep the current in-memory searches.
    }
  }

  void addSearch(String query) {
    final value = query.trim();

    if (value.isEmpty) return;

    state = [
      value,
      ...state.where((item) => item.toLowerCase() != value.toLowerCase()),
    ].take(maxSearches).toList();

    unawaited(_saveSearches());
  }

  void removeSearch(String query) {
    state = state.where((item) => item != query).toList();
    unawaited(_saveSearches());
  }

  void clearSearches() {
    state = [];
    unawaited(_saveSearches());
  }

  Future<void> _saveSearches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, state);
    } catch (_) {
      // Recent searches still work during the current session.
    }
  }
}

final recentSearchProvider =
    NotifierProvider<RecentSearchNotifier, List<String>>(
      RecentSearchNotifier.new,
    );
