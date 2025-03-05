import 'package:flutter/material.dart';
import '../services/authService.dart';
import '../data/loginUser.dart';
import '../data/registerUser.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userId;
  String? get userId => _userId;

  Future<void> checkAuthState() async {
    _isLoggedIn = await _authService.isLoggedIn();
    if (_isLoggedIn) {
      _userId = await _authService.getUserId(); // Retrieve userId if logged in
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _errorMessage = null;
    try {
      // Call the loginUser function
      // Call the loginUser function
      final response = await loginUser(email, password);
      // Extract token and userId from the response
      final token = response['token'];
      final userId = response['userId'];

      // Save the token and userId
      await _authService.saveAuthToken(token);
      await _authService.saveUserId(userId);

      // Update the provider state
      _isLoggedIn = true;
      _userId = userId;
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
      // Call the registerUser function
      final response =
          await registerUser(email, password, name, lastName, consent);

      // Extract token, userId, and role from the response
      final token = response['token'];

      // Save the token and userId
      await _authService.saveAuthToken(token);

      // Set _isLoggedIn to true
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> logout() async {
    await _authService.clearAuthToken();
    _isLoggedIn = false;
    notifyListeners();
  }
}
