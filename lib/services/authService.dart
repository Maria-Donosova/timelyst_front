import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _authTokenKey = 'authToken';
  //static const String _refreshTokenKey = 'refreshToken';
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Methods for managing the authentication token
  Future<void> saveAuthToken(String token) async {
    print("Entering saveAuthToken, token: $token");
    try {
      await _storage.write(key: _authTokenKey, value: token);
      print("Token saved successfully");
      // Decode and log the token content
      final payload = Jwt.parseJwt(token);
      print("Token payload: $payload");
    } catch (e) {
      print('Error saving auth token: $e');
      rethrow;
    }
  }

  Future<String?> getAuthToken() async {
    print("Entering getAuthToken, key: $_authTokenKey");
    try {
      return await _storage.read(key: _authTokenKey);
    } catch (e) {
      print('Error reading auth token: $e');
      return null;
    }
  }

  Future<void> clearAuthToken() async {
    print("Entering clearAuthToken");
    try {
      await _storage.delete(key: _authTokenKey);
      print("Cleared");
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

  Future<String?> getUserIdFromToken() async {
    final token = await getAuthToken();
    if (token == null) return null;

    try {
      final payload = Jwt.parseJwt(token);
      // Check common user ID field names
      return payload['userId'] ??
          payload['sub'] ??
          payload['uid'] ??
          payload['user_id'];
    } catch (e) {
      print('Error decoding token: $e');
      return null;
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
