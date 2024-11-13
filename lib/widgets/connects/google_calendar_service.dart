import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/vmwareengine/v1.dart';
import 'package:http/http.dart' as http;

class GoogleSignInService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId:
        '287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com', // Set your client ID here
    scopes: <String>[
      'openid',
      'profile',
      'email',
      'https://www.googleapis.com/auth/peopleapi.readonly',
      'https://www.googleapis.com/auth/calendar',
    ],
  );

//   const List<String> scopes = <String>[
//   'email',
//   'https://www.googleapis.com/auth/contacts.readonly',
// ];

// GoogleSignIn _googleSignIn = GoogleSignIn(
//   // Optional clientId
//   // clientId: 'your-client_id.apps.googleusercontent.com',
//   scopes: scopes,
//);

  // GoogleSignInAccount? _currentUser;
  // bool _isAuthorized = false;

  // Prompts the user to authorize `scopes` (web implementation).
  // On the web, this must be called from an user interaction (button click).
  // Future<void> _handleAuthorizeScopes() async {
  //   final bool isAuthorized = await _googleSignIn.requestScopes(scopes);

  //   setState(() {
  //     _isAuthorized = isAuthorized;
  //   });

  //   if (isAuthorized) {
  //     unawaited(_handleGetContact(_currentUser!));
  //   }
  // }

  //Sign out
  //Future<void> _handleSignOut() => _googleSignIn.disconnect();

  Future<void> signIn() async {
    print("Entering SignIn future");
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
        final String? accessToken = auth.accessToken;

        if (idToken != null && accessToken != null) {
          // Send the tokens to the backend
          await sendAuthTokensToBackend(idToken, accessToken);
        } else {
          print('No ID token or access token received');
        }
      } else {
        print('No Google account selected');
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<void> sendAuthTokensToBackend(
      String idToken, String accessToken) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/auth/google/callback'),
      body: {
        'id_token': idToken,
        'access_token': accessToken,
      },
    );
    if (response.statusCode == 200) {
      print('Tokens sent to backend successfully');
    } else {
      print('Failed to send tokens to backend: ${response.statusCode}');
    }
  }
}
