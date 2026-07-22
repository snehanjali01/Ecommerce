import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_provider.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _product;
  bool _isLoading = true;
  int _currentImageIndex = 0;
  int _quantity = 1;
  late PageController _pageController;

  List<dynamic> _relatedProducts = [];
  bool _relatedLoading = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadProduct();
  }

  @override
  void didUpdateWidget(covariant ProductDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.productId != widget.productId) {
      setState(() {
        _isLoading = true;
        _relatedLoading = true;
        _currentImageIndex = 0;
        _quantity = 1;
      });
      _loadProduct();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final product = await ApiService.getProductById(widget.productId);
      setState(() {
        _product = product;
        _isLoading = false;
      });
      _loadRelatedProducts();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRelatedProducts() async {
    final category = _product?['category']?.toString();
    if (category == null || category.isEmpty) {
      setState(() => _relatedLoading = false);
      return;
    }
    try {
      final products = await ApiService.getProductsByCategory(category);
      setState(() {
        _relatedProducts = products
            .where((p) => p['id'] != widget.productId)
            .take(10)
            .toList();
        _relatedLoading = false;
      });
    } catch (e) {
      setState(() => _relatedLoading = false);
    }
  }

  List<String> _getImageList() {
    final images = _product?['images'];
    if (images is List && images.isNotEmpty) {
      return images.map((e) => e.toString()).toList();
    }
    final fallback = _product?['imageUrl']?.toString() ?? '';
    return fallback.isNotEmpty ? [fallback] : [];
  }

  String _estimatedDeliveryText() {
    final now = DateTime.now();
    final delivery = now.add(const Duration(days: 4));
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final dayName = days[delivery.weekday - 1];
    return '$dayName, ${delivery.day} ${months[delivery.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: Text(_product?['name'] ?? 'Product',
            style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () async {
              if (_product != null) {
                await ApiService.addToWishlist(auth.userId!, {
                  'productId': _product!['id'],
                  'productName': _product!['name'],
                  'price': _product!['price'],
                  'category': _product!['category'],
                  'imageUrl': _product!['imageUrl'],
                });
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Added to wishlist!')));
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _product == null
              ? const Center(child: Text('Product not found'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductImageGallery(),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(_product!['name'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold)),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _product!['inStock'] == true
                                        ? Colors.green
                                        : Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _product!['inStock'] == true
                                        ? 'In Stock'
                                        : 'Out of Stock',
                                    style: const TextStyle(
                                        color: Colors.white, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildPriceRow(),
                            const SizedBox(height: 12),
                            _buildDeliveryEstimate(),
                            const SizedBox(height: 16),
                            const Text('Highlights',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildHighlightBullet(_product!['description'] ?? ''),
                            if (_product!['attributes'] != null)
                              ...(_product!['attributes'] as Map<String, dynamic>)
                                  .entries
                                  .map((e) => _buildHighlightBullet(
                                      '${_capitalize(e.key)}: ${e.value}')),
                            const SizedBox(height: 20),
                            const Text('Quantity',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildQuantitySelector(),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      _product!['inStock'] == true
                                          ? Colors.deepPurple
                                          : Colors.grey,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12)),
                                ),
                                onPressed: _product!['inStock'] == true
                                    ? () async {
                                        await ApiService.addToCart(
                                            auth.userId!, {
                                          'productId': _product!['id'],
                                          'productName': _product!['name'],
                                          'price': _product!['price'],
                                          'quantity': _quantity,
                                          'imageUrl': _product!['imageUrl'],
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'Added $_quantity to cart!')));
                                      }
                                    : null,
                                child: Text(
                                  _product!['inStock'] == true
                                      ? 'Add to Cart'
                                      : 'Out of Stock',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildRelatedProductsSection(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
    );
  }

  Widget _buildPriceRow() {
    final price = (_product!['price'] is num)
        ? (_product!['price'] as num).toDouble()
        : 0.0;
    final originalPrice = (_product!['originalPrice'] is num)
        ? (_product!['originalPrice'] as num).toDouble()
        : null;
    final hasDiscount = originalPrice != null && originalPrice > price;
    final discountPercent = hasDiscount
        ? (((originalPrice - price) / originalPrice) * 100).round()
        : 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text('₹${price.toStringAsFixed(0)}',
            style: const TextStyle(
                fontSize: 26,
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold)),
        if (hasDiscount) ...[
          const SizedBox(width: 10),
          Text(
            '₹${originalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$discountPercent% OFF',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDeliveryEstimate() {
    final inStock = _product!['inStock'] == true;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.local_shipping_outlined,
              color: Colors.deepPurple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              inStock
                  ? 'Get it by ${_estimatedDeliveryText()}'
                  : 'Currently unavailable for delivery',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightBullet(String text) {
    if (text.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: Icon(Icons.circle, size: 5, color: Colors.deepPurple),
          ),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        _buildQtyButton(Icons.remove, () {
          if (_quantity > 1) setState(() => _quantity--);
        }),
        Container(
          width: 48,
          alignment: Alignment.center,
          child: Text('$_quantity',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        _buildQtyButton(Icons.add, () {
          setState(() => _quantity++);
        }),
      ],
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: Colors.deepPurple),
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _buildProductImageGallery() {
    final images = _getImageList();

    if (images.isEmpty) {
      return Container(
        width: double.infinity,
        height: 320,
        color: Colors.deepPurple.withOpacity(0.1),
        child: const Center(
            child: Icon(Icons.shopping_bag,
                size: 100, color: Colors.deepPurple)),
      );
    }

    return Container(
      width: double.infinity,
      color: const Color(0xFFF7F7FB),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            children: [
              SizedBox(
                height: 320,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() => _currentImageIndex = index);
                  },
                  itemBuilder: (context, index) {
                    final url = images[index];
                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.deepPurple.withOpacity(0.1),
                        child: const Center(
                            child: Icon(Icons.shopping_bag,
                                size: 100, color: Colors.deepPurple)),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                              child: CircularProgressIndicator()),
                        );
                      },
                    );
                  },
                ),
              ),
              if (images.length > 1) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    final isActive = index == _currentImageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isActive ? 10 : 8,
                      height: isActive ? 10 : 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? Colors.deepPurple
                            : Colors.deepPurple.withOpacity(0.3),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRelatedProductsSection() {
    if (_relatedLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_relatedProducts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('You Might Also Like',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _relatedProducts.length,
            itemBuilder: (context, index) {
              final product = _relatedProducts[index];
              return SizedBox(
                width: 150,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _RelatedProductCard(product: product),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RelatedProductCard extends StatelessWidget {
  final dynamic product;
  const _RelatedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['imageUrl']?.toString() ?? '';
    final inStock = product['inStock'] == true;

    final price =
        (product['price'] is num) ? (product['price'] as num).toDouble() : 0.0;
    final originalPrice = (product['originalPrice'] is num)
        ? (product['originalPrice'] as num).toDouble()
        : null;
    final hasDiscount = originalPrice != null && originalPrice > price;
    final discountPercent = hasDiscount
        ? (((originalPrice - price) / originalPrice) * 100).round()
        : 0;

    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product['id']),
          ),
        );
      },
      child: Opacity(
        opacity: inStock ? 1.0 : 0.55,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.grey.withOpacity(0.12), blurRadius: 8),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.deepPurple.withOpacity(0.1),
                                child: const Icon(Icons.shopping_bag,
                                    size: 40, color: Colors.deepPurple),
                              ),
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Container(color: Colors.grey.shade200);
                              },
                            )
                          : Container(
                              color: Colors.deepPurple.withOpacity(0.1),
                              child: const Icon(Icons.shopping_bag,
                                  size: 40, color: Colors.deepPurple),
                            ),
                    ),
                    if (hasDiscount)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.red.shade600,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '$discountPercent% OFF',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product['name'] ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text('₹${price.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}