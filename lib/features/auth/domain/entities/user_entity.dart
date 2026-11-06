class UserEntity {
  final String id;
  final String? email;
  final String? fullName;
  final String? phone;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    this.email,
    this.fullName,
    this.phone,
    this.avatarUrl,
  });
}
