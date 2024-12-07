import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:google_sign_in/google_sign_in.dart';
import '../service/google_auth_service.dart';

import '../config/env_variables_config.dart';

// GoogleSignInAccount? _currentUser;
// GoogleSignInAccount get currentUser => _currentUser!;
// GoogleSignInService class to handle Google sign-in and sign-out operations using the GoogleSignIn plugin (web implementation).
class GoogleConnectService {
  final GoogleSignIn _googleSignIn = (kIsWeb)
      ? GoogleSignIn(
          clientId: Config.clientId,
          //"287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com",
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

  // google sign in silently method
  Future<String> googleSignInSilently(BuildContext context) async {
    print("Entering GoogleSignInSilently");
    try {
      GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signInSilently();
      if (googleSignInAccount != null) {
        print("Google Account: ${googleSignInAccount.email}");

        final serverAuthCode =
            await _googleAuthService.requestServerAuthenticatioinCode();
        print("Server Auth Code: $serverAuthCode");
        if (serverAuthCode != null) {
          final tokenResponse =
              await _googleAuthService.exchangeCodeForTokens(serverAuthCode);
          print("Token Response: $tokenResponse");

          if (tokenResponse != null) {
            final googleAccount = tokenResponse['email'];
            final accessToken = tokenResponse['access_token'];
            final idToken = tokenResponse['id_token'];
            final refreshtoken = tokenResponse['refresh_token'];
            print("Google Account: $googleAccount");
            print("Access Token: $accessToken");
            print("ID Token: $idToken");
            print("Refresh Token: $refreshtoken");
            _googleAuthService.sendTokensToBackend(
                idToken, accessToken, refreshtoken);
            showAboutDialog(context: context, children: [
              Text('Successful Google authentication via signInSilently'),
            ]);
            return googleAccount;
          } else {
            showAboutDialog(context: context, children: [
              Text('Google authentication via SignInSilently failed'),
            ]);
            print("Failed to obtain tokens via SignInSilently");
            return 'Failed to obtain tokens via SignInSilently';
          }
        }
      }
    } catch (error) {
      print('Error during web sign-in silently: $error');
      return 'Error during web sign-in silently: $error';
    }
    return 'Sign-in silently failed';
  }

  // implicit google sign in method
  Future<String> googleSignIn(BuildContext context) async {
    print("entering googleSignIn");
    if (kIsWeb) {
      try {
        GoogleSignInAccount? googleSignInAccount =
            await _googleSignIn.signInSilently();
        if (googleSignInAccount == null) {
          print("google account is null");
          // If silent sign-in fails, show the sign-in button
          googleSignInAccount = await _googleSignIn.signIn();
        }

        if (googleSignInAccount != null) {
          print("Google Account: ${googleSignInAccount.email}");

          final serverAuthCode =
              await _googleAuthService.requestServerAuthenticatioinCode();
          print("Server Auth Code: $serverAuthCode");
          if (serverAuthCode != null) {
            final tokenResponse =
                await _googleAuthService.exchangeCodeForTokens(serverAuthCode);
            print("Token Response: $tokenResponse");

            if (tokenResponse != null) {
              final googleAccount = tokenResponse['email'];
              final accessToken = tokenResponse['access_token'];
              final idToken = tokenResponse['id_token'];
              final refreshtoken = tokenResponse['refresh_token'];
              print("Google Account: $googleAccount");
              print("Access Token: $accessToken");
              print("ID Token: $idToken");
              print("Refresh Token: $refreshtoken");
              _googleAuthService.sendTokensToBackend(
                  idToken, accessToken, refreshtoken);
              showAboutDialog(context: context, children: [
                Text('Successful Google authentication'),
              ]);
              return googleAccount;
            } else {
              showAboutDialog(context: context, children: [
                Text('Google authentication via SignIn failed'),
              ]);
              print("Failed to obtain tokens using SignIn");
              return "Failed to obtain tokens using SignIn";
            }
          }
        }
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

  // Future<Map<String, dynamic>?> _exchangeCodeForTokens(String code) async {
  //   if (kIsWeb) {
  //     final response = await http.post(
  //       Uri.parse('Config.googleOath'),
  //       //Uri.parse('https://oauth2.googleapis.com/token'),
  //       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  //       body: {
  //         'code': code,
  //         'client_id': Config.clientId,
  //         //'287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com',
  //         'client_secret': Config.clientSecret,
  //         //'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',
  //         'redirect_uri': Config.redirectUri,
  //         //'http://localhost:7357',
  //         'grant_type': 'authorization_code',
  //       },
  //     );
  //     print(response.body);
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       print("Error: ${response.body}");
  //       return null;
  //     }
  //   } else {
  //     final response = await http.post(
  //       Uri.parse('Config.googleOath'),
  //       //Uri.parse('https://oauth2.googleapis.com/token'),
  //       headers: {'Content-Type': 'application/x-www-form-urlencoded'},
  //       body: {
  //         'code': code,
  //         'client_id': Config.clientId,
  //         'client_secret': Config.clientSecret,
  //         // 'client_id':
  //         //     '287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com',
  //         // 'client_secret': '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',
  //         'redirect_uri': Config.redirectUri,
  //         //'',
  //         'grant_type': 'authorization_code',
  //       },
  //     );
  //     print(response.body);
  //     if (response.statusCode == 200) {
  //       return jsonDecode(response.body);
  //     } else {
  //       print("Error: ${response.body}");
  //       return null;
  //     }
  //   }
  // }

  // Future<String?> requestServerAuthenticatioinCode() async {
  //   return requestServerAuthCode();
  // }

  // Future<void> sendAuthTokensToBackend(
  //     String idToken, String accessToken, String refreshToken) async {
  //   print('Entering sendAuthTokensToBackend Future');
  //   final response = await http.post(
  //     Uri.parse('Config.backendGoogleCallback'),
  //     //Uri.parse('http://localhost:3000/auth/google/callback'),
  //     body: {
  //       'id_token': idToken,
  //       'access_token': accessToken,
  //       'refresh_token': refreshToken,
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     print('Tokens sent to backend successfully');
  //   } else {
  //     print('Failed to send tokens to backend: ${response.statusCode}');
  //   }
  // }

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
