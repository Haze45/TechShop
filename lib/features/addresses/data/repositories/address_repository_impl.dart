import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_datasource.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;

  AddressRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<AddressEntity>> getAddresses() {
    return remoteDataSource.getAddresses();
  }

  @override
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
  }) {
    return remoteDataSource.addAddress(
      fullName: fullName,
      phone: phone,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      addressType: addressType,
    );
  }

  @override
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
  }) {
    return remoteDataSource.updateAddress(
      addressId: addressId,
      fullName: fullName,
      phone: phone,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      addressType: addressType,
    );
  }

  @override
  Future<void> deleteAddress(String addressId) {
    return remoteDataSource.deleteAddress(addressId);
  }
}
