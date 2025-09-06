import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:timelyst_flutter/services/googleIntegration/google_sign_in_result.dart';
import 'googleAuthService.dart';
import 'google_sign_in_singleton.dart';

class GoogleSignInOutService {
  final GoogleSignIn _googleSignIn;
  late final GoogleAuthService _googleAuthService;

  GoogleSignInOutService({GoogleSignIn? googleSignIn, GoogleAuthService? googleAuthService})
      : _googleSignIn = googleSignIn ?? GoogleSignInSingleton().googleSignIn,
        _googleAuthService = googleAuthService ?? GoogleAuthService();

  Future<GoogleSignInResult> googleSignIn(String serverAuthCode) async {
    try {
      final response =
          await _googleAuthService.sendAuthCodeToBackend(serverAuthCode);

      if (response['success']) {
        return GoogleSignInResult(
          userId: response['data']['userId'],
          email: response['email'],
          authCode: serverAuthCode,
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
