import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../data/login_user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkAuthState() async {
    _isLoggedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  // Future<void> login(String token, String refreshToken) async {
  //   await _authService.saveAuthToken(token);
  //   await _authService.saveRefreshToken(refreshToken);
  //   _isLoggedIn = true;
  //   print('Logged in: $_isLoggedIn');
  //   notifyListeners();
  // }

  Future<void> login(String email, String password) async {
    try {
      // Call the loginUser function
      await loginUser(email, password);

      // Assuming loginUser stores the token and sets _isLoggedIn to true
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      print('Error during login: $e');
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> logout() async {
    await _authService.clearAuthToken();
    _isLoggedIn = false;
    notifyListeners();
  }
}
