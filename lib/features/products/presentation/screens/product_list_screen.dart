import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../comparison/presentation/widgets/comparison_button.dart';
import '../../../recently_viewed/presentation/widgets/recently_viewed_section.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_state.dart';
import '../../../wishlist/presentation/viewmodels/wishlist_viewmodel.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import '../providers/recent_search_provider.dart';
import '../viewmodels/product_state.dart';
import '../widgets/product_card.dart';
import '../widgets/promotional_banner_carousel.dart';
import '../widgets/search_suggestions.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey _allProductsKey = GlobalKey();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    await ref.read(productViewModelProvider.notifier).searchProducts(query);
  }

  Future<void> _submitSearch(String query) async {
    final value = query.trim();

    if (value.isEmpty) {
      await _clearSearch();
      return;
    }

    _debounce?.cancel();

    ref.read(recentSearchProvider.notifier).addSearch(value);

    await _search(value);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _search(query);
    });
  }

  Future<void> _clearSearch() async {
    _debounce?.cancel();
    _searchController.clear();

    await ref.read(productViewModelProvider.notifier).clearFilters();
  }

  Future<void> _refresh() async {
    await ref.read(productViewModelProvider.notifier).loadProducts();
  }

  void _scrollToAllProducts() {
    final targetContext = _allProductsKey.currentContext;

    if (targetContext == null) return;

    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productViewModelProvider);
    final cartAsync = ref.watch(cartViewModelProvider);
    final cartItemCount = cartAsync.value?.totalItems ?? 0;
    final wishlistAsync = ref.watch(wishlistViewModelProvider);
    final wishlistState = wishlistAsync.value;
    final wishlistItemCount = wishlistState?.totalItems ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TechShop',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.push('/profile');
            },
            icon: const Icon(Icons.person_outline),
          ),
          IconButton(
            onPressed: () {
              context.push('/cart');
            },
            icon: Badge(
              isLabelVisible: cartItemCount > 0,
              label: Text('$cartItemCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            tooltip: 'My Cart',
          ),
          IconButton(
            onPressed: () => context.push('/wishlist'),
            tooltip: 'My Wishlist',
            icon: Badge(
              isLabelVisible: wishlistItemCount > 0,
              label: Text('$wishlistItemCount'),
              child: const Icon(Icons.favorite_border),
            ),
          ),
          IconButton(
            tooltip: 'My Orders',
            onPressed: () => context.push('/orders'),
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          ComparisonButton(),
        ],
      ),

      body: productAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 12),
                const Text(
                  'Unable to load products',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),

        data: (productState) {
          return _buildProductContent(productState, wishlistState);
        },
      ),
    );
  }

  Widget _buildProductContent(
    ProductState productState,
    WishlistState? wishlistState,
  ) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: _onSearchChanged,
                onSubmitted: _submitSearch,
                decoration: InputDecoration(
                  hintText: 'Search smartphones and laptops',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SearchSuggestions(
                onSearchSelected: (query) {
                  _searchController.text = query;
                  _submitSearch(query);
                },
              ),
            ),
          ),

          // Promotional Banner Carousel
          const SliverToBoxAdapter(child: PromotionalBannerCarousel()),

          // Categories
          SliverToBoxAdapter(child: _buildCategories(productState)),

          // Brand Filters
          SliverToBoxAdapter(child: _buildBrandFilters(productState)),

          // Product Sorting
          SliverToBoxAdapter(child: _buildSortDropdown(productState)),

          // Featured products
          if (productState.searchQuery.isEmpty &&
              productState.selectedCategoryId == null &&
              productState.selectedBrandId == null &&
              productState.featuredProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildFeaturedProducts(
                productState.featuredProducts,
                wishlistState,
              ),
            ),

          // Recently Added Products
          if (productState.searchQuery.isEmpty &&
              productState.selectedCategoryId == null &&
              productState.selectedBrandId == null &&
              productState.products.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildRecentlyAddedProducts(
                productState.products,
                wishlistState,
                productState.featuredProducts,
              ),
            ),

          // Recently Viewed Products
          if (productState.searchQuery.isEmpty &&
              productState.selectedCategoryId == null &&
              productState.selectedBrandId == null)
            const SliverToBoxAdapter(child: RecentlyViewedSection()),

          // Product section heading
          SliverToBoxAdapter(
            key: _allProductsKey,
            child: _buildProductSectionHeader(productState),
          ),

          // Product grid
          if (productState.products.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        productState.searchQuery.isNotEmpty
                            ? Icons.search_off
                            : Icons.inventory_2_outlined,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        productState.searchQuery.isNotEmpty
                            ? 'No products found'
                            : 'No products available',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        productState.searchQuery.isNotEmpty
                            ? 'Try another product name, brand or SKU.'
                            : 'There are currently no products to display.',
                        textAlign: TextAlign.center,
                      ),
                      if (productState.searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _clearSearch,
                          child: const Text('Clear Search'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = productState.products[index];

                  return ProductCard(
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
                  );
                }, childCount: productState.products.length),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.58,
                ),
              ),
            ),

          // Pagination
          if (productState.hasMore && productState.searchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ElevatedButton(
                    onPressed: productState.isLoadingMore
                        ? null
                        : () {
                            ref
                                .read(productViewModelProvider.notifier)
                                .loadMoreProducts();
                          },
                    child: productState.isLoadingMore
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Load More'),
                  ),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildProductSectionHeader(ProductState state) {
    String title;

    if (state.searchQuery.isNotEmpty) {
      title = 'Search Results';
    } else if (state.selectedCategoryId != null ||
        state.selectedBrandId != null) {
      title = 'Filtered Products';
    } else {
      title = 'All Products';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore our latest smartphones and laptops',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary
                  .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${state.products.length} Loaded',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories(ProductState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Shop by Category',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),

        SizedBox(
          height: 125,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildCategoryCard(
                name: 'All Products',
                icon: Icons.devices_other,
                color: const Color(0xFF1565C0),
                isSelected: state.selectedCategoryId == null,
                onTap: () {
                  _searchController.clear();
                  ref.read(productViewModelProvider.notifier).clearFilters();
                },
              ),

              ...state.categories.map((category) {
                final id = (category['id'] as num).toInt();
                final name = category['name'] as String? ?? 'Category';

                final isSmartphone = name.toLowerCase().contains('smartphone');

                return _buildCategoryCard(
                  name: name,
                  icon: isSmartphone ? Icons.smartphone : Icons.laptop_mac,
                  color: isSmartphone
                      ? const Color(0xFF00897B)
                      : const Color(0xFF6A1B9A),
                  isSelected: state.selectedCategoryId == id,
                  onTap: () {
                    _searchController.clear();

                    ref
                        .read(productViewModelProvider.notifier)
                        .filterByCategory(id);
                  },
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard({
    required String name,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 115,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isSelected ? 0.20 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.20),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 38, color: color),
            const SizedBox(height: 10),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandFilters(ProductState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Shop by Brand',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${state.brands.length} Brands',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildBrandChip(
                label: 'All Brands',
                selected: state.selectedBrandId == null,
                onTap: () {
                  ref
                      .read(productViewModelProvider.notifier)
                      .filterByBrand(null);
                },
              ),
              const SizedBox(width: 8),
              ...state.brands.map((brand) {
                final brandId = (brand['id'] as num).toInt();
                final brandName = brand['name'] as String;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildBrandChip(
                    label: brandName,
                    selected: state.selectedBrandId == brandId,
                    onTap: () {
                      ref
                          .read(productViewModelProvider.notifier)
                          .filterByBrand(brandId);
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBrandChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surface,
      side: BorderSide(
        color: selected ? colorScheme.primary : colorScheme.outlineVariant,
      ),
      labelStyle: TextStyle(
        color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildRecentlyAddedProducts(
    List<ProductEntity> products,
    WishlistState? wishlistState,
    List<ProductEntity> featuredProducts,
  ) {
    final featuredIds = featuredProducts.map((p) => p.id).toSet();

    final recentProducts =
        products.where((product) => !featuredIds.contains(product.id)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final latestProducts = recentProducts.take(10).toList();

    if (latestProducts.isEmpty) {
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
                      'Recently Added',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Discover our newest devices',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _scrollToAllProducts,
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 285,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: latestProducts.length,
            itemBuilder: (context, index) {
              final product = latestProducts[index];

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
  }

  Widget _buildFeaturedProducts(
    List<ProductEntity> products,
    WishlistState? wishlistState,
  ) {
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
                      'Featured Products',
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Handpicked devices for you',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${products.length} Products',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
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
              return SizedBox(
                width: 180,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ProductCard(
                    product: products[index],

                    isWishlisted:
                        wishlistState?.containsProduct(products[index].id) ??
                        false,

                    onTap: () {
                      context.push('/product/${products[index].id}');
                    },

                    onWishlistTap: () async {
                      final productId = products[index].id;

                      try {
                        final isAlreadyWishlisted =
                            ref
                                .read(wishlistViewModelProvider)
                                .value
                                ?.containsProduct(productId) ??
                            false;

                        if (isAlreadyWishlisted) {
                          await ref
                              .read(wishlistViewModelProvider.notifier)
                              .removeFromWishlist(productId);
                        } else {
                          await ref
                              .read(wishlistViewModelProvider.notifier)
                              .addToWishlist(productId);
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
  }

  Widget _buildSortDropdown(ProductState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text('Sort by:', style: TextStyle(fontWeight: FontWeight.w600)),

          const SizedBox(width: 12),

          DropdownButton<ProductSortOption>(
            value: state.sortOption,
            underline: const SizedBox(),
            borderRadius: BorderRadius.circular(12),

            items: const [
              DropdownMenuItem(
                value: ProductSortOption.newest,
                child: Text('Newest First'),
              ),
              DropdownMenuItem(
                value: ProductSortOption.priceLowToHigh,
                child: Text('Price: Low to High'),
              ),
              DropdownMenuItem(
                value: ProductSortOption.priceHighToLow,
                child: Text('Price: High to Low'),
              ),
              DropdownMenuItem(
                value: ProductSortOption.nameAscending,
                child: Text('Name: A to Z'),
              ),
            ],

            onChanged: (option) {
              if (option != null) {
                ref
                    .read(productViewModelProvider.notifier)
                    .sortProducts(option);
              }
            },
          ),
        ],
      ),
    );
  }
}
