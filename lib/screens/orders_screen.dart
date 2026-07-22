import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_provider.dart';
import '../services/api_service.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final orders = await ApiService.getOrdersByUser(auth.userId!);
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  final List<Map<String, dynamic>> _steps = [
    {'status': 'PLACED', 'label': 'Order Placed', 'icon': Icons.shopping_bag},
    {'status': 'CONFIRMED', 'label': 'Confirmed', 'icon': Icons.check_circle},
    {'status': 'SHIPPED', 'label': 'Shipped', 'icon': Icons.local_shipping},
    {'status': 'OUT_FOR_DELIVERY', 'label': 'Out for Delivery', 'icon': Icons.delivery_dining},
    {'status': 'DELIVERED', 'label': 'Delivered', 'icon': Icons.home},
  ];

  int _getStepIndex(String status) {
    for (int i = 0; i < _steps.length; i++) {
      if (_steps[i]['status'] == status) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('My Orders', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No orders yet',
                          style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final items = order['items'] as List<dynamic>? ?? [];
                    final currentStep = _getStepIndex(order['status'] ?? 'PLACED');
                    final isCancelled = order['status'] == 'CANCELLED';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                    'Order #${order['id'].toString().substring(0, 8)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text('₹${order['totalAmount']}',
                                    style: const TextStyle(
                                        color: Colors.deepPurple,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Each item now shows its product photo (if the
                            // order captured one) instead of just plain text.
                            // Falls back to a placeholder icon otherwise.
                            ...items.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: (item['imageUrl'] != null &&
                                                item['imageUrl']
                                                    .toString()
                                                    .startsWith('http'))
                                            ? Image.network(
                                                item['imageUrl'],
                                                width: 48,
                                                height: 48,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                        stackTrace) =>
                                                    Container(
                                                  width: 48,
                                                  height: 48,
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.1),
                                                  child: const Icon(
                                                      Icons.shopping_bag,
                                                      size: 22,
                                                      color:
                                                          Colors.deepPurple),
                                                ),
                                              )
                                            : Container(
                                                width: 48,
                                                height: 48,
                                                color: Colors.deepPurple
                                                    .withOpacity(0.1),
                                                child: const Icon(
                                                    Icons.shopping_bag,
                                                    size: 22,
                                                    color: Colors.deepPurple),
                                              ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          '${item['productName']} x${item['quantity']}',
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            const Divider(height: 24),
                            if (isCancelled)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.cancel, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Order Cancelled',
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              )
                            else
                              Column(
                                children: List.generate(_steps.length, (stepIndex) {
                                  final isCompleted = stepIndex <= currentStep;
                                  final isActive = stepIndex == currentStep;
                                  final isLast = stepIndex == _steps.length - 1;

                                  return Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Column(
                                        children: [
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: isCompleted
                                                  ? Colors.green
                                                  : Colors.grey.shade300,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _steps[stepIndex]['icon'] as IconData,
                                              color: isCompleted
                                                  ? Colors.white
                                                  : Colors.grey,
                                              size: 18,
                                            ),
                                          ),
                                          if (!isLast)
                                            Container(
                                              width: 2,
                                              height: 40,
                                              color: stepIndex < currentStep
                                                  ? Colors.green
                                                  : Colors.grey.shade300,
                                            ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _steps[stepIndex]['label'] as String,
                                              style: TextStyle(
                                                fontWeight: isActive
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                color: isCompleted
                                                    ? Colors.black
                                                    : Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                            if (isActive)
                                              Text(
                                                isActive ? 'Current Status' : '',
                                                style: const TextStyle(
                                                    color: Colors.green,
                                                    fontSize: 12),
                                              ),
                                            SizedBox(height: isLast ? 0 : 28),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}