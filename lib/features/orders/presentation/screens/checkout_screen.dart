import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../../core/config/env.dart';
import '../../../cart/presentation/viewmodels/cart_state.dart';
import '../../../cart/presentation/viewmodels/cart_viewmodel.dart';
import '../../../payment/data/models/payment_verification_model.dart';
import '../../../payment/data/services/razorpay_service.dart';
import '../../../payment/presentation/viewmodels/payment_viewmodel.dart';
import '../viewmodels/order_viewmodel.dart';
import '../widgets/delivery_address_form.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
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

  // Default payment method
  String _selectedPaymentMethod = 'cod';

  late final RazorpayService _razorpayService;

  String? _pendingOrderId;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();

    _razorpayService = RazorpayService(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
      onExternalWallet: _handleExternalWallet,
    );
  }

  @override
  void dispose() {
    _razorpayService.dispose();
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
      appBar: AppBar(title: const Text('Checkout')),
      body: cartAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) =>
            Center(child: Text('Unable to load cart: $error')),
        data: (cartState) {
          if (cartState.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
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

            // Payment method selection
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            _buildPaymentMethodSelector(),

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
                onPressed:
                    _isPlacingOrder ||
                        cartState.isUpdating ||
                        cartState.cart!.items.any((item) => !item.isInStock)
                    ? null
                    : _placeOrder,
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _selectedPaymentMethod == 'cod'
                            ? 'Place Order'
                            : 'Continue to Payment',
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Payment method selector
  Widget _buildPaymentMethodSelector() {
    return Card(
      child: Column(
        children: [
          RadioListTile<String>(
            value: 'cod',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedPaymentMethod = value;
              });
            },
            title: const Text('Cash on Delivery'),
            subtitle: const Text('Pay when your order arrives.'),
            secondary: const Icon(Icons.local_shipping_outlined),
          ),

          const Divider(height: 1),

          RadioListTile<String>(
            value: 'razorpay',
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _selectedPaymentMethod = value;
              });
            },
            title: const Text('Pay Online'),
            subtitle: const Text('Pay securely using Razorpay.'),
            secondary: const Icon(Icons.payment),
          ),
        ],
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
              shippingFee == 0 ? 'Free' : '₹${shippingFee.toStringAsFixed(2)}',
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

  Widget _summaryRow(String label, String amount, {bool isTotal = false}) {
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
    if (_isPlacingOrder) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

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
            paymentMethod: _selectedPaymentMethod,
          );

      if (!mounted) return;

      if (_selectedPaymentMethod == 'cod') {
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
                  SelectableText(orderId),
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
      } else {
        // Open Razorpay for online payment.
        await _openRazorpayCheckout(orderId);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to place order: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  Future<void> _openRazorpayCheckout(String orderId) async {
    try {
      _pendingOrderId = orderId;

      final paymentOrder = await ref
          .read(paymentViewModelProvider.notifier)
          .createPaymentOrder(orderId);

      if (!mounted) return;

      final options = {
        'key': Env.razorpayKeyId,
        'amount': paymentOrder.amount,
        'currency': paymentOrder.currency,
        'name': 'TechShop',
        'description': 'Payment for your TechShop order',
        'order_id': paymentOrder.razorpayOrderId,
        'prefill': {
          'contact': _phoneController.text.trim(),
          'name': _nameController.text.trim(),
        },
        'theme': {'color': '#1565C0'},
      };

      _razorpayService.openCheckout(options);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to open Razorpay: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    final orderId = _pendingOrderId;

    if (orderId == null ||
        response.orderId == null ||
        response.paymentId == null ||
        response.signature == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment details are incomplete.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final verified = await ref
          .read(paymentViewModelProvider.notifier)
          .verifyPayment(
            techShopOrderId: orderId,
            verification: PaymentVerificationModel(
              razorpayOrderId: response.orderId!,
              razorpayPaymentId: response.paymentId!,
              razorpaySignature: response.signature!,
            ),
          );

      if (!mounted) return;

      if (verified) {
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
              title: const Text('Payment Successful!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Your payment has been verified successfully.'),
                  const SizedBox(height: 12),
                  const Text('Order ID:'),
                  SelectableText(orderId),
                  const SizedBox(height: 8),
                  const Text('Payment ID:'),
                  SelectableText(response.paymentId!),
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Payment could not be verified. Please contact support.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment verification failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment failed: ${response.message ?? 'Please try again.'}',
        ),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'External wallet selected: ${response.walletName ?? 'Unknown'}',
        ),
      ),
    );
  }
}
