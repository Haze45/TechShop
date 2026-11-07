import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/address_model.dart';

class AddressRemoteDataSource {
  final SupabaseClient supabase;

  AddressRemoteDataSource(this.supabase);

  // Get all addresses of the logged-in user.
  Future<List<AddressModel>> getAddresses() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final response = await supabase
        .from('user_addresses')
        .select()
        .eq('user_id', userId)
        .order('is_default', ascending: false)
        .order('created_at', ascending: false);

    return response.map<AddressModel>((json) {
      return AddressModel.fromJson(Map<String, dynamic>.from(json));
    }).toList();
  }

  // Add a new address.
  Future<AddressModel> addAddress({
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String addressType,
  }) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    final response = await supabase
        .from('user_addresses')
        .insert({
          'user_id': userId,
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'address_line1': addressLine1.trim(),
          'address_line2': addressLine2?.trim().isEmpty == true
              ? null
              : addressLine2?.trim(),
          'city': city.trim(),
          'state': state.trim(),
          'postal_code': postalCode.trim(),
          'country': country.trim(),
          'address_type': addressType,
          'is_default': false,
        })
        .select()
        .single();

    return AddressModel.fromJson(Map<String, dynamic>.from(response));
  }

  // Update an existing address.
  Future<void> updateAddress({
    required String addressId,
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String addressType,
  }) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    await supabase
        .from('user_addresses')
        .update({
          'full_name': fullName.trim(),
          'phone': phone.trim(),
          'address_line1': addressLine1.trim(),
          'address_line2': addressLine2?.trim().isEmpty == true
              ? null
              : addressLine2?.trim(),
          'city': city.trim(),
          'state': state.trim(),
          'postal_code': postalCode.trim(),
          'country': country.trim(),
          'address_type': addressType,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', addressId)
        .eq('user_id', userId);
  }

  // Delete an address.
  Future<void> deleteAddress(String addressId) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    await supabase
        .from('user_addresses')
        .delete()
        .eq('id', addressId)
        .eq('user_id', userId);
  }

  // Set an address as the default address.
  Future<void> setDefaultAddress(String addressId) async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      throw Exception('User is not logged in.');
    }

    await supabase.rpc(
      'set_default_address',
      params: {'p_address_id': addressId},
    );
  }
}
