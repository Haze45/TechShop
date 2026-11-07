import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/theme_provider.dart';
import 'app_button.dart';
import 'app_text_field.dart';
import 'product_card.dart';

class DesignSystemPreview extends ConsumerWidget {
  const DesignSystemPreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TechShop Design System',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),

        actions: [
          PopupMenuButton<ThemeMode>(
            icon: const Icon(Icons.palette_outlined),
            initialValue: themeMode,
            onSelected: (mode) {
              ref.read(themeModeProvider.notifier).setThemeMode(mode);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: ThemeMode.light, child: Text('Light Mode')),
              PopupMenuItem(value: ThemeMode.dark, child: Text('Dark Mode')),
              PopupMenuItem(
                value: ThemeMode.system,
                child: Text('System Default'),
              ),
            ],
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branding
            Text('Welcome to TechShop', style: theme.textTheme.headlineMedium),

            const SizedBox(height: 8),

            Text(
              'Premium smartphones and laptops.',
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 28),

            // Typography
            Text('Typography', style: theme.textTheme.titleLarge),

            const SizedBox(height: 12),

            Text('Heading Large', style: theme.textTheme.headlineLarge),

            Text('Body Medium', style: theme.textTheme.bodyMedium),

            const SizedBox(height: 28),

            // Buttons
            Text('Buttons', style: theme.textTheme.titleLarge),

            const SizedBox(height: 12),

            AppButton(text: 'Explore Products', onPressed: () {}),

            const SizedBox(height: 12),

            AppButton(
              text: 'Continue',
              isExpanded: false,
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {},
            ),

            const SizedBox(height: 28),

            // Text Field
            Text('Text Fields', style: theme.textTheme.titleLarge),

            const SizedBox(height: 12),

            const AppTextField(
              label: 'Search Products',
              hint: 'Search smartphones and laptops',
              prefixIcon: Icon(Icons.search),
            ),

            const SizedBox(height: 28),

            // Product Cards
            Text('Product Cards', style: theme.textTheme.titleLarge),

            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.62,

              children: [
                ProductCard(
                  name: 'iPhone 16 Pro',
                  brand: 'Apple',
                  imageUrl: 'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=500',
                  price: 119900,
                  oldPrice: 129900,
                  rating: 4.8,
                  onTap: () {},
                  onWishlistTap: () {}, productId: '',
                ),

                ProductCard(
                  name: 'MacBook Air',
                  brand: 'Apple',
                  imageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=500',
                  price: 99900,
                  oldPrice: 109900,
                  rating: 4.7,
                  onTap: () {},
                  onWishlistTap: () {}, productId: '',
                ),
              ],
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}
