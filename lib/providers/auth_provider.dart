import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import '../data/login_user.dart';
import '../data/register_user.dart';

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

  Future<void> register(String email, String password, String name,
      String lastName, bool consent) async {
    try {
      // Call the registerUser function
      final response =
          await registerUser(email, password, name, lastName, consent);

      // Extract token, userId, and role from the response
      final token = response['token'];
      // final userId = response['userId'];
      // final role = response['role'];

      // Save the token and userId
      await _authService.saveAuthToken(token);
      // await _authService.saveUserId(userId);
      // await _authService.saveRole(role);

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
