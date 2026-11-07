import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/address_remote_datasource.dart';
import '../../data/repositories/address_repository_impl.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/repositories/address_repository.dart';

// Supabase DataSource
final addressRemoteDataSourceProvider = Provider<AddressRemoteDataSource>((
  ref,
) {
  return AddressRemoteDataSource(Supabase.instance.client);
});

// Address Repository
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  return AddressRepositoryImpl(ref.watch(addressRemoteDataSourceProvider));
});

// Fetch all customer addresses
final addressesProvider = FutureProvider<List<AddressEntity>>((ref) {
  return ref.watch(addressRepositoryProvider).getAddresses();
});
