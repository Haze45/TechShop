import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/support_ticket_entity.dart';
import '../providers/support_providers.dart';

class AdminSupportTicketDetailsScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const AdminSupportTicketDetailsScreen({super.key, required this.ticketId});

  @override
  ConsumerState<AdminSupportTicketDetailsScreen> createState() =>
      _AdminSupportTicketDetailsScreenState();
}

class _AdminSupportTicketDetailsScreenState
    extends ConsumerState<AdminSupportTicketDetailsScreen> {
  final _messageController = TextEditingController();

  bool _sending = false;
  bool _updatingStatus = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendReply() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      await ref
          .read(supportRepositoryProvider)
          .sendMessage(ticketId: widget.ticketId, message: message);

      _messageController.clear();

      ref.invalidate(supportTicketByIdProvider(widget.ticketId));
      ref.invalidate(adminSupportTicketsProvider);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send reply: $error')));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    setState(() => _updatingStatus = true);

    try {
      await ref
          .read(supportRepositoryProvider)
          .updateTicketStatus(ticketId: widget.ticketId, status: status);

      ref.invalidate(supportTicketByIdProvider(widget.ticketId));
      ref.invalidate(adminSupportTicketsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket status updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update status: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _updatingStatus = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticketAsync = ref.watch(supportTicketByIdProvider(widget.ticketId));

    final messagesAsync = ref.watch(
      ticketMessagesStreamProvider(widget.ticketId),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Ticket Details')),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Unable to load ticket: $error')),
        data: (ticket) {
          final canReply =
              ticket.status != 'resolved' && ticket.status != 'closed';

          return Column(
            children: [
              _AdminTicketHeader(
                ticket: ticket,
                updating: _updatingStatus,
                onStatusChanged: _updateStatus,
              ),

              const Divider(height: 1),

              Expanded(
                child: messagesAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stackTrace) =>
                      Center(child: Text('Unable to load messages: $error')),
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const Center(
                        child: Text('No messages in this conversation.'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final item = messages[index];

                        return Align(
                          alignment: item.isAdminReply
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.isAdminReply
                                  ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                  : Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.isAdminReply
                                      ? 'TechShop Support (You)'
                                      : 'Customer',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                                const SizedBox(height: 6),
                                Text(item.message),
                                const SizedBox(height: 6),
                                Text(
                                  _formatDate(item.createdAt),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              if (canReply)
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            minLines: 1,
                            maxLines: 4,
                            maxLength: 5000,
                            decoration: const InputDecoration(
                              hintText: 'Reply to customer...',
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _sending ? null : _sendReply,
                          icon: _sending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'This ticket is resolved or closed. Change its status to reopen replies.',
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();

    return '${local.day.toString().padLeft(2, '0')}/'
        '${local.month.toString().padLeft(2, '0')}/'
        '${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:'
        '${local.minute.toString().padLeft(2, '0')}';
  }
}

class _AdminTicketHeader extends StatelessWidget {
  final SupportTicketEntity ticket;
  final bool updating;
  final ValueChanged<String> onStatusChanged;

  const _AdminTicketHeader({
    required this.ticket,
    required this.updating,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ticket.subject, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(ticket.description),
          const SizedBox(height: 8),
          Text('Customer ID: ${ticket.userId}'),
          Text('Category: ${ticket.category.replaceAll('_', ' ')}'),
          Text('Priority: ${ticket.priority.toUpperCase()}'),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: ticket.status,
            decoration: const InputDecoration(
              labelText: 'Ticket Status',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'open', child: Text('Open')),
              DropdownMenuItem(
                value: 'in_progress',
                child: Text('In Progress'),
              ),
              DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
              DropdownMenuItem(value: 'closed', child: Text('Closed')),
            ],
            onChanged: updating
                ? null
                : (value) {
                    if (value != null && value != ticket.status) {
                      onStatusChanged(value);
                    }
                  },
          ),
          if (updating) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
