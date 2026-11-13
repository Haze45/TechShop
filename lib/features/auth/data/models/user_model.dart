import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.fullName,
    super.phone,
    super.avatarUrl,
    super.createdAt,
    super.emailConfirmedAt,
  });

  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};

    return UserModel(
      id: user.id,
      email: user.email,
      fullName: metadata['full_name'] as String?,
      phone: user.phone ?? metadata['phone'] as String?,
      avatarUrl: metadata['avatar_url'] as String?,
      createdAt: DateTime.tryParse(user.createdAt),
      emailConfirmedAt: user.emailConfirmedAt == null
          ? null
          : DateTime.tryParse(user.emailConfirmedAt!),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      emailConfirmedAt: emailConfirmedAt,
    );
  }
}
