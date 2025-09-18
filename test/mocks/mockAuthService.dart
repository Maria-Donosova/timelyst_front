import 'package:timelyst_flutter/services/authService.dart';

class MockAuthService implements AuthService {
  final Map<String, String> _storage = {};

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (email == 'test@test.com' && password == 'password') {
      final userId = '123';
      final token = 'mock_token';
      await saveAuthToken(token);
      await saveUserId(userId);
      return {'token': token, 'userId': userId, 'role': 'user'};
    } else {
      throw Exception('Invalid credentials');
    }
  }

  @override
  Future<Map<String, dynamic>> register(String email, String password,
      String name, String lastName, bool consent) async {
    final userId = '456';
    final token = 'mock_token_reg';
    await saveAuthToken(token);
    await saveUserId(userId);
    return {'token': token, 'userId': userId, 'role': 'user'};
  }

  @override
  Future<void> clearAuthToken() async {
    _storage.remove('authToken');
  }

  @override
  Future<void> clearUserId() async {
    _storage.remove('userId');
  }

  @override
  Future<String?> getAuthToken() async {
    return _storage['authToken'];
  }

  @override
  Future<String?> getUserId() async {
    return _storage['userId'];
  }

  @override
  Future<bool> isLoggedIn() async {
    return _storage.containsKey('authToken');
  }

  @override
  Future<void> saveAuthToken(String token) async {
    _storage['authToken'] = token;
  }

  @override
  Future<void> saveUserId(String userId) async {
    _storage['userId'] = userId;
  }

  @override
  Future<String?> getUserEmail() async {
    return _storage['userEmail'];
  }

  @override
  Future<void> saveUserEmail(String email) async {
    _storage['userEmail'] = email;
  }

  @override
  Future<void> clearUserEmail() async {
    _storage.remove('userEmail');
  }

  @override
  Future<void> logout() async {
    _storage.clear();
  }

  // Helper method for testing
  void setLoginState(bool isLoggedIn, {String? userId, String? token}) {
    if (isLoggedIn) {
      _storage['authToken'] = token ?? 'mock_token';
      if (userId != null) {
        _storage['userId'] = userId;
      }
    } else {
      _storage.clear();
    }
  }
}
