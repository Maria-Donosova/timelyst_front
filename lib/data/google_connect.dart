import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';

import '../service/google_auth_service.dart';

import '../config/env_variables_config.dart';

// import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../service/google_auth_service.dart';
// import '../config/env_variables_config.dart';

//class that handles google sign in and sign out operations
class GoogleConnectService {
  final GoogleSignIn _googleSignIn;

  GoogleConnectService()
      : _googleSignIn = GoogleSignIn(
          clientId: kIsWeb ? Config.clientId : null,
          scopes: _scopes,
        );

  static const List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
  ];

  final GoogleAuthService _googleAuthService = GoogleAuthService();

  Future<void> googleSignInSilently() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account != null) {
        await _handleSignIn(account);
      } else {
        throw Exception('Sign-in silently failed');
      }
    } catch (error) {
      throw Exception('Error during sign-in silently: $error');
    }
  }

  Future<String> googleSignIn(BuildContext context) async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      if (account == null) {
        final GoogleSignInAccount? account = await _googleSignIn.signIn();
        if (account != null) {
          await _handleSignIn(account);
          return account.email;
        } else {
          throw Exception('Sign-in failed');
        }
      } else {
        await _handleSignIn(account);
        return account.email;
      }
    } catch (error) {
      throw Exception('Error during sign-in: $error');
    }
  }

  Future<String> googleSignOut(BuildContext context) async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signOut();
      await _googleAuthService.clearTokensOnBackend();
      await _googleAuthService.clearAccessTokenStorage();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User signed out successfully')),
      );
      return account?.email ?? 'User signed out';
    } catch (e) {
      throw Exception('Error during sign-out: $e');
    }
  }

  Future<void> _handleSignIn(GoogleSignInAccount account) async {
    final String? serverAuthCode = account.serverAuthCode;
    if (serverAuthCode != null) {
      final Map<String, dynamic>? tokenResponse =
          await _googleAuthService.exchangeCodeForTokens(serverAuthCode);
      if (tokenResponse != null) {
        final String accessToken = tokenResponse['access_token'];
        final String idToken = tokenResponse['id_token'];
        final String refreshToken = tokenResponse['refresh_token'];
        await _googleAuthService.sendTokensToBackend(
            idToken, accessToken, refreshToken);
        await _googleAuthService.saveAccessTokenStorage(accessToken);
        // Provide user feedback or navigate to home screen
      } else {
        throw Exception('Failed to obtain tokens');
      }
    } else {
      throw Exception('Server auth code is null');
    }
  }
}

// // GoogleSignInService class to handle Google sign-in and sign-out operations using the GoogleSignIn plugin (web implementation).
// class GoogleConnectService {
//   final GoogleAuthService _googleAuthService = GoogleAuthService();
//   final GoogleSignIn _googleSignIn = (kIsWeb)
//       ? GoogleSignIn(
//           clientId: Config.clientId,
//           forceCodeForRefreshToken: true,
//           scopes: _scopes,
//         )
//       : GoogleSignIn(
//           forceCodeForRefreshToken: true,
//           scopes: _scopes,
//         );

//   static const List<String> _scopes = <String>[
//     'openid',
//     'profile',
//     'email',
//     'https://www.googleapis.com/auth/peopleapi.readonly',
//     'https://www.googleapis.com/auth/calendar',
//   ];

//   // google sign in silently method
//   Future<String> googleSignInSilently() async {
//     try {
//       GoogleSignInAccount? googleSignInAccount =
//           await _googleSignIn.signInSilently();
//       print('try Google SignIn Silently');
//       if (googleSignInAccount != null) {
//         final strin =
//             await _googleAuthService.requestServerAuthenticatioinCode();
//         if (strin != null) {
//           final tokenResponse =
//               await _googleAuthService.exchangeCodeForTokens(strin);
//           if (tokenResponse != null) {
//             final googleAccount = tokenResponse['email'];
//             final accessToken = tokenResponse['access_token'];
//             final idToken = tokenResponse['id_token'];
//             final refreshtoken = tokenResponse['refresh_token'];
//             print("Google Account: $googleAccount");
//             print("Access Token: $accessToken");
//             print("ID Token: $idToken");
//             print("Refresh Token: $refreshtoken");
//             _googleAuthService.sendTokensToBackend(
//                 idToken, accessToken, refreshtoken);
//             return 'Success';
//           } else {
//             print("Failed to obtain tokens.");
//             return 'Failed to obtain tokens';
//           }
//         }
//       }
//     } catch (error) {
//       print('Error during web sign-in: $error');
//       return 'Error during web sign-in: $error';
//     }
//     return 'Sign-in silently failed';
//   }

