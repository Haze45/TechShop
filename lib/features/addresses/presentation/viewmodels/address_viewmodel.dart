import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/address_providers.dart';

class AddressViewModel extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Add address
  Future<void> addAddress({
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String stateName,
    required String postalCode,
    required String country,
    required String addressType,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(addressRepositoryProvider).addAddress(
        fullName: fullName,
        phone: phone,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: stateName,
        postalCode: postalCode,
        country: country,
        addressType: addressType,
      );

      ref.invalidate(addressesProvider);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // Update address
  Future<void> updateAddress({
    required String addressId,
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String stateName,
    required String postalCode,
    required String country,
    required String addressType,
  }) async {
    state = const AsyncLoading();

    try {
      await ref.read(addressRepositoryProvider).updateAddress(
        addressId: addressId,
        fullName: fullName,
        phone: phone,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: stateName,
        postalCode: postalCode,
        country: country,
        addressType: addressType,
      );

      ref.invalidate(addressesProvider);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // Delete address
  Future<void> deleteAddress(String addressId) async {
    state = const AsyncLoading();

    try {
      await ref.read(addressRepositoryProvider).deleteAddress(addressId);

      ref.invalidate(addressesProvider);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  // Set default address.
  Future<void> setDefaultAddress(String addressId) async {
    state = const AsyncLoading();

    try {
      await ref
          .read(addressRepositoryProvider)
          .setDefaultAddress(addressId);

      ref.invalidate(addressesProvider);

      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }
}

final addressViewModelProvider =
AsyncNotifierProvider<AddressViewModel, void>(
  AddressViewModel.new,
);