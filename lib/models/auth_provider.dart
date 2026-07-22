import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _email;
  String? _role;
  bool _isLoading = false;

  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get role => _role;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _email = prefs.getString('email');
    _role = prefs.getString('role');
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.login(email, password);
      if (data['token'] != null) {
        _token = data['token'];
        _email = data['email'];
        _role = data['role'];
        _userId = email;
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', _token!);
        prefs.setString('userId', _userId!);
        prefs.setString('email', _email!);
        prefs.setString('role', _role!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.register(name, email, password);
      if (data['id'] != null) {
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _email = null;
    _role = null;
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    notifyListeners();
  }
}