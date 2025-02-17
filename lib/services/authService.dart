import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const String _authTokenKey = 'authToken';
  //static const String _refreshTokenKey = 'refreshToken';

  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Methods for managing the authentication token
  Future<void> saveAuthToken(String token) async {
    print("Entering saveAuthToken, token: $token");
    try {
      await _storage.write(key: _authTokenKey, value: token);
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


// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:jwt_decode/jwt_decode.dart';

// class AuthService {
//   static const String _authTokenKey = 'authToken';
//   static const String _refreshTokenKey = 'refreshToken';
//   static final AuthService _instance = AuthService._internal();
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//   String? _cachedAuthToken;

//   factory AuthService() => _instance;
//   AuthService._internal();

//   Future<void> saveAuthToken(String authToken, String refreshToken) async {
//     try {
//       await _storage.write(key: _authTokenKey, value: authToken);
//       await _storage.write(key: _refreshTokenKey, value: refreshToken);
//       _cachedAuthToken = authToken;
//     } on PlatformException catch (e) {
//       debugPrint('Secure storage error: ${e.message}');
//       rethrow;
//     }
//   }

//   Future<String?> getAuthToken({bool forceRefresh = false}) async {
//     if (_cachedAuthToken != null && !forceRefresh) return _cachedAuthToken;

//     try {
//       final token = await _storage.read(key: _authTokenKey);
//       _cachedAuthToken = token;
//       return token;
//     } on PlatformException catch (e) {
//       debugPrint('Token read error: ${e.message}');
//       return null;
//     }
//   }

//   Future<bool> isLoggedIn() async {
//     final token = await getAuthToken();
//     if (token == null) return false;

//     try {
//       final payload = Jwt.parseJwt(token);
//       final exp = payload['exp'] as int?;
//       return exp == null || DateTime.now().millisecondsSinceEpoch < exp * 1000;
//     } catch (e) {
//       debugPrint('Token validation error: $e');
//       return false;
//     }
//   }

//   Future<void> logout() async {
//     try {
//       await _storage.deleteAll();
//       _cachedAuthToken = null;
//     } on PlatformException catch (e) {
//       debugPrint('Logout error: ${e.message}');
//       rethrow;
//     }
//   }

//   Future<String?> refreshToken() async {
//     try {
//       final refreshToken = await _storage.read(key: _refreshTokenKey);
//       // Implement your token refresh API call here
//       final newTokens = await AuthAPI.refreshToken(refreshToken);
//       await saveAuthToken(newTokens.accessToken, newTokens.refreshToken);
//       return newTokens.accessToken;
//     } catch (e) {
//       await logout();
//       return null;
//     }
//   }
// }