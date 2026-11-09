import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/supabase_provider.dart';

import '../../data/datasources/support_remote_datasource.dart';
import '../../data/repositories/support_repository_impl.dart';
import '../../domain/entities/support_message_entity.dart';
import '../../domain/repositories/support_repository.dart';
import '../../domain/entities/support_ticket_entity.dart';

// Remote Data Source
final supportRemoteDataSourceProvider = Provider<SupportRemoteDataSource>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);

  return SupportRemoteDataSource(supabase);
});

// Repository
final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final remoteDataSource = ref.watch(supportRemoteDataSourceProvider);

  return SupportRepositoryImpl(remoteDataSource);
});

// Fetch customer tickets
final mySupportTicketsProvider = FutureProvider<List<SupportTicketEntity>>((
  ref,
) {
  return ref.watch(supportRepositoryProvider).getMyTickets();
});

// Fetch individual ticket
final supportTicketByIdProvider =
    FutureProvider.family<SupportTicketEntity, String>((ref, ticketId) {
      return ref.watch(supportRepositoryProvider).getTicketById(ticketId);
    });

final ticketMessagesProvider = FutureProvider.autoDispose
    .family<List<SupportMessageEntity>, String>((ref, ticketId) {
      return ref.read(supportRepositoryProvider).getTicketMessages(ticketId);
    });

final adminSupportTicketsProvider =
    FutureProvider.autoDispose<List<SupportTicketEntity>>((ref) {
      return ref.read(supportRepositoryProvider).getAllSupportTickets();
    });

final ticketMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<SupportMessageEntity>, String>((ref, ticketId) {
      return ref.read(supportRepositoryProvider).watchTicketMessages(ticketId);
    });
