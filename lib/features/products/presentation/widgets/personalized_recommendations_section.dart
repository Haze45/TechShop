import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../wishlist/presentation/viewmodels/wishlist_state.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import '../providers/recommendation_providers.dart';
import 'product_card.dart';

class PersonalizedRecommendationsSection extends ConsumerWidget {
  const PersonalizedRecommendationsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(personalizedRecommendationsProvider);

    final wishlistAsync = ref.watch(wishlistViewModelProvider);
    final WishlistState? wishlistState = wishlistAsync.value;

    return recommendationsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) {
        debugPrint('Recommendation loading failed: $error');
        // Guests or customers without access won't see a broken section.
        return const SizedBox.shrink();
      },
      data: (products) {
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommended Products',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Discover products you might like',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 285,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return SizedBox(
                    width: 180,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ProductCard(
                        product: product,
                        isWishlisted:
                            wishlistState?.containsProduct(product.id) ?? false,
                        onTap: () {
                          context.push('/product/${product.id}');
                        },
                        onWishlistTap: () async {
                          try {
                            final isAlreadyWishlisted =
                                ref
                                    .read(wishlistViewModelProvider)
                                    .value
                                    ?.containsProduct(product.id) ??
                                false;

                            if (isAlreadyWishlisted) {
                              await ref
                                  .read(wishlistViewModelProvider.notifier)
                                  .removeFromWishlist(product.id);
                            } else {
                              await ref
                                  .read(wishlistViewModelProvider.notifier)
                                  .addToWishlist(product.id);
                            }

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isAlreadyWishlisted
                                      ? 'Removed from wishlist'
                                      : 'Added to wishlist',
                                ),
                              ),
                            );
                          } catch (error) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please log in to manage your wishlist.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
