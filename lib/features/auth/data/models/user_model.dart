import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    super.email,
    super.fullName,
    super.phone,
    super.avatarUrl,
  });

  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? {};

    return UserModel(
      id: user.id,
      email: user.email,
      fullName: metadata['full_name'] as String?,
      phone: user.phone ?? metadata['phone'] as String?,
      avatarUrl: metadata['avatar_url'] as String?,
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
    );
  }
}