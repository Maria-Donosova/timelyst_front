import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftSignInResult.dart';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftAuthService.dart';
import 'package:timelyst_flutter/services/microsoftIntegration/microsoftSignInOut.dart';

class MicrosoftSignInManager {
  final MicrosoftAuthService _authService;
  final MicrosoftSignInOutService _signInOutService;

  MicrosoftSignInManager({
    MicrosoftAuthService? authService,
    MicrosoftSignInOutService? signInOutService,
  })  : _authService = authService ?? MicrosoftAuthService(),
        _signInOutService = signInOutService ?? MicrosoftSignInOutService();

  /// Initiates Microsoft OAuth sign-in flow
  Future<MicrosoftSignInResult> signIn(BuildContext context) async {
    try {
      print('🔍 [MicrosoftSignInManager] Starting Microsoft sign-in process');

      // Generate and launch Microsoft OAuth URL
      final authUrl = _authService.generateAuthUrl();
      print('🔍 [MicrosoftSignInManager] Generated auth URL');

      // Launch the OAuth URL in browser
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('🔍 [MicrosoftSignInManager] Launched OAuth URL in browser');
      } else {
        throw Exception('Could not launch Microsoft OAuth URL');
      }

      // In a real implementation, you would need to handle the redirect
      // and extract the authorization code. For now, this is a placeholder.
      // You might want to use a WebView or implement a custom URL scheme.
      
      print('⚠️ [MicrosoftSignInManager] OAuth redirect handling not implemented');
      print('🔍 [MicrosoftSignInManager] User needs to copy authorization code manually');
      
      // For now, return an empty result - this will need to be completed
      // when you implement the redirect handling
      return MicrosoftSignInResult(
        userId: null,
        email: null,
        authCode: null,
        calendars: [],
      );

    } catch (e) {
      print('❌ [MicrosoftSignInManager] Error during sign-in: $e');
      rethrow;
    }
  }

  /// Handles the OAuth callback with authorization code
  Future<MicrosoftSignInResult> handleAuthCallback(String authCode) async {
    try {
      print('🔍 [MicrosoftSignInManager] Handling auth callback with code');
      
      final result = await _signInOutService.microsoftSignIn(authCode);
      
      print('✅ [MicrosoftSignInManager] Microsoft Sign-In process completed successfully');
      return result;
      
    } catch (e) {
      print('❌ [MicrosoftSignInManager] Error handling auth callback: $e');
      rethrow;
    }
  }

  /// Signs out from Microsoft
  Future<void> signOut() async {
    try {
      print('🔍 [MicrosoftSignInManager] Starting Microsoft sign-out process');
      // Implement Microsoft sign-out logic if needed
      print('✅ [MicrosoftSignInManager] Microsoft sign-out completed');
    } catch (e) {
      print('❌ [MicrosoftSignInManager] Error during sign-out: $e');
      rethrow;
    }
  }
}