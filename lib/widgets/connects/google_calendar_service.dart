import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/vmwareengine/v1.dart';
import 'package:google_sign_in_web/web_only.dart';
import 'package:http/http.dart' as http;

// GoogleSignInService class to handle Google sign-in and sign-out operations using the GoogleSignIn plugin (web implementation).
class GoogleService {
  final GoogleSignIn _googleSignIn = (kIsWeb)
      ? GoogleSignIn(
          clientId:
              "287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com",
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

  Future<void> googleSignIn() async {
    if (kIsWeb) {
      // Web-specific code
      GoogleSignInAccount? googleSignInAccount;

      try {
        googleSignInAccount = await _googleSignIn.signIn();

        final strin = await requestServerAuthenticatioinCode() ?? '';
        if (googleSignInAccount != null) {
          GoogleSignInAuthentication auth =
              await googleSignInAccount.authentication;

          print("Access Token: ${auth.accessToken}");
          print("ID Token: ${auth.idToken}");

          print("Server Auth Code: $strin");
          // Use the tokens as needed
          if (strin != null) {
            final tokenResponse = await _exchangeCodeForTokens(strin);

            if (tokenResponse != null) {
              print("token response not null");
              print(tokenResponse);
              final accessToken = tokenResponse['access_token'];
              final idToken = tokenResponse['id_token'];

              final refreshtoken = tokenResponse['refresh_token'];

              print("Access Token: $accessToken");
              print("ID Token: $idToken");
              print("Refresh Token: $refreshtoken");
            } else {
              print("Failed to obtain tokens.");
            }
          }
        }
      } catch (error) {
        print('Error during web sign-in: $error');
      }
    } else {
      try {
        GoogleSignInAccount? account = await _googleSignIn.signIn();

        if (account != null) {
          GoogleSignInAuthentication auth = await account.authentication;
          print("Id token : ${auth.idToken}");
          print("Access token: ${auth.accessToken}");
          String? serverAuthCode = account.serverAuthCode;
          print("Server Auth Code: $serverAuthCode");

          if (serverAuthCode != null) {
            final tokenResponse = await _exchangeCodeForTokens(serverAuthCode);

            if (tokenResponse != null) {
              final accessToken = tokenResponse['access_token'];
              final idToken = tokenResponse['id_token'];

              final refreshtoken = tokenResponse['refresh_token'];

              print("Access Token: $accessToken");
              print("ID Token: $idToken");
              print("Refresh Token: $refreshtoken");
            } else {
              print("Failed to obtain tokens.");
            }
          }
        }
      } catch (error) {
        print(error);
      }
    }
  }

  Future<Map<String, dynamic>?> _exchangeCodeForTokens(String code) async {
    if (kIsWeb) {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'code': code,
          'client_id':
              '287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com',
          'client_secret': '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',
          'redirect_uri': 'http://localhost:7357',
          'grant_type': 'authorization_code',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error: ${response.body}");
        return null;
      }
    } else {
      final response = await http.post(
        Uri.parse('https://oauth2.googleapis.com/token'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'code': code,
          'client_id':
              '287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com',
          'client_secret': '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',
          'redirect_uri': '',
          'grant_type': 'authorization_code',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print("Error: ${response.body}");
        return null;
      }
    }
  }

  Future<String?> requestServerAuthenticatioinCode() async {
    return requestServerAuthCode();
  }

  Future<bool> _handleSignOut() async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      if (_googleSignIn.currentUser == null) {
        print("User is signed out");
        return true;
      } else {
        print("Sign out failed");
        return false;
      }
    } catch (e) {
      print(e);

      return false;
    }
  }

  // GoogleSignInAccount? _currentUser;

  // Future<void> signIn(BuildContext context) async {
  //   print("Entering SignIn Future");
  //   try {
  //     GoogleSignInAccount? account = await _googleSignIn.signInSilently();
  //     print('Account: $account');

  //     if (account == null) {
  //       // If silent sign-in fails, show the sign-in button
  //       account = await _googleSignIn.signIn();
  //     }
  //     if (account != null) {
  //       final GoogleSignInAuthentication auth = await account.authentication;
  //       final String? idToken = auth.idToken;

  //       if (idToken != null) {
  //         showAboutDialog(context: context, children: [
  //           Text('Successful Google authentication'),
  //         ]);

  //         await _handleScopesAuthorization();
  //         final String? accessToken = auth.accessToken;
  //         print('Access: $accessToken');
  //         // Send the tokens to the backend
  //         await sendAuthTokensToBackend(idToken);
  //       } else {
  //         print('No ID token received');
  //       }
  //     } else {
  //       print('No Google account selected');
  //     }
  //   } catch (error) {
  //     print('Error signing in: $error');
  //   }
  // }

  // Prompts the user to authorize `scopes` (web implementation).
  // On the web, this must be called from an user interaction (button click).
  // Future<void> _handleScopesAuthorization() async {
  //   print("Entering _handleAuthorizeScopes Future");

  //   final bool isAuthorized = await _googleSignIn.canAccessScopes(_scopes);
  //   print('isAuthorized: $isAuthorized');
  //   print('Auth headers: ${_googleSignIn.currentUser?.authHeaders}');

  //   if (isAuthorized) {
  //     print('Authorized');
  //   } else {
  //     print('Not authorized');
  //     //await _googleSignIn.requestScopes(_scopes);
  //   }
  // }

  Future<void> sendAuthTokensToBackend(String idToken) async {
    print('Entering sendAuthTokensToBackend Future');
    final response = await http.post(
      Uri.parse('http://localhost:3000/auth/google/callback'),
      body: {
        'id_token': idToken,
      },
    );
    if (response.statusCode == 200) {
      print('Tokens sent to backend successfully');
    } else {
      print('Failed to send tokens to backend: ${response.statusCode}');
    }
  }
}
