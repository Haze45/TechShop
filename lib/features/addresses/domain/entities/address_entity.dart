class AddressEntity {
  final String id;
  final String userId;

  final String fullName;
  final String phone;

  final String addressLine1;
  final String? addressLine2;

  final String city;
  final String state;
  final String postalCode;
  final String country;

  final String addressType;
  final bool isDefault;

  final DateTime createdAt;
  final DateTime updatedAt;

  const AddressEntity({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    required this.addressType,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });
}
