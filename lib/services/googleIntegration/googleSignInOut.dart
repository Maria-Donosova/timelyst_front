import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../../config/envVarConfig.dart';

import 'package:timelyst_flutter/services/googleIntegration/google_sign_in_result.dart';

import 'googleAuthService.dart';

class GoogleSignInOutService {
  static final GoogleSignInOutService _instance =
      GoogleSignInOutService._internal();
  factory GoogleSignInOutService() => _instance;
  GoogleSignInOutService._internal();

  late final GoogleSignIn _googleSignIn;

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
  // final GoogleSignIn _googleSignIn = (kIsWeb)
  //     ? GoogleSignIn(
  //         clientId: Config.clientId,
  //         forceCodeForRefreshToken: true,
  //         scopes: _scopes,
  //       )
  //     : GoogleSignIn(
  //         forceCodeForRefreshToken: true,
  //         scopes: _scopes,
  //       );

  // static const List<String> _scopes = <String>[
  //   'openid',
  //   'profile',
  //   'email',
  //   'https://www.googleapis.com/auth/peopleapi.readonly',
  //   'https://www.googleapis.com/auth/calendar',
  // ];

  GoogleAuthService _googleAuthService = GoogleAuthService();
  //ConnectedAccounts _connectedAccounts = ConnectedAccounts();

  Future<GoogleSignInResult> googleSignIn() async {
    // logger.i("entering googleSignIn");
    if (kIsWeb) {
      // logger.i("kIsWeb is true");
      try {
        final serverAuthCode = await _googleAuthService
            .requestServerAuthenticatioinCode()
            .timeout(const Duration(seconds: 30),
                onTimeout: () =>
                    throw TimeoutException('Google Sign-In timed out'));

        if (serverAuthCode != null) {
          final response =
              await _googleAuthService.sendAuthCodeToBackend(serverAuthCode);

          if (response['success']) {
            // logger.i('Success: ${response['message']}');
            // logger.i('User email: ${response['email']}');
            return GoogleSignInResult(
              userId: response['data']['userId'],
              email: response['email'],
            );
          } else {
            // logger.e('Error: ${response['message']}');
            throw GoogleSignInException(
                'Error from backend: ${response['message']}');
          }
        } else {
          // logger.e('Failed to get auth code from Google');
          throw GoogleSignInException('Failed to get auth code from Google');
        }
      } on TimeoutException {
        // logger.e('Google Sign-In timed out');
        throw GoogleSignInException('Google Sign-In timed out');
      } catch (error) {
        // logger.e('Error during web sign-in: $error');
        throw GoogleSignInException('Error during web sign-in: $error');
      }
    } else {
      // Mobile platform is not fully implemented, so I will leave it as it is for now.
      // I will add a comment to indicate that this part needs to be implemented.
      try {
        GoogleSignInAccount? account = await _googleSignIn.signIn();

        if (account != null) {
          GoogleSignInAuthentication auth = await account.authentication;
          // logger.i("Google Account: ${account.email}");
          // logger.i("Id token : ${auth.idToken}");
          // logger.i("Access token: ${auth.accessToken}");
          String? serverAuthCode = account.serverAuthCode;
          // logger.i("Server Auth Code: $serverAuthCode");
          // This part needs to be implemented to call the backend and get the userId
          throw UnimplementedError(
              'Mobile Google Sign-In is not fully implemented.');
        } else {
          throw GoogleSignInException(
              'Google Sign-In was cancelled by the user.');
        }
      } catch (error) {
        // logger.e(error);
        throw GoogleSignInException('An error occurred during Google Sign-In.');
      }
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
