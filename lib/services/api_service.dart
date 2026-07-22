import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;

class ApiService {
  // 'localhost' only resolves correctly from a real browser (web) or from
  // your PC itself. Android emulators run in their own virtual network,
  // where 'localhost' points to the emulator, not your computer — Android
  // emulators use the special alias 10.0.2.2 to reach the host machine.
  // iOS simulators, by contrast, share the host's network directly, so
  // 'localhost' still works there.
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8070';
    if (Platform.isAndroid) return 'http://10.0.2.2:8070';
    return 'http://localhost:8070';
  }

  // Auth
  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    return jsonDecode(response.body);
  }

  // Products
  static Future<List<dynamic>> getAllProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/products'));
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getProductsByCategory(String category) async {
    final response = await http.get(Uri.parse('$baseUrl/api/products/category/$category'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> getProductById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/api/products/$id'));
    return jsonDecode(response.body);
  }

  // Cart
  static Future<Map<String, dynamic>> getCart(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/cart/$userId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addToCart(String userId, Map<String, dynamic> item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/cart/$userId/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeFromCart(String userId, String productId) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/cart/$userId/remove/$productId'));
    return jsonDecode(response.body);
  }

  // Orders
  static Future<Map<String, dynamic>> placeOrder(Map<String, dynamic> order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(order),
    );
    return jsonDecode(response.body);
  }

  static Future<List<dynamic>> getOrdersByUser(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/orders/user/$userId'));
    return jsonDecode(response.body);
  }

  // Wishlist
  static Future<Map<String, dynamic>> getWishlist(String userId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/wishlist/$userId'));
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> addToWishlist(String userId, Map<String, dynamic> item) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/wishlist/$userId/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> removeFromWishlist(String userId, String productId) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/wishlist/$userId/remove/$productId'));
    return jsonDecode(response.body);
  }

  // Payments (Razorpay)
  static Future<Map<String, dynamic>> createRazorpayOrder(Map<String, dynamic> payment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/razorpay/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payment),
    );
    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> verifyData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/payments/razorpay/verify'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(verifyData),
    );
    return jsonDecode(response.body);
  }
}