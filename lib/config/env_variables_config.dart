import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get clientId =>
      dotenv.env['CLIENT_ID'] ??
      '287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com';
  static String get clientSecret =>
      dotenv.env['CLIENT_SECRET'] ?? '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';
  static String get backendUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000/auth/google/callback';
}
