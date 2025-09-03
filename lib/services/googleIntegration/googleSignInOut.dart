import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../../config/envVarConfig.dart';

import 'package:timelyst_flutter/services/googleIntegration/google_sign_in_result.dart';

import 'googleAuthService.dart';

class GoogleSignInOutService {
  late final GoogleSignIn _googleSignIn;
  late final GoogleAuthService _googleAuthService;

  GoogleSignInOutService({GoogleSignIn? googleSignIn, GoogleAuthService? googleAuthService}) {
    _googleAuthService = googleAuthService ?? GoogleAuthService();
  }

  List<String> _scopes = <String>[
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
      // _googleSignIn = GoogleSignIn(
      //   forceCodeForRefreshToken: true,
      //   scopes: _scopes,
      // );
    }
  }
  //ConnectedAccounts _connectedAccounts = ConnectedAccounts();

  Future<GoogleSignInResult> googleSignIn() async {
    try {
      final String? authCode = await _googleAuthService.requestServerAuthenticatioinCode();

      if (authCode == null) {
        throw GoogleSignInException('Failed to get auth code from Google.');
      }

      // After getting the auth code, the user is signed in. We can now get the email.
      final String? email = _googleSignIn.currentUser?.email;

      if (email == null) {
        throw GoogleSignInException('Could not retrieve email after sign-in.');
      }

      final response = await _googleAuthService.sendAuthCodeToBackend(authCode, email);

      if (response['success']) {
        return GoogleSignInResult(
          userId: response['data']['userId'],
          email: response['email'],
        );
      } else {
        throw GoogleSignInException(
            'Error from backend: ${response['message']}');
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

  // google sign out method
  Future<void> googleDisconnect() async {
    try {
      await _googleSignIn.disconnect();
      if (_googleSignIn.currentUser == null) {
        // logger.i("User is disconnected");
      } else {
        // logger.e("Disconnect failed");
        throw GoogleSignInException('Failed to disconnect Google account.');
      }
    } catch (e) {
      // logger.e(e);
      throw GoogleSignInException('Error disconnecting Google account: $e');
    }
  }

  // google sign out method
  Future<void> googleSignOut() async {
    try {
      await _googleSignIn.signOut();
      // logger.i("User signed out and cookies cleared");
    } catch (e) {
      // logger.e(e);
      throw GoogleSignInException('Google sign-out failed: $e');
    }
  }
}

      await _googleSignIn.signOut();
      // logger.i("User signed out and cookies cleared");
    } catch (e) {
      // logger.e(e);
      throw GoogleSignInException('Google sign-out failed: $e');
    }
  }
}
