import 'package:flutter/material.dart';
import '../service/google_auth_service.dart';
import '../data/login_user.dart';
import '../data/register_user.dart';

class GoogleAuthProvider with ChangeNotifier {
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> checkAuthState() async {
    _isLoggedIn = await _googleAuthService.isLoggedIn();
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _errorMessage = null; // Clear any previous error message
    try {
      // Call the loginUser function
      await loginUser(email, password);

      // Assuming loginUser stores the token and sets _isLoggedIn to true
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
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
      await _googleAuthService.saveAuthToken(token);

      // Set _isLoggedIn to true
      _isLoggedIn = true;
      notifyListeners();
    } catch (e) {
      print('Error during registration: $e');
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> logout() async {
    await _googleAuthService.clearAuthToken();
    _isLoggedIn = false;
    notifyListeners();
  }
}
