import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';

import '../authService.dart';
import '../../utils/apiClient.dart';
import '../../config/envVarConfig.dart';
import 'google_sign_in_singleton.dart';

class GoogleAuthService {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignInSingleton().googleSignIn,
        _apiClient = ApiClient(),
        _authService = AuthService();

  GoogleAuthService.test(this._apiClient, this._authService, this._googleSignIn);

  Future<String?> requestServerAuthenticatioinCode() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      return googleAuth?.serverAuthCode;
    } catch (e) {
      print('Error requesting auth code: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendAuthCodeToBackend(String authCode) async {
    try {
      final body = {
        'code': authCode,
      };

      final response = await _apiClient.post(
        Config.backendGoogleCalendar,
        body: body,
        token: await _authService.getAuthToken(),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Auth code sent to backend successfully',
          'email': responseData['email'],
          'data': responseData,
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message':
              'Failed to send Auth code to backend: ${response.statusCode}',
          'error': errorData,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to send Auth code to backend',
      };
    }
  }
}