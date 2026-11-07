import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/review_providers.dart';

class ProductRatingWidget extends ConsumerWidget {
  final String productId;
  final double starSize;

  const ProductRatingWidget({
    super.key,
    required this.productId,
    this.starSize = 18,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingAsync = ref.watch(productRatingSummaryProvider(productId));

    return ratingAsync.when(
      loading: () => const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, stack) => const SizedBox.shrink(),
      data: (summary) {
        if (summary == null || summary.reviewCount == 0) {
          return Text(
            'No ratings yet',
            style: Theme.of(context).textTheme.bodySmall,
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 18),
            const SizedBox(width: 4),
            Text(
              summary.averageRating.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 4),
            Text(
              '(${summary.reviewCount})',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
      },
    );
  }
}
