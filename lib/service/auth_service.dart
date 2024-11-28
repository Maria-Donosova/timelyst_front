import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _authTokenKey = 'authToken';
  //static const String _refreshTokenKey = 'refreshToken';

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Methods for managing the authentication token
  Future<void> saveAuthToken(String token) async {
    try {
      await _storage.write(key: _authTokenKey, value: token);
    } catch (e) {
      print('Error saving auth token: $e');
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      print('Error reading auth token: $e');
      return null;
    }
  }

  Future<void> clearAuthToken() async {
    try {
      await _storage.delete(key: _authTokenKey);
    } catch (e) {
      print('Error clearing auth token: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await getAuthToken();
      print('getAuthToken: $token');
      return token != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Methods for managing the refresh token
  // Future<void> saveRefreshToken(String refreshToken) async {
  //   try {
  //     await _storage.write(key: _refreshTokenKey, value: refreshToken);
  //   } catch (e) {
  //     print('Error saving refresh token: $e');
  //     rethrow;
  //   }
  // }

  // Future<String?> getRefreshToken() async {
  //   try {
  //     return await _storage.read(key: _refreshTokenKey);
  //   } catch (e) {
  //     print('Error reading refresh token: $e');
  //     return null;
  //   }
  // }
}