//   // implicit google sign in method
//   Future<String> googleSignIn(BuildContext context) async {
//     if (kIsWeb) {
//       try {
//         GoogleSignInAccount? googleSignInAccount =
//             await _googleSignIn.signInSilently();

//         print('try Google SignIn Silently');

//         if (googleSignInAccount == null) {
//           // If silent sign-in fails, show the sign-in button
//           googleSignInAccount = await _googleSignIn.signIn();
//         }

//         if (googleSignInAccount != null) {
//           final strin =
//               await _googleAuthService.requestServerAuthenticatioinCode();

//           // Use the tokens as needed
//           if (strin != null) {
//             final tokenResponse =
//                 await _googleAuthService.exchangeCodeForTokens(strin);

//             if (tokenResponse != null) {
//               final googleAccount = tokenResponse['email'];
//               final accessToken = tokenResponse['access_token'];
//               final idToken = tokenResponse['id_token'];
//               final refreshtoken = tokenResponse['refresh_token'];
//               print("Google Account: $googleAccount");
//               print("Access Token: $accessToken");
//               print("ID Token: $idToken");
//               print("Refresh Token: $refreshtoken");
//               _googleAuthService.sendTokensToBackend(
//                   idToken, accessToken, refreshtoken);
//               showAboutDialog(context: context, children: [
//                 Text('Successful Google authentication'),
//               ]);
//               return 'Success';
//             } else {
//               print("Failed to obtain tokens.");
//               return 'Failed to obtain tokens';
//             }
//           }
//         }
//       } catch (error) {
//         print('Error during web sign-in: $error');
//         return 'Error during web sign-in: $error';
//       }
//     } else {
//       try {
//         GoogleSignInAccount? account = await _googleSignIn.signIn();

//         if (account != null) {
//           GoogleSignInAuthentication auth = await account.authentication;
//           print("Google Account: ${account.email}");
//           print("Id token : ${auth.idToken}");
//           print("Access token: ${auth.accessToken}");
//           String? serverAuthCode = account.serverAuthCode;
//           print("Server Auth Code: $serverAuthCode");

//           if (serverAuthCode != null) {
//             final tokenResponse =
//                 await _googleAuthService.exchangeCodeForTokens(serverAuthCode);

//             if (tokenResponse != null) {
//               final accessToken = tokenResponse['access_token'];
//               final idToken = tokenResponse['id_token'];
//               final refreshtoken = tokenResponse['refresh_token'];
//               final googleAccount = account.email;

//               print("Access Token: $accessToken");
//               print("ID Token: $idToken");
//               print("Refresh Token: $refreshtoken");
//               print("Success");
//               return googleAccount;
//             } else {
//               print("Failed to obtain tokens.");
//               return 'Failed to obtain tokens';
//             }
//           }
//         }
//       } catch (error) {
//         print(error);
//         return 'Error: $error';
//       }
//     }
//     return 'Regular sign-in failed';
//   }

//   // google sign out method
//   Future<String> googleSignOut(BuildContext context) async {
//     try {
//       await _googleSignIn.disconnect();
//       await _googleSignIn.signOut();
//       await _googleAuthService.clearTokensOnBackend();
//       if (_googleSignIn.currentUser == null) {
//         return "User is signed out";
//       } else {
//         return "Sign out failed";
//       }
//     } catch (e) {
//       return "Error: $e";
//     }
//   }

