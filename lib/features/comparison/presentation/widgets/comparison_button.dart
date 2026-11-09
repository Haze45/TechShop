import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/comparison_provider.dart';

class ComparisonButton extends ConsumerWidget {
  const ComparisonButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedProducts = ref.watch(comparisonProvider);
    final count = selectedProducts.length;

    return FilledButton.tonalIcon(
      onPressed: count == 0
          ? null
          : () {
              context.push('/compare');
            },
      icon: const Icon(Icons.compare_arrows),
      label: Text('Compare ($count)'),
    );
  }
}
