import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/recent_search_provider.dart';

class SearchSuggestions extends ConsumerWidget {
  final ValueChanged<String> onSearchSelected;

  const SearchSuggestions({super.key, required this.onSearchSelected});

  static const List<String> suggestions = [
    'Samsung',
    'iPhone',
    'OnePlus',
    'Google Pixel',
    'Lenovo',
    'HP',
    'Dell',
    'ASUS',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSearches = ref.watch(recentSearchProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              TextButton(
                onPressed: () {
                  ref.read(recentSearchProvider.notifier).clearSearches();
                },
                child: const Text('Clear all'),
              ),
            ],
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((query) {
              return InputChip(
                label: Text(query),
                onPressed: () => onSearchSelected(query),
                onDeleted: () {
                  ref.read(recentSearchProvider.notifier).removeSearch(query);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
        ],
        Text('Popular Searches', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((query) {
            return ActionChip(
              avatar: const Icon(Icons.search, size: 16),
              label: Text(query),
              onPressed: () => onSearchSelected(query),
            );
          }).toList(),
        ),
      ],
    );
  }
}