//   Future<void> _handleSignIn(GoogleSignInAccount account) async {
//     final String? serverAuthCode = account.serverAuthCode;
//     if (serverAuthCode != null) {
//       final Map<String, dynamic>? tokenResponse =
//           await _googleAuthService.exchangeCodeForTokens(serverAuthCode);
//       if (tokenResponse != null) {
//         final String accessToken = tokenResponse['access_token'];
//         final String idToken = tokenResponse['id_token'];
//         final String refreshToken = tokenResponse['refresh_token'];
//         await _googleAuthService.sendTokensToBackend(
//             idToken, accessToken, refreshToken);
//         await _googleAuthService.saveAccessTokenStorage(accessToken);
//         // Provide user feedback or navigate to home screen
//       } else {
//         throw Exception('Failed to obtain tokens');
//       }
//     } else {
//       throw Exception('Server auth code is null');
//     }
//   }
// }


// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';

// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:google_sign_in_web/web_only.dart';

// import '../config/env_variables_config.dart';

// // GoogleSignInAccount? _currentUser;
// // GoogleSignInAccount get currentUser => _currentUser!;
// // GoogleSignInService class to handle Google sign-in and sign-out operations using the GoogleSignIn plugin (web implementation).
// class GoogleService {
//   final GoogleSignIn _googleSignIn = (kIsWeb)
//       ? GoogleSignIn(
//           clientId: Config.clientId,
//           //"287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com",
//           forceCodeForRefreshToken: true,
//           scopes: _scopes,
//         )
//       : GoogleSignIn(
//           forceCodeForRefreshToken: true,
//           scopes: _scopes,
//         );

//   static const List<String> _scopes = <String>[
//     'openid',
//     'profile',
//     'email',
//     'https://www.googleapis.com/auth/peopleapi.readonly',
//     'https://www.googleapis.com/auth/calendar',
//   ];

//   // google sign in silently method
//   Future<String> googleSignInSilently() async {
//     try {
//       GoogleSignInAccount? googleSignInAccount =
//           await _googleSignIn.signInSilently();
//       print('try Google SignIn Silently');
//       if (googleSignInAccount != null) {
//         final strin = await requestServerAuthenticatioinCode();
//         if (strin != null) {
//           final tokenResponse = await _exchangeCodeForTokens(strin);
//           if (tokenResponse != null) {
//             final googleAccount = tokenResponse['email'];
//             final accessToken = tokenResponse['access_token'];
//             final idToken = tokenResponse['id_token'];
//             final refreshtoken = tokenResponse['refresh_token'];
//             print("Google Account: $googleAccount");
//             print("Access Token: $accessToken");
//             print("ID Token: $idToken");
//             print("Refresh Token: $refreshtoken");
//             sendAuthTokensToBackend(idToken, accessToken, refreshtoken);
//             return 'Success';
//           } else {
//             print("Failed to obtain tokens.");
//             return 'Failed to obtain tokens';
//           }
//         }
//       }
//     } catch (error) {
//       print('Error during web sign-in: $error');
//       return 'Error during web sign-in: $error';
//     }
//     return 'Sign-in silently failed';
//   }

//   // implicit google sign in method
//   Future<String> googleSignIn(BuildContext context) async {
//     if (kIsWeb) {
//       //   try {
//       //     GoogleSignInAccount? googleSignInAccount =
//       //         await _googleSignIn.signInSilently();

//       //     print('try Google SignIn Silently');

//       //     if (googleSignInAccount == null) {
//       //       // If silent sign-in fails, show the sign-in button
//       //       googleSignInAccount = await _googleSignIn.signIn();
//       //     }

//       //     if (googleSignInAccount != null) {
//       //       final strin = await requestServerAuthenticatioinCode();

//       //       // Use the tokens as needed
//       //       if (strin != null) {
//       //         final tokenResponse = await _exchangeCodeForTokens(strin);

//       //         if (tokenResponse != null) {
//       //           final googleAccount = tokenResponse['email'];
//       //           final accessToken = tokenResponse['access_token'];
//       //           final idToken = tokenResponse['id_token'];
//       //           final refreshtoken = tokenResponse['refresh_token'];
//       //           print("Google Account: $googleAccount");
//       //           print("Access Token: $accessToken");
//       //           print("ID Token: $idToken");
//       //           print("Refresh Token: $refreshtoken");
//       //           sendAuthTokensToBackend(idToken, accessToken, refreshtoken);
//       //           showAboutDialog(context: context, children: [
//       //             Text('Successful Google authentication'),
//       //           ]);
//       //           return 'Success';
//       //         } else {
//       //           print("Failed to obtain tokens.");
//       //           return 'Failed to obtain tokens';
//       //         }
//       //       }
//       //     }
//       //   } catch (error) {
//       //     print('Error during web sign-in: $error');
//       //     return 'Error during web sign-in: $error';
//       //   }
//       // } else {
//       try {
//         GoogleSignInAccount? account = await _googleSignIn.signIn();

