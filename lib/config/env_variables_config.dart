import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get clientId =>
      dotenv.env['CLIENT_ID'] ??
      '287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com';
  static String get clientSecret =>
      dotenv.env['CLIENT_SECRET'] ?? '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';
  static String get googleOath =>
      dotenv.env['GOOGLE_OATH_URL'] ?? 'https://oauth2.googleapis.com/token';

  static String get backendGoogleCallback =>
      dotenv.env['BACKEND_GOOGLE_CALLBACK'] ??
      'http://localhost:3000/auth/google/callback';
  static String get redirectUri =>
      dotenv.env['REDIRECT_URI'] ?? 'http://localhost:7357';
  static String get frontendURL =>
      dotenv.env['FRONTEND_URL'] ?? 'http://localhost:7357';
}
