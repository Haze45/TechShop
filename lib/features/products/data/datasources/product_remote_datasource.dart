import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class ProductRemoteDataSource {
  final SupabaseClient supabase;

  static const String _productSelect = '''
  id,
  category_id,
  brand_id,
  name,
  slug,
  sku,
  description,
  price,
  compare_at_price,
  stock_quantity,
  specifications,
  is_active,
  is_featured,
  created_at,
  updated_at,
  product_images (
    id,
    product_id,
    image_url,
    alt_text,
    display_order,
    is_primary
  )
''';

  ProductRemoteDataSource(this.supabase);

  // Fetch all active products.
  Future<List<ProductModel>> getProducts({
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _sortProducts(
      supabase.from('products').select(_productSelect).eq('is_active', true),
      sortOption,
    ).range(from, to);

    return response
        .map<ProductModel>((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Fetch featured products.
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    final response = await supabase
        .from('products')
        .select(_productSelect)
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return response
        .map<ProductModel>((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Fetch a single product by ID.
  Future<ProductModel?> getProductById(String productId) async {
    final response = await supabase
        .from('products')
        .select(_productSelect)
        .eq('id', productId)
        .eq('is_active', true)
        .maybeSingle();

    if (response == null) return null;

    return ProductModel.fromJson(response);
  }

  // Fetch products by category.
  Future<List<ProductModel>> getProductsByCategory({
    required int categoryId,
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _sortProducts(
      supabase
          .from('products')
          .select(_productSelect)
          .eq('category_id', categoryId)
          .eq('is_active', true),
      sortOption,
    ).range(from, to);

    return response
        .map<ProductModel>((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Fetch products by brand.
  Future<List<ProductModel>> getProductsByBrand({
    required int brandId,
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await _sortProducts(
      supabase
          .from('products')
          .select(_productSelect)
          .eq('brand_id', brandId)
          .eq('is_active', true),
      sortOption,
    ).range(from, to);

    return response
        .map<ProductModel>((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Search products.

  Future<List<ProductModel>> searchProducts(
    String query, {
    int page = 0,
    int limit = 10,
    String sortOption = 'newest',
  }) async {
    final searchQuery = query.trim();

    if (searchQuery.isEmpty) {
      return [];
    }

    // Get one page of matching product records.
    final response = await supabase.rpc(
      'search_products_paginated',
      params: {
        'p_query': searchQuery,
        'p_page': page,
        'p_limit': limit,
        'p_sort_option': sortOption,
      },
    );

    final productIds = (response as List)
        .map((item) => item['id'] as String)
        .toList();

    if (productIds.isEmpty) {
      return [];
    }

    // Fetch product records along with their images.
    final productsResponse = await supabase
        .from('products')
        .select(_productSelect)
        .inFilter('id', productIds);

    final productsById = <String, ProductModel>{};

    for (final json in productsResponse) {
      final product = ProductModel.fromJson(Map<String, dynamic>.from(json));

      productsById[product.id] = product;
    }

    // Maintain the order returned by the RPC.
    return productIds
        .map((id) => productsById[id])
        .whereType<ProductModel>()
        .toList();
  }

  // Fetch related products from the same category.
  Future<List<ProductModel>> getRelatedProducts({
    required int categoryId,
    required String excludeProductId,
    int limit = 10,
  }) async {
    final response = await supabase
        .from('products')
        .select(_productSelect)
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .neq('id', excludeProductId)
        .order('created_at', ascending: false)
        .limit(limit);

    return response
        .map<ProductModel>((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Fetch categories.
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await supabase
        .from('categories')
        .select('id, name')
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch brands.
  Future<List<Map<String, dynamic>>> getBrands() async {
    final response = await supabase
        .from('brands')
        .select('id, name')
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  // Apply sorting to a product query.
  dynamic _sortProducts(dynamic query, String sortOption) {
    switch (sortOption) {
      case 'priceLowToHigh':
        return query.order('price', ascending: true);

      case 'priceHighToLow':
        return query.order('price', ascending: false);

      case 'nameAscending':
        return query.order('name', ascending: true);

      case 'newest':
      default:
        return query.order('created_at', ascending: false);
    }
  }
}
