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
      
      // Use requestServerAuthCode() which is the correct method for web with GIS
      // We cast to dynamic because the method might not be statically available in all versions/platforms
      // but we know it exists for web with the correct package version.
      // However, to be safe and avoid the previous NoSuchMethodError if the package version is weird,
      // we can try to use it directly if the type allows, or keep the dynamic cast but ensure the package is correct.
      // Given the user's error "NoSuchMethodError: method not found: 'requestServerAuthCode'", 
      // it implies the method WAS NOT on the object. 
      // But with the GIS script, the underlying JS should work. 
      // The Dart method `requestServerAuthCode` MUST exist on `GoogleSignIn` for this to compile/run.
      // If it doesn't exist on the Dart class, we can't call it.
      // Let's check if we can use the `google_sign_in_web` specific implementation or if it's exposed on the main plugin.
      // Actually, `requestServerAuthCode` IS exposed on `GoogleSignIn` in newer versions.
      // Let's try calling it directly without cast first.
      
      final authCode = await _googleSignIn.requestServerAuthCode();
      
      if (authCode == null) {
        print('⚠️ [GoogleAuthService] Sign-in aborted by user');
        return null;
      }

      final maskedCode = (authCode.length) > 10 ? '${authCode.substring(0, 10)}...' : authCode;
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