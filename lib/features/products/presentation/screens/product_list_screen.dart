import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';
import '../viewmodels/product_state.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
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

  void _onSearchChanged(String query) {
    _debounce?.cancel();

    _debounce = Timer(
      const Duration(milliseconds: 500),
          () {
        _search(query);
      },
    );
  }

  Future<void> _clearSearch() async {
    _debounce?.cancel();
    _searchController.clear();

    await ref
        .read(productViewModelProvider.notifier)
        .clearFilters();
  }

  Future<void> _refresh() async {
    await ref.read(productViewModelProvider.notifier).loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productViewModelProvider);

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
            icon: const Icon(Icons.shopping_cart_outlined),
            tooltip: 'My Cart',
          ),
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
          return _buildProductContent(productState);
        },
      ),
    );
  }

  Widget _buildProductContent(ProductState productState) {
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
                onSubmitted: (query) {
                  _debounce?.cancel();
                  _search(query);
                },
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

          // Categories
          SliverToBoxAdapter(child: _buildCategories(productState)),

          // Brand Filters
          SliverToBoxAdapter(
            child: _buildBrandFilters(productState),
          ),

          // Product Sorting
          SliverToBoxAdapter(
            child: _buildSortDropdown(productState),
          ),

          // Featured products
          if (productState.searchQuery.isEmpty &&
              productState.selectedCategoryId == null &&
              productState.selectedBrandId == null &&
              productState.featuredProducts.isNotEmpty)
            SliverToBoxAdapter(
              child: _buildFeaturedProducts(productState.featuredProducts),
            ),

          // Product section heading
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                productState.searchQuery.isNotEmpty
                    ? 'Search Results'
                    : 'All Products',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Product grid
          if (productState.products.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 55,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text('No products found'),
                  ],
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
                    onTap: () {
                      context.push('/product/${product.id}');
                    },
                  );
                }, childCount: productState.products.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.68,
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

  Widget _buildCategories(ProductState state) {
    return SizedBox(
      height: 55,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('All'),
              selected: state.selectedCategoryId == null,
              onSelected: (_) {
                _searchController.clear();

                ref.read(productViewModelProvider.notifier).clearFilters();
              },
            ),
          ),

          ...state.categories.map((category) {
            final id = (category['id'] as num).toInt();
            final name = category['name'] as String? ?? 'Category';

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(name),
                selected: state.selectedCategoryId == id,
                onSelected: (_) {
                  _searchController.clear();

                  ref
                      .read(productViewModelProvider.notifier)
                      .filterByCategory(id);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBrandFilters(ProductState state) {
    return SizedBox(
      height: 45,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          ChoiceChip(
            label: const Text('All Brands'),
            selected: state.selectedBrandId == null,
            onSelected: (_) {
              ref
                  .read(productViewModelProvider.notifier)
                  .filterByBrand(null);
            },
          ),

          const SizedBox(width: 8),

          ...state.brands.map((brand) {
            final brandId = (brand['id'] as num).toInt();

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(brand['name'] as String),
                selected: state.selectedBrandId == brandId,
                onSelected: (_) {
                  ref
                      .read(productViewModelProvider.notifier)
                      .filterByBrand(brandId);
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeaturedProducts(List<ProductEntity> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'Featured Products',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
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
                    onTap: () {
                      context.push('/product/${products[index].id}');
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
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const Text(
            'Sort by:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),

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
