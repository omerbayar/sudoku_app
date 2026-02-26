import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  String _username = '';
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  String get username => _username;
  String get email => _email;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _username = prefs.getString('username') ?? '';
    _email = prefs.getString('email') ?? '';
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // Simulate login - accept any non-empty credentials
    if (email.isEmpty || password.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    _email = email;
    _username = email.split('@').first;
    _isLoggedIn = true;
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', _username);
    await prefs.setString('email', _email);
    notifyListeners();
    return true;
  }

  Future<bool> register(String username, String email, String password) async {
    if (username.isEmpty || email.isEmpty || password.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    _username = username;
    _email = email;
    _isLoggedIn = true;
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('username', _username);
    await prefs.setString('email', _email);
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    _username = '';
    _email = '';
    await prefs.setBool('isLoggedIn', false);
    await prefs.remove('username');
    await prefs.remove('email');
    notifyListeners();
  }
}
