import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/vmwareengine/v1.dart';
import 'package:http/http.dart' as http;

// GoogleSignInService class to handle Google sign-in and sign-out operations using the GoogleSignIn plugin (web implementation).
class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com',
    scopes: _scopes,
  );

  static const List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'https://www.googleapis.com/auth/peopleapi.readonly',
    'https://www.googleapis.com/auth/calendar',
  ];

  GoogleSignInAccount? _currentUser;

  Future<void> signIn(BuildContext context) async {
    print("Entering SignIn Future");
    try {
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      print('Account: $account');

      if (account == null) {
        // If silent sign-in fails, show the sign-in button
        account = await _googleSignIn.signIn();
      }
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        final String? idToken = auth.idToken;

        if (idToken != null) {
          showAboutDialog(context: context, children: [
            Text('Successful Google authentication'),
          ]);

          await _handleAuthorizeScopes();
          // Send the tokens to the backend
          await sendAuthTokensToBackend(idToken);
        } else {
          print('No ID token received');
        }
      } else {
        print('No Google account selected');
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  // Prompts the user to authorize `scopes` (web implementation).
  // On the web, this must be called from an user interaction (button click).
  Future<void> _handleAuthorizeScopes() async {
    print("Entering _handleAuthorizeScopes Future");

    bool _isAuthorized = false;

    final bool isAuthorized = await _googleSignIn.requestScopes(_scopes);
    print('isAuthorized: $isAuthorized');
    print('Auth headers: ${_googleSignIn.currentUser?.authHeaders}');

    _isAuthorized = isAuthorized;

    if (isAuthorized) {
      print('Authorized');
    } else {
      print('Not authorized');
    }
  }

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

  //Sign out
  Future<void> _handleSignOut() => _googleSignIn.disconnect();
}
