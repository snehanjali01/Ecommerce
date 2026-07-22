import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/auth_provider.dart';
import '../services/api_service.dart';
import '../services/razorpay_web/razorpay_web.dart';
import 'orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final Map<String, dynamic> cart;
  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _addressController = TextEditingController();
  String _paymentMethod = 'COD';
  bool _isLoading = false;

  late Razorpay _razorpay;
  Map<String, dynamic>? _pendingOrderData;
  double _total = 0;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onMobilePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    if (!kIsWeb) _razorpay.clear();
    super.dispose();
  }

  Future<void> _completePayment({
    required String paymentId,
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
  }) async {
    try {
      await ApiService.verifyPayment({
        'paymentId': paymentId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': razorpaySignature,
      });

      await ApiService.placeOrder(_pendingOrderData!['orderPayload']);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful! Order placed.')));
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OrdersScreen()),
          (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment verification failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Mobile (Android/iOS) callback via razorpay_flutter
  void _onMobilePaymentSuccess(PaymentSuccessResponse response) {
    _completePayment(
      paymentId: _pendingOrderData!['paymentId'],
      razorpayPaymentId: response.paymentId!,
      razorpayOrderId: response.orderId!,
      razorpaySignature: response.signature!,
    );
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: ${response.message}')));
    setState(() => _isLoading = false);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('External wallet selected: ${response.walletName}')));
    setState(() => _isLoading = false);
  }

  Future<void> _handlePlaceOrder(AuthProvider auth, List<dynamic> items) async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter delivery address')));
      return;
    }

    setState(() => _isLoading = true);

    final orderPayload = {
      'userId': auth.userId,
      'items': items,
      'address': _addressController.text,
      'paymentMethod': _paymentMethod,
    };

    try {
      if (_paymentMethod == 'COD') {
        await ApiService.placeOrder(orderPayload);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order placed successfully!')));
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const OrdersScreen()),
            (route) => false);
        setState(() => _isLoading = false);
        return;
      }

      // RAZORPAY flow — create order on backend first
      final paymentOrder = await ApiService.createRazorpayOrder({
        'userId': auth.userId,
        'amount': _total,
        'orderId': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      print('PAYMENT ORDER RESPONSE: $paymentOrder');

      _pendingOrderData = {
        'paymentId': paymentOrder['id'],
        'orderPayload': orderPayload,
      };

      // Key regenerated after the previous one was accidentally committed
      // to GitHub — always keep only the public Key ID in Flutter code,
      // never the secret (that stays server-side only).
      const razorpayKey = 'rzp_test_TDILPUbG3N1AxR';
      final amountInPaise = (_total * 100).toInt();
      final razorpayOrderId = paymentOrder['razorpayOrderId'];

      print('RAZORPAY ORDER ID: $razorpayOrderId');

      if (kIsWeb) {
        RazorpayWeb.open(
          key: razorpayKey,
          amount: amountInPaise,
          orderId: razorpayOrderId,
          name: 'ShopEase',
          description: 'Order Payment',
          email: auth.email ?? '',
          onSuccess: (paymentId, orderId, signature) {
            _completePayment(
              paymentId: _pendingOrderData!['paymentId'],
              razorpayPaymentId: paymentId,
              razorpayOrderId: orderId,
              razorpaySignature: signature,
            );
          },
          onError: (error) {
            if (!mounted) return;
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('Payment failed: $error')));
            setState(() => _isLoading = false);
          },
        );
      } else {
        // 'currency' is required by Razorpay's native Android SDK — omitting
        // it can throw an unhandled exception that crashes the whole app
        // instead of surfacing a normal Flutter error.
        final Map<String, dynamic> options = {
          'key': razorpayKey,
          'amount': amountInPaise,
          'currency': 'INR',
          'name': 'ShopEase',
          'order_id': razorpayOrderId,
          'description': 'Order Payment',
          'prefill': {
            'contact': '',
            'email': auth.email ?? '',
          },
        };
        _razorpay.open(options);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to place order: $e')));
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final items = widget.cart['items'] as List<dynamic>? ?? [];
    final total = widget.cart['totalAmount'] ?? 0;
    _total = (total is int) ? total.toDouble() : (total as double);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Checkout', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ...items.map((item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${item['productName']} x${item['quantity']}'),
                              Text('₹${item['totalPrice']}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        )),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('₹$total',
                            style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Delivery Address',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter your full delivery address',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),
            const Text('Payment Method',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  RadioListTile(
                    value: 'COD',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                    title: const Text('Cash on Delivery'),
                    secondary: const Icon(Icons.money, color: Colors.green),
                  ),
                  RadioListTile(
                    value: 'RAZORPAY',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val!),
                    title: const Text('Pay Online (Razorpay)'),
                    secondary: const Icon(Icons.payment, color: Colors.blue),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _isLoading
                    ? null
                    : () => _handlePlaceOrder(auth, items),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Place Order',
                        style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}