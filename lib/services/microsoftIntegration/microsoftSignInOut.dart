import 'dart:async';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftSignInResult.dart';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftAuthService.dart';
import 'package:timelyst_flutter/services/authService.dart';

class MicrosoftSignInOutService {
  late final MicrosoftAuthService _microsoftAuthService;
  late final AuthService _authService;

  MicrosoftSignInOutService({
    MicrosoftAuthService? microsoftAuthService,
    AuthService? authService,
  })  : _microsoftAuthService = microsoftAuthService ?? MicrosoftAuthService(),
        _authService = authService ?? AuthService();

  /// Handles Microsoft sign-in with authorization code
  Future<MicrosoftSignInResult> microsoftSignIn(String authCode) async {
    print('🔍 [MicrosoftSignInOutService] Starting Microsoft sign-in with auth code');
    print('🔍 [MicrosoftSignInOutService] Auth code length: ${authCode.length}');

    try {
      // Send auth code to backend for token exchange
      final response = await _microsoftAuthService.sendAuthCodeToBackend(authCode);

      print('🔍 [MicrosoftSignInOutService] Received response from MicrosoftAuthService');
      print('🔍 [MicrosoftSignInOutService] Response success: ${response['success']}');
      
      if (response['success']) {
        // Get userId from stored auth token instead of backend response  
        final userId = await _authService.getUserId();
        
        // Try multiple possible locations for email in the response
        final email = response['email'] ?? 
                     response['data']?['email'] ?? 
                     response['data']?['microsoftEmail'];
        final calendars = response['calendars'];
        
        print('✅ [MicrosoftSignInOutService] Microsoft Sign-In successful');
        print('🔍 [MicrosoftSignInOutService] User ID: $userId');
        print('🔍 [MicrosoftSignInOutService] User email: $email');
        print('🔍 [MicrosoftSignInOutService] Email from response["email"]: ${response['email']}');
        print('🔍 [MicrosoftSignInOutService] Email from response["data"]["email"]: ${response['data']?['email']}');
        print('🔍 [MicrosoftSignInOutService] Email from response["data"]["microsoftEmail"]: ${response['data']?['microsoftEmail']}');
        print('🔍 [MicrosoftSignInOutService] Number of calendars: ${calendars?.length ?? 0}');
        
        return MicrosoftSignInResult(
          userId: userId ?? '',
          email: email ?? '',
          authCode: authCode,
          calendars: calendars,
        );
      } else {
        final errorMessage = response['message'] ?? 'Unknown error occurred';
        print('❌ [MicrosoftSignInOutService] Microsoft Sign-In failed: $errorMessage');
        throw Exception('Microsoft authentication failed: $errorMessage');
      }
    } catch (e) {
      print('❌ [MicrosoftSignInOutService] Exception during Microsoft sign-in: $e');
      rethrow;
    }
  }

  /// Signs out from Microsoft (if needed)
  Future<void> microsoftSignOut() async {
    try {
      print('🔍 [MicrosoftSignInOutService] Starting Microsoft sign-out');
      // Implement Microsoft-specific sign-out logic if needed
      // This might involve revoking tokens or clearing local state
      print('✅ [MicrosoftSignInOutService] Microsoft sign-out completed');
    } catch (e) {
      print('❌ [MicrosoftSignInOutService] Error during Microsoft sign-out: $e');
      rethrow;
    }
  }
}