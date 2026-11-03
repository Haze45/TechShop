import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../cart/presentation/viewmodels/cart_state.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';
import '../widgets/delivery_address_form.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() =>
      _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _postalCodeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: cartAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Unable to load cart: $error'),
        ),
        data: (cartState) {
          if (cartState.isEmpty) {
            return const Center(
              child: Text('Your cart is empty.'),
            );
          }

          return _buildCheckoutContent(cartState);
        },
      ),
    );
  }

  Widget _buildCheckoutContent(CartState cartState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DeliveryAddressForm(
              nameController: _nameController,
              phoneController: _phoneController,
              addressController: _addressController,
              landmarkController: _landmarkController,
              cityController: _cityController,
              stateController: _stateController,
              postalCodeController: _postalCodeController,
            ),

            const SizedBox(height: 28),

            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            _buildOrderSummary(cartState),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: cartState.isUpdating ||
                    cartState.cart!.items.any(
                          (item) => !item.isInStock,
                    )
                    ? null
                    : _placeOrder,
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(CartState cartState) {
    const shippingFee = 0.0;
    final subtotal = cartState.totalPrice;
    final total = subtotal + shippingFee;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _summaryRow(
              'Items (${cartState.totalItems})',
              '₹${subtotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 12),
            _summaryRow(
              'Shipping',
              shippingFee == 0
                  ? 'Free'
                  : '₹${shippingFee.toStringAsFixed(2)}',
            ),
            const Divider(height: 24),
            _summaryRow(
              'Total Amount',
              '₹${total.toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
      String label,
      String amount, {
        bool isTotal = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isTotal ? 18 : 14,
          ),
        ),
      ],
    );
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final shippingAddress = {
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'landmark': _landmarkController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'postal_code': _postalCodeController.text.trim(),
      };

      final orderId = await ref
          .read(orderViewModelProvider.notifier)
          .createOrder(
        shippingAddress: shippingAddress,
      );

      if (!mounted) return;

      // Reload cart because the Supabase function cleared it.
      ref.invalidate(cartViewModelProvider);

      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 55,
            ),
            title: const Text('Order Placed Successfully!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your order has been placed successfully.'),
                const SizedBox(height: 12),
                const Text('Order ID:'),
                SelectableText(
                  orderId,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  context.go('/home');
                },
                child: const Text('Continue Shopping'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to place order: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}