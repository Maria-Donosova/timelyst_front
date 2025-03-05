import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _authTokenKey = 'authToken';
  static const String _userIdKey = 'userId';
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

  // Save userId
  Future<void> saveUserId(String userId) async {
    print("Entering saveUserId, userId: $userId");
    try {
      await _storage.write(key: _userIdKey, value: userId);
      print("UserId saved successfully");
    } catch (e) {
      print('Error saving userId: $e');
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

  // Get userId
  Future<String?> getUserId() async {
    print("Entering getUserId, key: $_userIdKey");
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      print('Error reading userId: $e');
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

  // Clear userId
  Future<void> clearUserId() async {
    print("Entering clearUserId");
    try {
      await _storage.delete(key: _userIdKey);
      print("User ID cleared");
    } catch (e) {
      print('Error clearing userId: $e');
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
