import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/support_providers.dart';

class CreateSupportTicketScreen extends ConsumerStatefulWidget {
  const CreateSupportTicketScreen({super.key});

  @override
  ConsumerState<CreateSupportTicketScreen> createState() =>
      _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState
    extends ConsumerState<CreateSupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();

  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'general';
  String _selectedPriority = 'normal';

  bool _isSubmitting = false;

  final Map<String, String> _categories = {
    'general': 'General Query',
    'order_issue': 'Order Issue',
    'payment_issue': 'Payment Issue',
    'product_issue': 'Product Issue',
    'delivery_issue': 'Delivery Issue',
    'refund': 'Refund',
  };

  final Map<String, String> _priorities = {
    'low': 'Low',
    'normal': 'Normal',
    'high': 'High',
  };

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(supportRepositoryProvider)
          .createTicket(
            subject: _subjectController.text.trim(),
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            priority: _selectedPriority,
          );

      ref.invalidate(mySupportTicketsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Support ticket created successfully.'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to create ticket: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Support Ticket')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How can we help you?',
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              Text(
                'Describe your issue and our support team will assist you.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // Subject
              TextFormField(
                controller: _subjectController,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Enter your issue subject',
                  prefixIcon: Icon(Icons.subject),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a subject.';
                  }

                  if (value.trim().length < 5) {
                    return 'Subject must contain at least 5 characters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 6,
                maxLength: 2000,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Explain your issue in detail...',
                  alignLabelWithHint: true,
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe your issue.';
                  }

                  if (value.trim().length < 10) {
                    return 'Description must contain at least 10 characters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Category
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _categories.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedCategory = value;
                        });
                      },
              ),

              const SizedBox(height: 16),

              // Priority
              DropdownButtonFormField<String>(
                initialValue: _selectedPriority,
                decoration: const InputDecoration(
                  labelText: 'Priority',
                  prefixIcon: Icon(Icons.flag_outlined),
                  border: OutlineInputBorder(),
                ),
                items: _priorities.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: _isSubmitting
                    ? null
                    : (value) {
                        if (value == null) return;

                        setState(() {
                          _selectedPriority = value;
                        });
                      },
              ),

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSubmitting ? null : _submitTicket,
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isSubmitting ? 'Submitting...' : 'Submit Support Ticket',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
