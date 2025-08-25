import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/authService.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userId;
  String? get userId => _userId;

  Future<void> tryAutoLogin() async {
    final token = await _authService.getAuthToken();
    if (token != null) {
      _isLoggedIn = true;
      _userId = await _authService.getUserId();
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    try {
      final result = await _authService.login(email, password);
      _userId = result['userId'];
      _isLoggedIn = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name,
      String lastName, bool consent) async {
    try {
      final result = await _authService.register(email, password, name, lastName, consent);
      _userId = result['userId'];
      _isLoggedIn = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.clearAuthToken();
    await _authService.clearUserId();
    _isLoggedIn = false;
    _userId = null;
    notifyListeners();
  }
}
