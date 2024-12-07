import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// import 'package:http/http.dart' as http;

import 'package:google_sign_in/google_sign_in.dart';
import '../service/google_auth_service.dart';

import '../config/env_variables_config.dart';

// GoogleSignInService class to handle Google sign-in and sign-out operations using the GoogleSignIn plugin (web implementation).
class GoogleConnectService {
  final GoogleSignIn _googleSignIn = (kIsWeb)
      ? GoogleSignIn(
          clientId: Config.clientId,
          forceCodeForRefreshToken: true,
          scopes: _scopes,
        )
      : GoogleSignIn(
          forceCodeForRefreshToken: true,
          scopes: _scopes,
        );

  static const List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'https://www.googleapis.com/auth/peopleapi.readonly',
    'https://www.googleapis.com/auth/calendar',
  ];

  GoogleAuthService _googleAuthService = GoogleAuthService();

  Future<String> googleSignIn(BuildContext context) async {
    print("entering googleSignIn");
    if (kIsWeb) {
      print("kIsWeb is true");
      try {
        // if (await _googleSignIn.isSignedIn()) {
        final user = _googleSignIn.currentUser;
        print("User: $user");
        String email = _googleSignIn.currentUser!.email;
        print("User emaail: $email");
        final serverAuthCode =
            await _googleAuthService.requestServerAuthenticatioinCode();
        print("Server Auth Code: $serverAuthCode");

        if (serverAuthCode != null) {
          final tokenResponse =
              await _googleAuthService.exchangeCodeForTokens(serverAuthCode);

          if (tokenResponse != null) {
            final accessToken = tokenResponse['access_token'];
            final idToken = tokenResponse['id_token'];
            final refreshtoken = tokenResponse['refresh_token'];
            print("Google Account: ${user?.email}");
            print("Access Token: $accessToken");
            print("ID Token: $idToken");
            print("Refresh Token: $refreshtoken");
            _googleAuthService.sendTokensToBackend(
                idToken, accessToken, refreshtoken);
            showAboutDialog(context: context, children: [
              Text('Successful Google authentication'),
            ]);
            //print("Google Account logged in successfully: $googleAccount");
            return "Google Account logged in successfully";
            //googleAccount;
          } else {
            showAboutDialog(context: context, children: [
              Text('Google authentication via SignIn failed'),
            ]);
            return "Failed to obtain tokens using SignIn";
          }
        }
        // }
      } catch (error) {
        print('Error during web sign-in: $error');
        return 'Error during web sign-in: $error';
      }
    } else {
      try {
        GoogleSignInAccount? account = await _googleSignIn.signIn();

        if (account != null) {
          GoogleSignInAuthentication auth = await account.authentication;
          print("Google Account: ${account.email}");
          print("Id token : ${auth.idToken}");
          print("Access token: ${auth.accessToken}");
          String? serverAuthCode = account.serverAuthCode;
          print("Server Auth Code: $serverAuthCode");

          if (serverAuthCode != null) {
            final tokenResponse =
                await _googleAuthService.exchangeCodeForTokens(serverAuthCode);

            if (tokenResponse != null) {
              final accessToken = tokenResponse['access_token'];
              final idToken = tokenResponse['id_token'];
              final refreshtoken = tokenResponse['refresh_token'];
              final googleAccount = account.email;

              print("Access Token: $accessToken");
              print("ID Token: $idToken");
              print("Refresh Token: $refreshtoken");
              print("Success");
              return googleAccount;
            } else {
              print("Failed to obtain tokens");
              return 'Failed to obtain tokens';
            }
          }
        }
      } catch (error) {
        print(error);
        return 'Error: $error';
      }
    }
    return 'Regular sign-in failed';
  }

  // google sign out method
  Future<String> googleSignOut(BuildContext context) async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      await _googleAuthService.clearTokensOnBackend();
      //await storage.deleteAll();
      if (_googleSignIn.currentUser == null) {
        print("User is signed out");
        return "User is signed out";
      } else {
        print("Sign out failed");
        return "Sign out failed";
      }
    } catch (e) {
      print(e);
      return "Error: $e";
    }
  }
}
