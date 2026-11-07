import '../entities/address_entity.dart';

abstract class AddressRepository {
  Future<List<AddressEntity>> getAddresses();

  Future<AddressEntity> addAddress({
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String postalCode,
    required String country,
    required String addressType,
  });

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
  });

  Future<void> deleteAddress(String addressId);
  Future<void> setDefaultAddress(String addressId);
}
