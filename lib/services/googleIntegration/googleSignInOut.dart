import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../../config/env_variables_config.dart';

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
    _googleSignIn = kIsWeb
        ? GoogleSignIn(
            clientId: Config.clientId,
            forceCodeForRefreshToken: true,
            scopes: _scopes,
          )
        : GoogleSignIn(
            forceCodeForRefreshToken: true,
            scopes: _scopes,
          );
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

  Future<Map<String, dynamic>> googleSignIn(BuildContext context) async {
    print("entering googleSignIn");
    if (kIsWeb) {
      print("kIsWeb is true");
      try {
        final serverAuthCode =
            await _googleAuthService.requestServerAuthenticatioinCode();

        if (serverAuthCode != null) {
          final response =
              await _googleAuthService.sendAuthCodeToBackend(serverAuthCode);

          // Check if the response is valid
          if (response.containsKey('success')) {
            if (response['success']) {
              print('Success: ${response['message']}');
              print('User email: ${response['email']}');

              // Return the email and success message
              return {
                'userId': response['data']['userId'],
                'email': response['email'],
                'message': response['message'],
              };
              //return 'Success: ${response['message']}';
            } else {
              print('Error: ${response['message']}');
              return {
                'email': null,
                'message': 'Error: ${response['message']}',
              };
            }
          } else {
            print('Invalid response from backend: $response');
            return {
              'email': null,
              'message': 'Invalid response from backend',
            };
          }
        } else {
          return {
            'email': null,
            'message': 'Failed to get auth code from Google',
          };
        }
      } catch (error) {
        print('Error during web sign-in: $error');
        return {
          'email': null,
          'message': 'Error during web sign-in: $error',
        };
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
        }
      } catch (error) {
        print(error);
        return {
          'email': null,
          'message': 'Invalid response from backend',
        };
      }
    }
    return {
      'email': null,
      'message': 'Signed in failed',
    };
  }

  // google sign out method
  Future<String> googleDisconnect() async {
    try {
      await _googleSignIn.disconnect();
      //await _googleSignIn.signOut();
      // await _googleAuthService.clearTokensOnBackend();
      // await storage.deleteAll();
      if (_googleSignIn.currentUser == null) {
        print("User is disconnected");
        return "User is disconnected";
      } else {
        print("Disconnect failed");
        return "Disconnect failed";
      }
    } catch (e) {
      print(e);
      return "Error: $e";
    }
  }

  // google sign out method
  Future<void> googleSignOut() async {
    try {
      //await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      print("User signed out and cookies cleared");
    } catch (e) {
      print(e);
      throw Exception('Google sign-out failed: $e');
    }
  }
}
