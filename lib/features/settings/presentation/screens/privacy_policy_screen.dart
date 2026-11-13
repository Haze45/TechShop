import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  Widget _section(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.6)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'TechShop Privacy Policy',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Last updated: November 2026'),
          const SizedBox(height: 20),

          _section(
            '1. Introduction',
            'TechShop is an online shopping application for smartphones '
                'and laptops. This policy explains how information is handled '
                'when you use our application.',
          ),

          _section(
            '2. Information We Collect',
            'We may process information such as your name, email address, '
                'phone number, profile picture, delivery addresses, order '
                'details, product reviews and customer support messages. '
                'The application may also record product views and shopping '
                'interactions to provide personalized recommendations.',
          ),

          _section(
            '3. How We Use Your Information',
            'Information is used to manage your account, process orders, '
                'deliver products, manage payments, provide customer support, '
                'send order status notifications and improve product '
                'recommendations.',
          ),

          _section(
            '4. Data Storage and Services',
            'TechShop uses Supabase for authentication, database and file '
                'storage services, and Firebase Cloud Messaging for push '
                'notifications. Payment processing may be handled through '
                'Razorpay. These services process information as necessary '
                'to provide their respective functionality.',
          ),

          _section(
            '5. Payments',
            'Payments are processed through the configured payment '
                'provider. TechShop should not store your complete card '
                'number, CVV or other sensitive payment credentials in its '
                'application database.',
          ),

          _section(
            '6. Notifications',
            'If enabled, you may receive notifications about order '
                'confirmation, processing, shipping, delivery and cancellation. '
                'You can manage order update notifications through Settings.',
          ),

          _section(
            '7. Data Sharing',
            'Information may be processed by service providers that '
                'support authentication, hosting, storage, payment processing '
                'and notifications. We do not intend to sell personal '
                'information to third parties.',
          ),

          _section(
            '8. Data Security',
            'TechShop uses access controls and backend security policies '
                'to help protect user information. However, no electronic '
                'storage or transmission method can be guaranteed to be '
                'completely secure.',
          ),

          _section(
            '9. Account and Data Deletion',
            'You can request account deletion through the Delete Account '
                'option in your profile. Some transaction records may need '
                'to be retained where required for legal, accounting or '
                'legitimate business purposes.',
          ),

          _section(
            '10. Changes to This Policy',
            'This policy may be updated when application functionality '
                'or data handling practices change. The updated policy '
                'will be made available in the application.',
          ),

          _section(
            '11. Contact',
            'For privacy-related questions, please contact the TechShop '
                'support team through the Customer Support section of the app.',
          ),
        ],
      ),
    );
  }
}
