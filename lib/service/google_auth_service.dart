import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GoogleAuthService {
  static const String _googleAccount = 'google_account';
  static const String _accessToken = 'access_token';
  static const String _idToken = 'id_token';
  static const String _refreshToken = 'refreshToken';

  static const String _serverAuthCode = 'server_auth_code';

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Methods for managing the authentication token
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: _accessToken, value: token);
    } catch (e) {
      print('Error saving auth token: $e');
      rethrow;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessToken);
    } catch (e) {
      print('Error reading auth token: $e');
      return null;
    }
  }

  Future<void> clearAccessToken() async {
    try {
      await _storage.delete(key: _accessToken);
    } catch (e) {
      print('Error clearing auth token: $e');
      rethrow;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
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
