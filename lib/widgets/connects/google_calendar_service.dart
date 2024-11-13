import 'package:google_sign_in/google_sign_in.dart';
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

  Future<void> signIn() async {
    print("Entering SignIn future");
    try {
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      print('Account: $account');

      if (account == null) {
        // If silent sign-in fails, show the sign-in button
        await _googleSignIn.signIn();
      }

      final GoogleSignInAuthentication auth = await account!.authentication;
      // ignore: deprecated_member_use
      final String? authCode = auth.serverAuthCode;
      print('Auth code: $authCode');

      if (authCode != null) {
        // Send the authorization code to the backend
        await sendAuthCodeToBackend(authCode);
      } else {
        print('No authorization code received');
      }
    } catch (error) {
      print('Error signing in: $error');
    }
  }

  Future<void> sendAuthCodeToBackend(String authCode) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/auth/google/callback'),
      body: {'code': authCode},
    );

    if (response.statusCode == 200) {
      print('Authorization code sent to backend successfully');
    } else {
      print(
          'Failed to send authorization code to backend: ${response.statusCode}');
    }
  }
}
