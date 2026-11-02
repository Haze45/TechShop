import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cart_model.dart';

class CartRemoteDataSource {
  final SupabaseClient supabase;

  CartRemoteDataSource(this.supabase);

  Future<String> getOrCreateCart(String userId) async {
    // Check whether the user already has a cart.
    final existingCart = await supabase
        .from('carts')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    if (existingCart != null) {
      return existingCart['id'] as String;
    }

    // Create a new cart if one does not exist.
    final newCart = await supabase
        .from('carts')
        .insert({
      'user_id': userId,
    })
        .select('id')
        .single();

    return newCart['id'] as String;
  }

  Future<CartModel?> getCart(String userId) async {
    final cartId = await getOrCreateCart(userId);

    final response = await supabase
        .from('carts')
        .select('''
        *,
        cart_items(
          *,
          products(
            *,
            product_images(*)
          )
        )
      ''')
        .eq('id', cartId)
        .maybeSingle();

    if (response == null) {
      return null;
    }

    return CartModel.fromJson(response);
  }

  Future<void> addToCart({
    required String cartId,
    required String productId,
    int quantity = 1,
  }) async {
    final existingItem = await supabase
        .from('cart_items')
        .select('id, quantity')
        .eq('cart_id', cartId)
        .eq('product_id', productId)
        .maybeSingle();

    if (existingItem != null) {
      final currentQuantity = (existingItem['quantity'] as num).toInt();

      await supabase
          .from('cart_items')
          .update({
        'quantity': currentQuantity + quantity,
        'updated_at': DateTime.now().toIso8601String(),
      })
          .eq('id', existingItem['id']);
    } else {
      await supabase.from('cart_items').insert({
        'cart_id': cartId,
        'product_id': productId,
        'quantity': quantity,
      });
    }
  }

  Future<void> updateCartItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    if (quantity <= 0) {
      throw ArgumentError('Quantity must be greater than zero.');
    }

    await supabase
        .from('cart_items')
        .update({
      'quantity': quantity,
      'updated_at': DateTime.now().toIso8601String(),
    })
        .eq('id', itemId);
  }

  Future<void> removeCartItem(String itemId) async {
    await supabase
        .from('cart_items')
        .delete()
        .eq('id', itemId);
  }

  Future<void> clearCart(String cartId) async {
    await supabase
        .from('cart_items')
        .delete()
        .eq('cart_id', cartId);
  }
}