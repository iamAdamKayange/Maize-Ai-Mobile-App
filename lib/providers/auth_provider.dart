import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _expertise;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get expertise => _expertise;

  void login(String email, String password) {
    // Simple validation - in real app, check against backend
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _userEmail = email;
      _userName = email.split('@')[0];
      notifyListeners();
    }
  }

  void register(String email, String password, String name, String expertise) {
    _isLoggedIn = true;
    _userEmail = email;
    _userName = name;
    _expertise = expertise;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _expertise = null;
    notifyListeners();
  }
}
