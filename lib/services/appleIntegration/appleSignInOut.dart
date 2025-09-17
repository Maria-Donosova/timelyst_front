import 'dart:async';
import 'package:timelyst_flutter/services/appleIntegration/appleSignInResult.dart';
import 'package:timelyst_flutter/services/appleIntegration/appleAuthService.dart';
import 'package:timelyst_flutter/services/authService.dart';

class AppleSignInOutService {
  late final AppleAuthService _appleAuthService;
  late final AuthService _authService;

  AppleSignInOutService({
    AppleAuthService? appleAuthService,
    AuthService? authService,
  })  : _appleAuthService = appleAuthService ?? AppleAuthService(),
        _authService = authService ?? AuthService();

  /// Handles Apple sign-in with authorization code
  Future<AppleSignInResult> appleSignIn(String authCode) async {
    print('🔍 [AppleSignInOutService] Starting Apple sign-in with auth code');
    print('🔍 [AppleSignInOutService] Auth code length: ${authCode.length}');

    try {
      // Send auth code to backend for token exchange
      final response = await _appleAuthService.sendAuthCodeToBackend(authCode);

      print('🔍 [AppleSignInOutService] Received response from AppleAuthService');
      print('🔍 [AppleSignInOutService] Response success: ${response['success']}');
      
      if (response['success']) {
        // Get userId from stored auth token instead of backend response  
        final userId = await _authService.getUserId();
        
        // Try multiple possible locations for email in the response
        final email = response['email'] ?? 
                     response['data']?['email'] ?? 
                     response['data']?['appleEmail'];
        final calendars = response['calendars'];
        
        print('✅ [AppleSignInOutService] Apple Sign-In successful');
        print('🔍 [AppleSignInOutService] User ID: $userId');
        print('🔍 [AppleSignInOutService] User email: $email');
        print('🔍 [AppleSignInOutService] Email from response["email"]: ${response['email']}');
        print('🔍 [AppleSignInOutService] Email from response["data"]["email"]: ${response['data']?['email']}');
        print('🔍 [AppleSignInOutService] Email from response["data"]["appleEmail"]: ${response['data']?['appleEmail']}');
        print('🔍 [AppleSignInOutService] Number of calendars: ${calendars?.length ?? 0}');
        
        return AppleSignInResult(
          userId: userId ?? '',
          email: email ?? '',
          authCode: authCode,
          calendars: calendars,
        );
      } else {
        final errorMessage = response['message'] ?? 'Unknown error occurred';
        print('❌ [AppleSignInOutService] Apple Sign-In failed: $errorMessage');
        throw Exception('Apple authentication failed: $errorMessage');
      }
    } catch (e) {
      print('❌ [AppleSignInOutService] Exception during Apple sign-in: $e');
      rethrow;
    }
  }

  /// Signs out from Apple (if needed)
  Future<void> appleSignOut() async {
    try {
      print('🔍 [AppleSignInOutService] Starting Apple sign-out');
      // Implement Apple-specific sign-out logic if needed
      // This might involve revoking tokens or clearing local state
      print('✅ [AppleSignInOutService] Apple sign-out completed');
    } catch (e) {
      print('❌ [AppleSignInOutService] Error during Apple sign-out: $e');
      rethrow;
    }
  }
}