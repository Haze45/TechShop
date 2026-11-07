import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/address_entity.dart';
import '../providers/address_providers.dart';
import '../viewmodels/address_viewmodel.dart';
import '../widgets/address_form.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  Future<void> _deleteAddress(
    BuildContext context,
    WidgetRef ref,
    AddressEntity address,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref
          .read(addressViewModelProvider.notifier)
          .deleteAddress(address.id);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Address deleted successfully.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to delete address: $error')),
      );
    }
  }

  void _showAddressDialog(BuildContext context, {AddressEntity? address}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(address == null ? 'Add New Address' : 'Edit Address'),
        content: SizedBox(width: 450, child: AddressForm(address: address)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Addresses')),
      body: addressState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Unable to load addresses: $error'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(addressesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (addresses) {
          if (addresses.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_off_outlined, size: 64),
                  SizedBox(height: 12),
                  Text('No saved addresses yet.'),
                  SizedBox(height: 6),
                  Text('Add an address for faster checkout.'),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(addressesProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = addresses[index];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              address.addressType == 'home'
                                  ? Icons.home_outlined
                                  : address.addressType == 'work'
                                  ? Icons.work_outline
                                  : Icons.location_on_outlined,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              address.addressType.toUpperCase(),
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const Spacer(),
                            if (address.isDefault)
                              const Chip(label: Text('Default')),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          address.fullName,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(address.phone),
                        const SizedBox(height: 8),
                        Text(address.addressLine1),
                        if (address.addressLine2 != null &&
                            address.addressLine2!.isNotEmpty)
                          Text(address.addressLine2!),
                        Text(
                          '${address.city}, ${address.state} ${address.postalCode}',
                        ),
                        Text(address.country),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: () =>
                                  _showAddressDialog(context, address: address),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit'),
                            ),
                            TextButton.icon(
                              onPressed: () =>
                                  _deleteAddress(context, ref, address),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                        if (!address.isDefault) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                try {
                                  await ref
                                      .read(addressViewModelProvider.notifier)
                                      .setDefaultAddress(address.id);

                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Default address updated successfully.',
                                      ),
                                    ),
                                  );
                                } catch (error) {
                                  if (!context.mounted) return;

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Unable to set default address: $error',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Set as Default'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Address'),
      ),
    );
  }
}
