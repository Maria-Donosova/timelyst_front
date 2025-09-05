import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../../config/envVarConfig.dart';
import 'package:timelyst_flutter/services/googleIntegration/google_sign_in_result.dart';
import 'googleAuthService.dart';

class GoogleSignInOutService {
  late GoogleSignIn _googleSignIn;
  late final GoogleAuthService _googleAuthService;

  GoogleSignInOutService({GoogleSignIn? googleSignIn, GoogleAuthService? googleAuthService}) {
    _googleAuthService = googleAuthService ?? GoogleAuthService();
  }

  List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'https://www.googleapis.com/auth/calendar',
  ];

  void initialize() {
    if (kIsWeb) {
      final clientId = Config.googleClientId;
      if (clientId == null) {
        throw Exception(
            'Google Client ID is not configured. Please set the CLIENT_ID environment variable.');
      }
      _googleSignIn = GoogleSignIn(
        clientId: clientId,
        forceCodeForRefreshToken: true,
        scopes: _scopes,
      );
    } else {
      _googleSignIn = GoogleSignIn(
        forceCodeForRefreshToken: true,
        scopes: _scopes,
      );
    }
  }

  Future<GoogleSignInResult> googleSignIn() async {
    try {
      final serverAuthCode = await _googleAuthService.requestServerAuthenticatioinCode();

      if (serverAuthCode != null) {
        final response =
            await _googleAuthService.sendAuthCodeToBackend(serverAuthCode);

        if (response['success']) {
          return GoogleSignInResult(
            userId: response['data']['userId'],
            email: response['email'],
          );
        } else {
          throw GoogleSignInException(
              'Error from backend: ${response['message']}');
        }
      } else {
        throw GoogleSignInException('Failed to get auth code from Google');
      }
    } on TimeoutException {
      throw GoogleSignInException('Google Sign-In timed out');
    } catch (error) {
      if (error is GoogleSignInException) {
        rethrow;
      }
      throw GoogleSignInException('Error during web sign-in: $error');
    }
  }

  Future<void> googleDisconnect() async {
    try {
      await _googleSignIn.disconnect();
    } catch (e) {
      throw GoogleSignInException('Error disconnecting Google account: $e');
    }
  }

  Future<void> googleSignOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      throw GoogleSignInException('Google sign-out failed: $e');
    }
  }
}
