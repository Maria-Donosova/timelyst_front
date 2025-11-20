import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../config/envVarConfig.dart';

class GoogleSignInSingleton {
  static final GoogleSignInSingleton _singleton =
      GoogleSignInSingleton._internal();

  factory GoogleSignInSingleton() {
    return _singleton;
  }

  GoogleSignInSingleton._internal() {
    _googleSignIn = _initializeGoogleSignIn();
  }

  late GoogleSignIn _googleSignIn;

  GoogleSignIn get googleSignIn => _googleSignIn;

  static const List<String> _scopes = <String>[
    'openid',
    'profile',
    'email',
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/calendar.calendarlist.readonly',
  ];

  GoogleSignIn _initializeGoogleSignIn() {
    if (kIsWeb) {
      final clientId = Config.googleClientId;
      if (clientId == null) {
        throw Exception(
            'Google Client ID is not configured. Please set the CLIENT_ID environment variable.');
      }
      return GoogleSignIn(
        clientId: clientId,
        forceCodeForRefreshToken: true,
        scopes: _scopes,
      );
    } else {
      return GoogleSignIn(
        forceCodeForRefreshToken: true,
        scopes: _scopes,
      );
    }
  }
}
