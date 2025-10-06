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

      // Generate and launch Microsoft OAuth URL
      final authUrl = _authService.generateAuthUrl();

      // Launch the OAuth URL in browser
      final uri = Uri.parse(authUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Microsoft OAuth URL');
      }

      // In a real implementation, you would need to handle the redirect
      // and extract the authorization code. For now, this is a placeholder.
      // You might want to use a WebView or implement a custom URL scheme.
      
      print('⚠️ [MicrosoftSignInManager] OAuth redirect handling not implemented');
      
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
      
      final result = await _signInOutService.microsoftSignIn(authCode);
      
      return result;
      
    } catch (e) {
      print('❌ [MicrosoftSignInManager] Error handling auth callback: $e');
      rethrow;
    }
  }

  /// Signs out from Microsoft
  Future<void> signOut() async {
    try {
      // Implement Microsoft sign-out logic if needed
    } catch (e) {
      print('❌ [MicrosoftSignInManager] Error during sign-out: $e');
      rethrow;
    }
  }
}