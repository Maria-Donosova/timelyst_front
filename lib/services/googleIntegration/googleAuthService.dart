import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web_only;

import '../authService.dart';
import '../../utils/apiClient.dart';
import '../../config/envVarConfig.dart';
import 'google_sign_in_singleton.dart';
import '../../models/calendars.dart';

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
      print('🔍 [GoogleAuthService] Starting server auth code request...');
      print('🔍 [GoogleAuthService] GoogleSignIn scopes: ${_googleSignIn.scopes}');
      final authCode = await web_only.requestServerAuthCode();
      final maskedCode = (authCode?.length ?? 0) > 10 ? '${authCode?.substring(0, 10)}...' : authCode;
      print('✅ [GoogleAuthService] Server auth code received successfully: $maskedCode');
      return authCode;
    } catch (e, stackTrace) {
      print('❌ [GoogleAuthService] Error requesting auth code: $e');
      print('🔍 [GoogleAuthService] Stack trace: $stackTrace');
      print('🔍 [GoogleAuthService] Error type: ${e.runtimeType}');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendAuthCodeToBackend(String authCode) async {
    try {
      print('🔍 [GoogleAuthService] Starting to send auth code to backend...');
      print('🔍 [GoogleAuthService] Backend URL: ${Config.backendGoogleCalendar}');
      
      final authToken = await _authService.getAuthToken();
      final maskedToken = (authToken?.length ?? 0) > 10 ? '${authToken?.substring(0, 10)}...' : authToken;
      print('🔍 [GoogleAuthService] Auth token obtained: $maskedToken');
      
      final body = {
        'code': authCode,
      };
      print('🔍 [GoogleAuthService] Request body prepared with auth code');

      final response = await _apiClient.post(
        Config.backendGoogleCalendar,
        body: body,
        token: authToken,
      );
      
      print('🔍 [GoogleAuthService] Backend response status code: ${response.statusCode}');
      print('🔍 [GoogleAuthService] Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ [GoogleAuthService] Backend response successful');
        print('🔍 [GoogleAuthService] Response data keys: ${responseData.keys.toList()}');
        print('🔍 [GoogleAuthService] User email: ${responseData['email']}');
        print('🔍 [GoogleAuthService] User ID: ${responseData['userId']}');
        
        // Extract calendars from the unified response
        List<Calendar> calendars = [];
        if (responseData['calendars'] != null) {
          final calendarsData = responseData['calendars'] as List;
          print('🔍 [GoogleAuthService] Found ${calendarsData.length} calendars in response');
          calendars = calendarsData
              .map((json) => Calendar.fromGoogleJson(json))
              .toList();
          print('🔍 [GoogleAuthService] Parsed ${calendars.length} calendar objects');
        } else {
          print('⚠️ [GoogleAuthService] No calendars found in backend response');
          print('🔍 [GoogleAuthService] Available response fields: ${responseData.keys.toList()}');
        }

        return {
          'success': true,
          'message': 'Auth code sent to backend successfully',
          'email': responseData['email'],
          'data': responseData,
          'calendars': calendars,
        };
      } else {
        final errorData = jsonDecode(response.body);
        print('❌ [GoogleAuthService] Backend request failed with status: ${response.statusCode}');
        print('🔍 [GoogleAuthService] Error response: $errorData');
        return {
          'success': false,
          'message':
              'Failed to send Auth code to backend: ${response.statusCode}',
          'error': errorData,
        };
      }
    } catch (e, stackTrace) {
      print('❌ [GoogleAuthService] Exception in sendAuthCodeToBackend: $e');
      print('🔍 [GoogleAuthService] Exception type: ${e.runtimeType}');
      print('🔍 [GoogleAuthService] Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Failed to send Auth code to backend: $e',
      };
    }
  }
}