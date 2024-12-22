import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  // Google OAuth2
  static String? get clientId => dotenv.env['CLIENT_ID']!;
  static String? get clientSecret => dotenv.env['CLIENT_SECRET']!;
  static String? get googleOath => dotenv.env['GOOGLE_OATH_URL']!;
  static String? get googleOath2Token => dotenv.env['GOOGLE_OATH2_TOKEN_URL']!;

// Backend google APIs
  static String get backendGoogleCallback =>
      dotenv.env['BACKEND_GOOGLE_CALLBACK']!;
  static String get backendGoogleCalendars =>
      dotenv.env['BACKEND_GOOGLE_CALENDARS']!;
  //static String? get redirectUri => dotenv.env['REDIRECT_URI'];

  static String get frontendURL =>
      dotenv.env['FRONTEND_URL'] ?? 'http://localhost:7357';
}
