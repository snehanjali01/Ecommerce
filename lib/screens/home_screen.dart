import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/auth_provider.dart';
import '../services/api_service.dart';
import 'product_list_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'orders_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Sarees',
      'key': 'sarees',
      'imageUrl':
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=300',
    },
    {
      'name': "Men's Shirts",
      'key': 'mens_shirts',
      'imageUrl':
          'https://images.unsplash.com/photo-1596755094514-f87e34085b2c?w=300',
    },
    {
      'name': 'Grocery',
      'key': 'grocery',
      'imageUrl':
          'https://images.unsplash.com/photo-1542838132-92c53300491e?w=300',
    },
    {
      'name': 'Footwear',
      'key': 'footwear',
      'imageUrl':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=300',
    },
    {
      'name': 'Electronics',
      'key': 'electronics',
      'imageUrl':
          'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=300',
    },
    {
      'name': 'Sports',
      'key': 'sports',
      'imageUrl':
          'https://images.unsplash.com/photo-1614632537197-38a17061c2bd?w=300',
    },
    {
      'name': 'Home & Decor',
      'key': 'home_decor',
      'imageUrl':
          'https://images.unsplash.com/photo-1578500494198-246f612d3b3d?w=300',
    },
    {
      'name': 'Toys',
      'key': 'toys',
      'imageUrl':
          'https://images.unsplash.com/photo-1587654780291-39c9404d746b?w=300',
    },
    {
      'name': 'Beauty',
      'key': 'beauty',
      'imageUrl':
          'https://images.pexels.com/photos/3018845/pexels-photo-3018845.jpeg?w=300',
    },
    {
      'name': 'Kitchen',
      'key': 'kitchen',
      'imageUrl':
          'https://images.pexels.com/photos/34579937/pexels-photo-34579937.jpeg?w=300',
    },
    {
      'name': 'Bags',
      'key': 'bags',
      'imageUrl':
          'https://images.pexels.com/photos/3731256/pexels-photo-3731256.jpeg?w=300',
    },
    {
      'name': 'Books',
      'key': 'books',
      'imageUrl':
          'https://images.pexels.com/photos/1029141/pexels-photo-1029141.jpeg?w=300',
    },
   {
  'name': 'Stationery',
  'key': 'stationery',
  'imageUrl':
      'https://images.pexels.com/photos/6368842/pexels-photo-6368842.jpeg?w=300',
},
    {
      'name': 'Crop Tops',
      'key': 'crop_tops',
      'imageUrl':
          'https://images.pexels.com/photos/12892817/pexels-photo-12892817.jpeg?w=300',
    },
    {
      'name': "Men's T-Shirts",
      'key': 'mens_tshirts',
      'imageUrl':
          'https://images.pexels.com/photos/8498700/pexels-photo-8498700.jpeg?w=300',
    },
  ];

  List<dynamic> _allProducts = [];
  final TextEditingController _searchController = TextEditingController();

  final PageController _bannerController = PageController();
  int _bannerIndex = 0;
  Timer? _bannerTimer;

  final List<Map<String, dynamic>> _banners = [
    {
      'headline': 'Every healthy habit starts with one smart choice',
      'subtext': 'Flat 20% OFF on Groceries',
      'icon': Icons.eco,
      'colors': [Colors.deepPurple, Colors.purpleAccent],
      'imageUrl':
          'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=900',
    },
    {
      'headline': 'Drape elegance, own every occasion',
      'subtext': 'Sarees starting at ₹899',
      'icon': Icons.checkroom,
      'colors': [Colors.pink, Colors.pinkAccent],
      'imageUrl':
          'https://images.unsplash.com/photo-1610030469983-98e550d6193c?w=900',
    },
    {
      'headline': 'Good shoes take you to good places',
      'subtext': 'Up to 30% OFF Footwear',
      'icon': Icons.directions_walk,
      'colors': [Colors.orange, Colors.deepOrangeAccent],
      'imageUrl':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=900',
    },
    {
      'headline': 'Little hands, big imaginations',
      'subtext': 'New Arrivals in Toys',
      'icon': Icons.toys,
      'colors': [Colors.teal, Colors.tealAccent],
      'imageUrl':
          'https://images.pexels.com/photos/4000309/pexels-photo-4000309.jpeg?w=900',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_bannerController.hasClients) return;
      _bannerIndex = (_bannerIndex + 1) % _banners.length;
      _bannerController.animateToPage(
        _bannerIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ApiService.getAllProducts();
      setState(() => _allProducts = products);
    } catch (e) {}
  }

  List<dynamic> _byCategory(String key) =>
      _allProducts.where((p) => p['category'] == key).toList();

  void _goToSearch() {
    final query = _searchController.text.trim();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductListScreen(searchQuery: query),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(auth),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 14),
                    _buildSectionTitle('Categories'),
                    const SizedBox(height: 8),
                    _buildCategoryList(),
                    const SizedBox(height: 12),
                    _buildPromoCarousel(),
                    const SizedBox(height: 4),
                    for (final cat in categories)
                      if (_byCategory(cat['key'] as String).isNotEmpty)
                        _buildCategoryRow(
                          cat['name'] as String,
                          _byCategory(cat['key'] as String),
                        ),
                    _buildFeaturedHeader(),
                    const SizedBox(height: 8),
                    _buildFeaturedGrid(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Products'),
          BottomNavigationBarItem(
              icon: Icon(Icons.receipt), label: 'Orders'),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProductListScreen()));
          }
          if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()));
          }
        },
      ),
    );
  }

  Widget _buildHeader(AuthProvider auth) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                              'Hello, ${auth.email?.split('@')[0] ?? 'User'}',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.waving_hand,
                            color: Colors.amberAccent, size: 16),
                      ],
                    ),
                    const SizedBox(height: 2),
                    const Text('What are you looking for?',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.favorite_border, color: Colors.white),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const WishlistScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined,
                    color: Colors.white),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(auth.email ?? ''),
                      content: Text('Role: ${auth.role ?? ''}'),
                      actions: [
                        TextButton(
                          onPressed: () async {
                            await auth.logout();
                            Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                                (route) => false);
                          },
                          child: const Text('Logout',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _goToSearch(),
              decoration: InputDecoration(
                hintText: 'Search products, brands & more',
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.deepPurple),
                  onPressed: _goToSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ProductListScreen(category: cat['key'] as String))),
            child: Container(
              width: 74,
              margin: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(36),
                    child: Image.network(
                      cat['imageUrl'] as String,
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 64,
                        width: 64,
                        color: Colors.deepPurple.withOpacity(0.1),
                        child: const Icon(Icons.shopping_bag,
                            color: Colors.deepPurple),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          height: 64,
                          width: 64,
                          color: Colors.grey.shade200,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat['name'] as String,
                    style: const TextStyle(fontSize: 11),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPromoCarousel() {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _bannerIndex = i),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              final colors = List<Color>.from(banner['colors'] as List);
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: colors.first,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      banner['imageUrl'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(color: colors.first),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(color: colors.first);
                      },
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            colors.first.withOpacity(0.92),
                            colors.first.withOpacity(0.55),
                            colors.last.withOpacity(0.15),
                          ],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 16),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    banner['headline'] as String,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        height: 1.25),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(banner['icon'] as IconData,
                                    color: Colors.white, size: 22),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              banner['subtext'] as String,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == _bannerIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? Colors.deepPurple : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCategoryRow(String title, List<dynamic> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
          child: Text('Top Picks in $title',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return SizedBox(
                width: 150,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: _ProductCard(product: products[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Featured Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          TextButton(
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProductListScreen())),
            child: const Text('See all',
                style: TextStyle(color: Colors.deepPurple)),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedGrid() {
    if (_allProducts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final featured = _allProducts.take(8).toList();
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 220,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: featured.length,
      itemBuilder: (context, index) {
        final product = featured[index];
        return _ProductCard(product: product);
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final imageUrl = product['imageUrl']?.toString() ?? '';
    final inStock = product['inStock'] == true;
    final stock = product['stock'] is int
        ? product['stock'] as int
        : int.tryParse(product['stock']?.toString() ?? '') ?? 999;
    final lowStock = inStock && stock > 0 && stock <= 3;

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
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => ProductDetailScreen(productId: product['id']))),
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
                        child: _Badge(
                          text: '$discountPercent% OFF',
                          color: Colors.red.shade600,
                        ),
                      ),
                    if (!inStock)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _Badge(
                          text: 'Out of Stock',
                          color: Colors.grey.shade700,
                        ),
                      )
                    else if (lowStock)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: _Badge(
                          text: 'Hurry! Only $stock left',
                          color: Colors.red.shade600,
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
                          fontWeight: FontWeight.bold, fontSize: 13),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('₹${price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Text(
                            '₹${originalPrice.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      inStock ? 'In Stock' : 'Out of Stock',
                      style: TextStyle(
                          color: inStock ? Colors.green : Colors.red,
                          fontSize: 11),
                    ),
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

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}