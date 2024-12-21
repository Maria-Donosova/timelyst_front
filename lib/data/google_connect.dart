import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../config/env_variables_config.dart';

import 'package:google_sign_in/google_sign_in.dart';
import '../service/google_auth_service.dart';
import '../service/connected_accounts.dart';

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
  //ConnectedAccounts _connectedAccounts = ConnectedAccounts();

  Future<Map<String, dynamic>> googleSignIn(
      BuildContext context, ConnectedAccounts connectedAccounts) async {
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

              // Add the email to the connected accounts
              connectedAccounts.addAccount(response['email']);

              // Return the email and success message
              return {
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

//   //PLACEHODLER fetch google user calendars
//   Future<List<Calendar>> fetchGoogleCalendars(
//       String userId, String email) async {
//     final response = await http.get(
//       Uri.parse('/fetch-calendars?userId=$userId&email=$email'),
//     );

//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body)['data'];
//       return data.map((calendar) => Calendar.fromJson(calendar)).toList();
//     } else {
//       throw Exception('Failed to load calendars');
//     }
//   }

//   //fetch google user events
//   Future<void> saveSelectedCalendars(String userId, List<Calendar> selectedCalendars) async {
//     final response = await http.post(
//       Uri.parse('/save-calendars'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'userId': userId,
//         'selectedCalendars': selectedCalendars.map((calendar) => calendar?.toJson()).toList(),
//       }),
//     );

//     class Calendar {
//   final String summary;

//   Calendar({required this.summary});

//   factory Calendar.fromJson(Map<String, dynamic> json) {
//     return Calendar(
//       summary: json['summary'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'summary': summary,
//     };
//   }
// }

  //   if (response.statusCode != 200) {
  //     throw Exception('Failed to save calendars');
  //   }
  // }

  // google sign out method
  Future<String> googleSignOut(BuildContext context) async {
    try {
      await _googleSignIn.disconnect();
      await _googleSignIn.signOut();
      //await _googleAuthService.clearTokensOnBackend();
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
