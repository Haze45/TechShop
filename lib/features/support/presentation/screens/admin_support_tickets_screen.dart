import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/support_providers.dart';

class AdminSupportTicketsScreen extends ConsumerStatefulWidget {
  const AdminSupportTicketsScreen({super.key});

  @override
  ConsumerState<AdminSupportTicketsScreen> createState() =>
      _AdminSupportTicketsScreenState();
}

class _AdminSupportTicketsScreenState
    extends ConsumerState<AdminSupportTicketsScreen> {
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedStatus = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(adminSupportTicketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Tickets'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(adminSupportTicketsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Unable to load tickets: $error')),
        data: (tickets) {
          final filteredTickets = tickets.where((ticket) {
            final query = _searchQuery.toLowerCase();

            final matchesSearch =
                ticket.subject.toLowerCase().contains(query) ||
                ticket.userId.toLowerCase().contains(query) ||
                ticket.id.toLowerCase().contains(query);

            final matchesStatus =
                _selectedStatus == 'all' || ticket.status == _selectedStatus;

            return matchesSearch && matchesStatus;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search tickets...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                          icon: const Icon(Icons.clear),
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value.trim());
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Filter by status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'all',
                          child: Text('All Tickets'),
                        ),
                        DropdownMenuItem(value: 'open', child: Text('Open')),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(
                          value: 'resolved',
                          child: Text('Resolved'),
                        ),
                        DropdownMenuItem(
                          value: 'closed',
                          child: Text('Closed'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: filteredTickets.isEmpty
                    ? const Center(child: Text('No support tickets found.'))
                    : RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(adminSupportTicketsProvider);
                          await ref.read(adminSupportTicketsProvider.future);
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredTickets.length,
                          itemBuilder: (context, index) {
                            final ticket = filteredTickets[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                title: Text(
                                  ticket.subject,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Customer: ${ticket.userId}'),
                                      Text(
                                        'Category: ${ticket.category.replaceAll('_', ' ')}',
                                      ),
                                      Text(
                                        'Priority: ${ticket.priority.toUpperCase()}',
                                      ),
                                      const SizedBox(height: 6),
                                      Chip(
                                        label: Text(
                                          ticket.status.toUpperCase(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () async {
                                  await context.push(
                                    '/admin/support/${ticket.id}',
                                  );

                                  ref.invalidate(adminSupportTicketsProvider);
                                },
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
