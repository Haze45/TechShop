
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product_model.dart';

class ProductRemoteDataSource {
  final SupabaseClient supabase;

  ProductRemoteDataSource(this.supabase);

  // Fetch all active products.
  Future<List<ProductModel>> getProducts({
    int page = 0,
    int limit = 10,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await supabase
        .from('products')
        .select('*, product_images(*)')
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .range(from, to);

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromJson(json),
    )
        .toList();
  }

  // Fetch featured products.
  Future<List<ProductModel>> getFeaturedProducts({
    int limit = 10,
  }) async {
    final response = await supabase
        .from('products')
        .select('*, product_images(*)')
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(limit);

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromJson(json),
    )
        .toList();
  }

  // Fetch a single product by ID.
  Future<ProductModel?> getProductById(String productId) async {
    final response = await supabase
        .from('products')
        .select('*, product_images(*)')
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
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await supabase
        .from('products')
        .select('*, product_images(*)')
        .eq('category_id', categoryId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .range(from, to);

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromJson(json),
    )
        .toList();
  }

  // Fetch products by brand.
  Future<List<ProductModel>> getProductsByBrand({
    required int brandId,
    int page = 0,
    int limit = 10,
  }) async {
    final from = page * limit;
    final to = from + limit - 1;

    final response = await supabase
        .from('products')
        .select('*, product_images(*)')
        .eq('brand_id', brandId)
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .range(from, to);

    return response
        .map<ProductModel>(
          (json) => ProductModel.fromJson(json),
    )
        .toList();
  }

  // Search products by name.
  Future<List<ProductModel>> searchProducts(String query) async {
    final searchQuery = query.trim();

    if (searchQuery.isEmpty) {
      return [];
    }

    final response = await supabase
        .from('products')
        .select('*, product_images(*)')
        .eq('is_active', true)
        .or(
      'name.ilike.%$searchQuery%,'
          'description.ilike.%$searchQuery%,'
          'sku.ilike.%$searchQuery%',
    )
        .order('created_at', ascending: false);

    return response
        .map<ProductModel>((json) => ProductModel.fromJson(json))
        .toList();
  }

  // Fetch categories.
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await supabase
        .from('categories')
        .select()
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }

  // Fetch brands.
  Future<List<Map<String, dynamic>>> getBrands() async {
    final response = await supabase
        .from('brands')
        .select()
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }
}
