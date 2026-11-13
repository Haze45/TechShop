import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
      appBar: AppBar(title: const Text('Terms & Conditions')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'TechShop Terms & Conditions',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Last updated: November 2026'),
          const SizedBox(height: 20),

          _section(
            '1. Acceptance of Terms',
            'By accessing or using TechShop, you agree to these Terms '
                '& Conditions. If you do not agree, please do not use '
                'the application.',
          ),

          _section(
            '2. About TechShop',
            'TechShop is an online shopping application that allows '
                'customers to browse and purchase smartphones and laptops.',
          ),

          _section(
            '3. User Accounts',
            'You are responsible for providing accurate account '
                'information and maintaining the confidentiality of your '
                'login credentials. You must notify the support team if '
                'you suspect unauthorized access to your account.',
          ),

          _section(
            '4. Product Information and Pricing',
            'We aim to display accurate product descriptions, '
                'specifications, prices and availability. Product details '
                'and stock availability may change. If an error is '
                'identified, we will take reasonable steps to address it.',
          ),

          _section(
            '5. Orders',
            'An order is subject to availability and acceptance by '
                'TechShop. You should review your delivery address, '
                'products and order total before confirming a purchase.',
          ),

          _section(
            '6. Payments',
            'Available payment methods are displayed during checkout. '
                'Online payments may be processed through Razorpay. '
                'Cash on Delivery may be available for eligible orders. '
                'Payment confirmation is subject to verification.',
          ),

          _section(
            '7. Shipping and Delivery',
            'Delivery estimates are provided for guidance and may '
                'vary due to location, availability, logistics or '
                'circumstances beyond our control. Please provide '
                'a complete and accurate delivery address.',
          ),

          _section(
            '8. Cancellation and Refunds',
            'Order cancellation and refund eligibility depend on '
                'the order status, payment status and applicable '
                'cancellation and refund policies. Contact Customer '
                'Support for assistance with an order.',
          ),

          _section(
            '9. Reviews and User Content',
            'Users should submit honest and relevant product reviews. '
                'Abusive, misleading, unlawful or inappropriate content '
                'may be rejected or removed.',
          ),

          _section(
            '10. Acceptable Use',
            'You must not misuse the application, attempt unauthorized '
                'access, interfere with its operation or submit false '
                'information.',
          ),

          _section(
            '11. Intellectual Property',
            'Application design, branding, text and other original '
                'content may be protected by applicable intellectual '
                'property laws. You may not reproduce or distribute '
                'protected content without permission.',
          ),

          _section(
            '12. Limitation of Liability',
            'To the extent permitted by applicable law, TechShop '
                'will not be responsible for indirect or consequential '
                'losses arising from use of the application. Nothing '
                'in these terms excludes liability that cannot legally '
                'be excluded.',
          ),

          _section(
            '13. Changes to Terms',
            'These Terms & Conditions may be updated as the '
                'application evolves. Updated terms will be published '
                'within the application.',
          ),

          _section(
            '14. Contact and Support',
            'For questions about these terms, orders or account '
                'issues, contact TechShop through the Customer Support '
                'section of the application.',
          ),
        ],
      ),
    );
  }
}
