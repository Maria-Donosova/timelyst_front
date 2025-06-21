import 'package:timelyst_flutter/services/authService.dart';

class MockAuthService implements AuthService {
  bool _isLoggedIn = false;
  String? _userId;

  @override
  Future<void> clearAuthToken() async {
    // Simulate clearing the token
  }

  @override
  Future<void> clearUserId() async {
    _userId = null;
  }

  @override
  Future<String?> getAuthToken() async {
    return null;
  }

  @override
  Future<String?> getUserId() async {
    return _userId;
  }

  @override
  Future<bool> isLoggedIn() async {
    return _isLoggedIn;
  }

  @override
  Future<void> saveAuthToken(String token) async {
    // Simulate saving the token
  }

  @override
  Future<void> saveUserId(String userId) async {
    _userId = userId;
  }

  // Helper method for testing
  void setLoginState(bool isLoggedIn, {String? userId}) {
    _isLoggedIn = isLoggedIn;
    _userId = userId;
  }
}
