import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/admin_review_providers.dart';

class AdminReviewsScreen extends ConsumerStatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  ConsumerState<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends ConsumerState<AdminReviewsScreen> {
  String selectedStatus = 'pending';

  Future<void> _updateStatus(String reviewId, String status) async {
    try {
      await ref
          .read(adminReviewRepositoryProvider)
          .updateReviewStatus(reviewId: reviewId, status: status);

      ref.invalidate(adminReviewsProvider(selectedStatus));

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'Review approved successfully.'
                : 'Review rejected successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update review: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(adminReviewsProvider(selectedStatus));

    return Scaffold(
      appBar: AppBar(title: const Text('Review Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'pending', label: Text('Pending')),
                ButtonSegment(value: 'approved', label: Text('Approved')),
                ButtonSegment(value: 'rejected', label: Text('Rejected')),
                ButtonSegment(value: 'all', label: Text('All')),
              ],
              selected: {selectedStatus},
              onSelectionChanged: (selection) {
                setState(() {
                  selectedStatus = selection.first;
                });
              },
            ),
          ),
          Expanded(
            child: reviewsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unable to load reviews.'),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(adminReviewsProvider(selectedStatus));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (reviews) {
                if (reviews.isEmpty) {
                  return const Center(child: Text('No reviews found.'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(adminReviewsProvider(selectedStatus));
                    await ref.read(adminReviewsProvider(selectedStatus).future);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reviews.length,
                    itemBuilder: (context, index) {
                      final review = reviews[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      review.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(review.status.toUpperCase()),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: List.generate(
                                  5,
                                  (starIndex) => Icon(
                                    starIndex < review.rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(review.review),
                              const SizedBox(height: 12),
                              Text(
                                'Product ID: ${review.productId}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'User ID: ${review.userId}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              Text(
                                'Submitted: ${DateFormat('dd MMM yyyy, hh:mm a').format(review.createdAt)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              if (review.isVerifiedPurchase)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                      SizedBox(width: 6),
                                      Text('Verified purchase'),
                                    ],
                                  ),
                                ),
                              if (review.status == 'pending') ...[
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () =>
                                          _updateStatus(review.id, 'approved'),
                                      icon: const Icon(Icons.check),
                                      label: const Text('Approve'),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          _updateStatus(review.id, 'rejected'),
                                      icon: const Icon(Icons.close),
                                      label: const Text('Reject'),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
