import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/support_ticket_entity.dart';
import '../providers/support_providers.dart';

class SupportTicketDetailsScreen extends ConsumerStatefulWidget {
  final String ticketId;

  const SupportTicketDetailsScreen({super.key, required this.ticketId});

  @override
  ConsumerState<SupportTicketDetailsScreen> createState() =>
      _SupportTicketDetailsScreenState();
}

class _SupportTicketDetailsScreenState
    extends ConsumerState<SupportTicketDetailsScreen> {
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();

    if (message.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      await ref
          .read(supportRepositoryProvider)
          .sendMessage(ticketId: widget.ticketId, message: message);

      _messageController.clear();

      ref.invalidate(supportTicketByIdProvider(widget.ticketId));
      ref.invalidate(mySupportTicketsProvider);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to send message: $error')));
    } finally {
      if (mounted) {
        setState(() => _sending = false);
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
      appBar: AppBar(title: const Text('Support Conversation')),
      body: ticketAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Unable to load ticket: $error')),
        data: (ticket) {
          final canReply =
              ticket.status != 'resolved' && ticket.status != 'closed';

          return Column(
            children: [
              _TicketHeader(ticket: ticket),

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
                        child: Text('No messages yet. Start the conversation.'),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final item = messages[index];

                        return Align(
                          alignment: item.isAdminReply
                              ? Alignment.centerLeft
                              : Alignment.centerRight,
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
                                        .surfaceContainerHighest
                                  : Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.isAdminReply
                                      ? 'TechShop Support'
                                      : 'You',
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
                              hintText: 'Write a message...',
                              border: OutlineInputBorder(),
                              counterText: '',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _sending ? null : _sendMessage,
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
                  child: Text('This ticket is closed for replies.'),
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

class _TicketHeader extends StatelessWidget {
  final SupportTicketEntity ticket;

  const _TicketHeader({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(ticket.subject, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(ticket.description),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(ticket.status.toUpperCase())),
              Chip(label: Text(ticket.priority.toUpperCase())),
              Chip(label: Text(ticket.category.replaceAll('_', ' '))),
            ],
          ),
        ],
      ),
    );
  }
}
