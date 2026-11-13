class UserEntity {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? emailConfirmedAt;

  const UserEntity({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
    this.createdAt,
    this.emailConfirmedAt,
  });

  bool get isEmailVerified => emailConfirmedAt != null;
}
