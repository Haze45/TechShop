import 'package:flutter/material.dart';

class AdminErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const AdminErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              size: 36,
              color: theme.colorScheme.error,
            ),

            const SizedBox(height: 12),

            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}