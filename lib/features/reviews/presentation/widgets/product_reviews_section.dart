import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/product_review_entity.dart';
import '../providers/review_providers.dart';

class ProductReviewsSection extends ConsumerWidget {
  final String productId;

  const ProductReviewsSection({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));
    final myReviewAsync = ref.watch(myProductReviewProvider(productId));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Customer Reviews',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          reviewsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                const Text('Unable to load reviews. Please try again.'),
            data: (reviews) {
              if (reviews.isEmpty) {
                return const Text(
                  'No reviews yet. Be the first to review this product!',
                );
              }

              final averageRating =
                  reviews.fold<int>(0, (sum, review) => sum + review.rating) /
                  reviews.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStars(averageRating.round()),
                          Text('${reviews.length} reviews'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ...reviews.map((review) => _ReviewTile(review: review)),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          myReviewAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const SizedBox.shrink(),
            data: (myReview) {
              if (myReview != null) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Review',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(myReview.title),
                        const SizedBox(height: 6),
                        Text(myReview.review),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Status: ${myReview.status.toUpperCase()}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                _showReviewDialog(
                                  context,
                                  ref,
                                  existingReview: myReview,
                                );
                              },
                              child: const Text('Edit'),
                            ),
                            TextButton(
                              onPressed: () {
                                _deleteReview(context, ref, myReview.id);
                              },
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showReviewDialog(context, ref),
                  icon: const Icon(Icons.rate_review_outlined),
                  label: const Text('Write a Review'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStars(int rating) {
    return Row(
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        ),
      ),
    );
  }

  Future<void> _showReviewDialog(
    BuildContext context,
    WidgetRef ref, {
    ProductReviewEntity? existingReview,
  }) async {
    final titleController = TextEditingController(
      text: existingReview?.title ?? '',
    );

    final reviewController = TextEditingController(
      text: existingReview?.review ?? '',
    );

    int selectedRating = existingReview?.rating ?? 5;
    bool isSubmitting = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                existingReview == null ? 'Write a Review' : 'Edit Your Review',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your rating'),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(
                        5,
                        (index) => IconButton(
                          onPressed: isSubmitting
                              ? null
                              : () {
                                  setDialogState(() {
                                    selectedRating = index + 1;
                                  });
                                },
                          icon: Icon(
                            index < selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      enabled: !isSubmitting,
                      decoration: const InputDecoration(
                        labelText: 'Review title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: reviewController,
                      enabled: !isSubmitting,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Your review',
                        alignLabelWithHint: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final title = titleController.text.trim();
                          final review = reviewController.text.trim();

                          if (title.isEmpty || review.isEmpty) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please enter a title and review.',
                                ),
                              ),
                            );
                            return;
                          }

                          setDialogState(() {
                            isSubmitting = true;
                          });

                          try {
                            if (existingReview == null) {
                              await ref
                                  .read(reviewRepositoryProvider)
                                  .submitReview(
                                    productId: productId,
                                    rating: selectedRating,
                                    title: title,
                                    review: review,
                                  );
                            } else {
                              await ref
                                  .read(reviewRepositoryProvider)
                                  .updateReview(
                                    reviewId: existingReview.id,
                                    rating: selectedRating,
                                    title: title,
                                    review: review,
                                  );
                            }

                            ref.invalidate(productReviewsProvider(productId));
                            ref.invalidate(myProductReviewProvider(productId));

                            if (!dialogContext.mounted) return;

                            Navigator.pop(dialogContext);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  existingReview == null
                                      ? 'Review submitted! It will appear after approval.'
                                      : 'Review updated! It will appear after approval.',
                                ),
                              ),
                            );
                          } catch (error) {
                            setDialogState(() {
                              isSubmitting = false;
                            });

                            if (!dialogContext.mounted) return;

                            ScaffoldMessenger.of(dialogContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Unable to submit review: $error',
                                ),
                              ),
                            );
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(existingReview == null ? 'Submit' : 'Update'),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    reviewController.dispose();
  }

  Future<void> _deleteReview(
    BuildContext context,
    WidgetRef ref,
    String reviewId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Review?'),
        content: const Text('Are you sure you want to delete your review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(reviewRepositoryProvider).deleteReview(reviewId);

      ref.invalidate(productReviewsProvider(productId));
      ref.invalidate(myProductReviewProvider(productId));
      ref.invalidate(productRatingSummaryProvider(productId));

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete review: $error')),
      );
    }
  }
}

class _ReviewTile extends StatelessWidget {
  final ProductReviewEntity review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd MMM yyyy').format(review.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    review.title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                if (review.isVerifiedPurchase)
                  const Chip(
                    avatar: Icon(Icons.verified, size: 16),
                    label: Text('Verified Purchase'),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 18,
                  ),
                ),
                const Spacer(),
                Text(date, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            const SizedBox(height: 10),
            Text(review.review),
          ],
        ),
      ),
    );
  }
}
