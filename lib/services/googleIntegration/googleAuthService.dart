import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in_web/web_only.dart';

import '../authService.dart';
import '../../utils/apiClient.dart';
import '../../config/envVarConfig.dart';

class GoogleAuthService {
  late final ApiClient _apiClient;
  late final AuthService _authService;

  GoogleAuthService() {
    _apiClient = ApiClient();
    _authService = AuthService();
  }

  GoogleAuthService.test(this._apiClient, this._authService);

  Future<String?> requestServerAuthenticatioinCode() async {
    try {
      return await requestServerAuthCode().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Google auth timed out'),
      );
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