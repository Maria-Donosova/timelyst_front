import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in_web/web_only.dart';

import '../config/env_variables_config.dart';

import 'package:http/http.dart' as http;

class GoogleAuthService {
  // static const String _accessToken = 'access_token';
  // static const String _idToken = 'id_token';
  // static const String _refreshToken = 'refreshToken';
  // static const String _serverAuthCode = 'server_auth_code';

  // final FlutterSecureStorage _storage = FlutterSecureStorage();

  // // Methods for managing the access token
  // Future<void> saveAccessTokenStorage(String token) async {
  //   try {
  //     await _storage.write(key: _accessToken, value: token);
  //   } catch (e) {
  //     print('Error saving auth token: $e');
  //     rethrow;
  //   }
  // }

  // Future<String?> getAccessTokenStorage() async {
  //   try {
  //     return await _storage.read(key: _accessToken);
  //   } catch (e) {
  //     print('Error reading auth token: $e');
  //     return null;
  //   }
  // }

  // Future<void> clearAccessTokenStorage() async {
  //   try {
  //     await _storage.delete(key: _accessToken);
  //   } catch (e) {
  //     print('Error clearing auth token: $e');
  //     rethrow;
  //   }
  // }

  // Methods that manage exchanges with googleapis

  // Method for requesting server authentication code
  Future<String?> requestServerAuthenticatioinCode() async {
    print("entering request server auth code");
    return requestServerAuthCode();
  }

  // // Method for exchanging server authentication code for tokens (inclduing access token, id token, and refresh token)
  // Future<Map<String, dynamic>?> exchangeCodeForTokens(String code) async {
  //   print("entering exchange code for tokens");
  //   print("Code is: $code");
  //   if (kIsWeb) {
  //     final response = await http.post(
  //       Uri.parse("${Config.googleOath2Token}"),
  //       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  //       body: {
  //         'code': code,
  //         'client_id': Config.clientId,
  //         'client_secret': Config.clientSecret,
  //         'redirect_uri': Config.redirectUri,
  //         'grant_type': 'authorization_code',
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       print("response body: ${response.body}");
  //       return jsonDecode(response.body);
  //     } else {
  //       print("Error: ${response.body}");
  //       return null;
  //     }
  //   } else {
  //     final response = await http.post(
  //       Uri.parse("${Config.googleOath2Token}"),
  //       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  //       body: {
  //         'code': code,
  //         'client_id': Config.clientId,
  //         'client_secret': Config.clientSecret,
  //         'redirect_uri': Config.redirectUri,
  //         'grant_type': 'authorization_code',
  //       },
  //     );
  //     print(response.body);
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       print("Error: ${response.body}");
  //       return null;
  //     }
  //   }
  // }

  // Future<String> requestLoggedInUserEmail(String accessToken) async {
  //   print("entering requestLoggedInUserEmail");
  //   final response = await http.get(
  //     Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo'),
  //     headers: {
  //       'Authorization': 'Bearer ${accessToken}',
  //     },
  //   );
  //   print("access token: $accessToken");

  //   if (response.statusCode == 200) {
  //     final userInfo = json.decode(response.body);
  //     String email = userInfo['email'];
  //     print('User Email: $email');
  //     return email;
  //   } else {
  //     print('Failed to get user info: ${response.statusCode}');
  //     return 'Failed to get user info: ${response.statusCode}';
  //   }
  // }

  Future<bool> isGoogleLoggedIn() async {
    try {
      print('Google Logged Out');
      return true;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // methods to manage exchanges with backend
  Future<void> sendAuthCodeToBackend(String authCode) async {
    print('Entering sendAuthCodeToBackend Future');
    print("Auth Code: $authCode");
    final response = await http.post(
      //Uri.parse('Config.backendGoogleCallback'),
      Uri.parse('http://localhost:3000/google/callback'),
      //Uri.parse('http://localhost:3000/graphql'),
      body: {
        'code': authCode,
      },
    );
    if (response.statusCode == 200) {
      print('Auth code sent to backend successfully');
    } else {
      print('Failed to send Auth code to backend: ${response.statusCode}');
    }
  }

  // // methods to manage exchanges with backend
  // Future<void> sendTokensToBackend(
  //     String idToken, String accessToken, String refreshToken) async {
  //   print('Entering sendAuthTokensToBackend Future');
  //   final response = await http.post(
  //     Uri.parse('Config.backendGoogleCallback'),
  //     //Uri.parse('http://localhost:3000/auth/google/callback'),
  //     body: {
  //       'id_token': idToken,
  //       'access_token': accessToken,
  //       'refresh_token': refreshToken,
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     print('Tokens sent to backend successfully');
  //   } else {
  //     print('Failed to send tokens to backend: ${response.statusCode}');
  //   }
  // }

  // Future<bool> clearTokensOnBackend() async {
  //   try {
  //     //final token = await getTokens();
  //     print('Tokens deleted');
  //     return true;
  //   } catch (e) {
  //     print('Error clearing tokens: $e');
  //     return false;
  //   }
  // }
}
