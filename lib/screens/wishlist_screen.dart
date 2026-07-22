import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_provider.dart';
import '../services/api_service.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  Map<String, dynamic>? _wishlist;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    try {
      final wishlist = await ApiService.getWishlist(auth.userId!);
      setState(() {
        _wishlist = wishlist;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final items = _wishlist?['items'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('My Wishlist', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Your wishlist is empty',
                          style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: (item['imageUrl'] != null &&
                                      item['imageUrl'].toString().startsWith('http'))
                                  ? Image.network(
                                      item['imageUrl'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 70,
                                        height: 70,
                                        color: Colors.deepPurple.withOpacity(0.1),
                                        child: const Icon(Icons.shopping_bag, color: Colors.deepPurple),
                                      ),
                                    )
                                  : Container(
                                      width: 70,
                                      height: 70,
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      child: const Icon(Icons.shopping_bag, color: Colors.deepPurple),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['productName'] ?? '',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text('₹${item['price']}',
                                      style: const TextStyle(
                                          color: Colors.deepPurple,
                                          fontWeight: FontWeight.bold)),
                                  Text(item['category'] ?? '',
                                      style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_shopping_cart,
                                      color: Colors.deepPurple),
                                  onPressed: () async {
                                    await ApiService.addToCart(auth.userId!, {
                                      'productId': item['productId'],
                                      'productName': item['productName'],
                                      'price': item['price'],
                                      'quantity': 1,
                                      'imageUrl': item['imageUrl'],
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Added to cart!')));
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await ApiService.removeFromWishlist(
                                        auth.userId!, item['productId']);
                                    _loadWishlist();
                                  },
                                ),
                              ],
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