//         if (account != null) {
//           GoogleSignInAuthentication auth = await account.authentication;
//           print("Google Account: ${account.email}");
//           print("Id token : ${auth.idToken}");
//           print("Access token: ${auth.accessToken}");
//           String? serverAuthCode = account.serverAuthCode;
//           print("Server Auth Code: $serverAuthCode");

//           if (serverAuthCode != null) {
//             final tokenResponse = await _exchangeCodeForTokens(serverAuthCode);

//             if (tokenResponse != null) {
//               final accessToken = tokenResponse['access_token'];
//               final idToken = tokenResponse['id_token'];
//               final refreshtoken = tokenResponse['refresh_token'];
//               final googleAccount = account.email;

//               print("Access Token: $accessToken");
//               print("ID Token: $idToken");
//               print("Refresh Token: $refreshtoken");
//               print("Success");
//               return googleAccount;
//             } else {
//               print("Failed to obtain tokens.");
//               return 'Failed to obtain tokens';
//             }
//           }
//         }
//       } catch (error) {
//         print(error);
//         return 'Error: $error';
//       }
//     }
//     return 'Regular sign-in failed';
//   }

//   Future<Map<String, dynamic>?> _exchangeCodeForTokens(String code) async {
//     if (kIsWeb) {
//       final response = await http.post(
//         Uri.parse('Config.googleOath'),
//         //Uri.parse('https://oauth2.googleapis.com/token'),
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//         body: {
//           'code': code,
//           'client_id': Config.clientId,
//           //'287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com',
//           'client_secret': Config.clientSecret,
//           //'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',
//           'redirect_uri': Config.redirectUri,
//           //'http://localhost:7357',
//           'grant_type': 'authorization_code',
//         },
//       );
//       print(response.body);
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         print("Error: ${response.body}");
//         return null;
//       }
//     } else {
//       final response = await http.post(
//         Uri.parse('Config.googleOath'),
//         //Uri.parse('https://oauth2.googleapis.com/token'),
//         headers: {'Content-Type': 'application/x-www-form-urlencoded'},
//         body: {
//           'code': code,
//           'client_id': Config.clientId,
//           'client_secret': Config.clientSecret,
//           // 'client_id':
//           //     '287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com',
//           // 'client_secret': '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',
//           'redirect_uri': Config.redirectUri,
//           //'',
//           'grant_type': 'authorization_code',
//         },
//       );
//       print(response.body);
//       if (response.statusCode == 200) {
//         return jsonDecode(response.body);
//       } else {
//         print("Error: ${response.body}");
//         return null;
//       }
//     }
//   }

//   Future<String?> requestServerAuthenticatioinCode() async {
//     return requestServerAuthCode();
//   }

//   Future<void> sendAuthTokensToBackend(
//       String idToken, String accessToken, String refreshToken) async {
//     print('Entering sendAuthTokensToBackend Future');
//     final response = await http.post(
//       Uri.parse('Config.backendGoogleCallback'),
//       //Uri.parse('http://localhost:3000/auth/google/callback'),
//       body: {
//         'id_token': idToken,
//         'access_token': accessToken,
//         'refresh_token': refreshToken,
//       },
//     );
//     if (response.statusCode == 200) {
//       print('Tokens sent to backend successfully');
//     } else {
//       print('Failed to send tokens to backend: ${response.statusCode}');
//     }
//   }

//   // google sign out method
//   Future<String> googleSignOut(BuildContext context) async {
//     try {
//       await _googleSignIn.disconnect();
//       await _googleSignIn.signOut();
//       //await storage.deleteAll();
//       if (_googleSignIn.currentUser == null) {
//         print("User is signed out");
//         return "User is signed out";
//       } else {
//         print("Sign out failed");
//         return "Sign out failed";
//       }
//     } catch (e) {
//       print(e);
//       return "Error: $e";
//     }
//   }
// }
