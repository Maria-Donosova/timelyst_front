import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';


import '../authService.dart';
import '../../utils/apiClient.dart';
import '../../config/envVarConfig.dart';
import 'google_sign_in_singleton.dart';
import '../../models/calendars.dart';
import '../../utils/timezoneUtils.dart';

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
      await _googleSignIn.signOut();
      final authCode = await _googleSignIn.requestServerAuthCode();
      final maskedCode = (authCode?.length ?? 0) > 10 ? '${authCode?.substring(0, 10)}...' : authCode;
      return authCode;
    } catch (e, stackTrace) {
      print('❌ [GoogleAuthService] Error requesting auth code: $e');
      rethrow;
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      final GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
      if (currentUser != null) {
        return currentUser.email;
      } else {
        print('⚠️ [GoogleAuthService] No current user found');
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ [GoogleAuthService] Error getting user email: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>> sendAuthCodeToBackend(String authCode) async {
    try {
      final authToken = await _authService.getAuthToken();
      
      final body = {
        'code': authCode,
      };

      final response = await _apiClient.post(
        Config.backendGoogleConnect,
        body: body,
        token: authToken,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        return {
          'success': true,
          'message': responseData['message'] ?? 'Google account connected',
        };
      } else {
        print('❌ [GoogleAuthService] Backend request failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to connect Google account: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ [GoogleAuthService] Exception in sendAuthCodeToBackend: $e');
      return {
        'success': false,
        'message': 'Failed to connect Google account: $e',
      };
    }
  }
}