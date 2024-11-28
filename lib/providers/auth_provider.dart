import 'package:flutter/material.dart';
import '../service/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkAuthState() async {
    _isLoggedIn = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<void> login(String token, String refreshToken) async {
    await _authService.saveAuthToken(token);
    await _authService.saveRefreshToken(refreshToken);
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.clearAuthToken();
    _isLoggedIn = false;
    notifyListeners();
  }
}
