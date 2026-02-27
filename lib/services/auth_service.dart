import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isGuest = false;
  String _username = '';
  String _email = '';

  bool get isLoggedIn => _isLoggedIn;
  bool get isGuest => _isGuest;
  String get username => _username;
  String get email => _email;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _isGuest = prefs.getBool('isGuest') ?? false;
    _username = prefs.getString('username') ?? '';
    _email = prefs.getString('email') ?? '';
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = true;
    _isGuest = true;
    _username = '';
    _email = '';
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isGuest', true);
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
    _isGuest = false;
    _username = '';
    _email = '';
    await prefs.setBool('isLoggedIn', false);
    await prefs.setBool('isGuest', false);
    await prefs.remove('username');
    await prefs.remove('email');
    notifyListeners();
  }
}
