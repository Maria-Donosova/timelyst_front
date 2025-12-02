import 'dart:async';
import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart' as gsi;
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart' as gsi_platform;


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
      
      // Try to get the code using the platform interface directly, as the wrapper method might be missing
      // in some versions or on some platforms.
      // This is specifically for the web GIS flow where signIn() returns null code.
      try {
        // We need to cast to dynamic because we can't be 100% sure of the platform interface version
        // at compile time without checking pubspec.lock, and we want to avoid compilation errors.
        // The user claims requestServerAuthCode is the correct method.
        final platform = gsi_platform.GoogleSignInPlatform.instance;
        final authCode = await (platform as dynamic).requestServerAuthCode();
        
        if (authCode != null) {
          final maskedCode = (authCode.length) > 10 ? '${authCode.substring(0, 10)}...' : authCode;
          print('✅ [GoogleAuthService] Obtained server auth code via Platform Interface: $maskedCode');
          return authCode;
        }
      } catch (e) {
        print('⚠️ [GoogleAuthService] Failed to call requestServerAuthCode on platform interface: $e');
      }

      // Fallback to signIn() if the above fails or returns null
      print('ℹ️ [GoogleAuthService] Falling back to signIn()');
      final gsi.GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      if (account == null) {
        print('⚠️ [GoogleAuthService] Sign-in aborted by user');
        return null;
      }

      final authCode = account.serverAuthCode;
      final maskedCode = (authCode?.length ?? 0) > 10 ? '${authCode?.substring(0, 10)}...' : authCode;
      
      if (authCode == null) {
        print('⚠️ [GoogleAuthService] Sign-in successful but serverAuthCode is null. Check if GIS script is present and forceCodeForRefreshToken is true.');
      } else {
        print('✅ [GoogleAuthService] Obtained server auth code via signIn: $maskedCode');
      }
      
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
          if (responseData is Map<String, dynamic>) ...responseData,
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