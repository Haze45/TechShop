import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/admin_remote_datasource.dart';
import '../../data/repositories/admin_repository_impl.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../domain/usecases/check_admin_role.dart';

final adminRemoteDataSourceProvider = Provider<AdminRemoteDataSource>((ref) {
  return AdminRemoteDataSource(Supabase.instance.client);
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.watch(adminRemoteDataSourceProvider));
});

final checkAdminRoleProvider = Provider<CheckAdminRole>((ref) {
  return CheckAdminRole(ref.watch(adminRepositoryProvider));
});

final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = Supabase.instance.client.auth.currentUser;

  if (user == null) return false;

  return ref.watch(checkAdminRoleProvider).call();
});
