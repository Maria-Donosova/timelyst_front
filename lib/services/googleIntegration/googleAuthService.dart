import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart' as gsi;


import '../authService.dart';
import '../../utils/apiClient.dart';
import '../../config/envVarConfig.dart';
import 'google_sign_in_singleton.dart';
import '../../models/calendars.dart';
import '../../utils/timezoneUtils.dart';

class GoogleAuthService {
  late final ApiClient _apiClient;
  late final AuthService _authService;
  final gsi.GoogleSignIn _googleSignIn;

  GoogleAuthService({gsi.GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignInSingleton().googleSignIn,
        _apiClient = ApiClient(),
        _authService = AuthService();

  GoogleAuthService.test(this._apiClient, this._authService, this._googleSignIn);

  Future<String?> requestServerAuthenticationCode() async {
    try {
      // Ensure we sign out first to force a fresh sign-in and get a new auth code
      await _googleSignIn.signOut();
      
      // Use signIn() which handles the flow based on configuration (forceCodeForRefreshToken: true)
      final gsi.GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        print('⚠️ [GoogleAuthService] Sign-in aborted by user');
        return null;
      }

      final authCode = account.serverAuthCode;
      final maskedCode = (authCode?.length ?? 0) > 10 ? '${authCode?.substring(0, 10)}...' : authCode;
      print('✅ [GoogleAuthService] Obtained server auth code: $maskedCode');
      
      return authCode;
    } catch (e, stackTrace) {
      print('❌ [GoogleAuthService] Error requesting auth code: $e');
      rethrow;
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      final gsi.GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
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