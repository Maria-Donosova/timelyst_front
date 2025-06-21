import 'package:flutter/material.dart';
import '../services/authService.dart';
import '../data/loginUser.dart';
import '../data/registerUser.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthProvider(this._authService);

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userId;
  String? get userId => _userId;

  Future<void> checkAuthState() async {
    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      _userId = await _authService.getUserId();
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _errorMessage = null;
    try {
      final response = await loginUser(email, password);
      final tokenFromResponse = response['token'];
      final userIdFromResponse = response['userId'];

      await _authService.saveAuthToken(tokenFromResponse);
      await _authService.saveUserId(userIdFromResponse);

      _isLoggedIn = true;
      _userId = userIdFromResponse;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to login: $e';
      notifyListeners();
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> register(String email, String password, String name,
      String lastName, bool consent) async {
    try {
      final response =
          await registerUser(email, password, name, lastName, consent);
      final tokenFromResponse = response['token'];
      await _authService.saveAuthToken(tokenFromResponse);
      // Handle userId and login state as per your app's flow after registration
      _isLoggedIn = true; // Example: assuming registration logs in
      // _userId = ... // if returned by register API and auto-login
      notifyListeners();
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> logout() async {
    await _authService.clearAuthToken();
    await _authService.clearUserId();
    _isLoggedIn = false;
    _userId = null;
    // _token = null;
    notifyListeners();
  }
}
