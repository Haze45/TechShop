
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/wishlist_model.dart';

class WishlistRemoteDataSource {
  final SupabaseClient supabase;

  WishlistRemoteDataSource(this.supabase);

  // =========================================
  // 1. GET OR CREATE WISHLIST
  // =========================================

  Future<String> getOrCreateWishlist(String userId) async {
    final existingWishlist = await supabase
        .from('wishlists')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (existingWishlist != null) {
      return existingWishlist['id'].toString();
    }

    final newWishlist = await supabase
        .from('wishlists')
        .insert({
      'user_id': userId,
    })
        .select('id')
        .single();

    return newWishlist['id'].toString();
  }

  // =========================================
  // 2. GET WISHLIST WITH PRODUCTS
  // =========================================

  Future<WishlistModel?> getWishlist(String userId) async {
    final wishlistId = await getOrCreateWishlist(userId);

    final response = await supabase
        .from('wishlists')
        .select('''
          *,
          wishlist_items(
            *,
            products!inner(
              *,
              product_images(*)
            )
          )
        ''')
        .eq('id', wishlistId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return WishlistModel.fromJson(response);
  }

  // =========================================
  // 3. ADD PRODUCT TO WISHLIST
  // =========================================

  Future<void> addToWishlist({
    required String wishlistId,
    required String productId,
  }) async {
    await supabase
        .from('wishlist_items')
        .upsert(
      {
        'wishlist_id': wishlistId,
        'product_id': productId,
      },
      onConflict: 'wishlist_id,product_id',
      ignoreDuplicates: true,
    );
  }

  // =========================================
  // 4. REMOVE PRODUCT FROM WISHLIST
  // =========================================

  Future<void> removeFromWishlist({
    required String wishlistId,
    required String productId,
  }) async {
    await supabase
        .from('wishlist_items')
        .delete()
        .eq('wishlist_id', wishlistId)
        .eq('product_id', productId);
  }

  // =========================================
  // 5. CLEAR WISHLIST
  // =========================================

  Future<void> clearWishlist(String wishlistId) async {
    await supabase
        .from('wishlist_items')
        .delete()
        .eq('wishlist_id', wishlistId);
  }
}
