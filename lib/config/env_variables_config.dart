import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get clientId => dotenv.env['CLIENT_ID'] ?? 'default_client_id';
  static String get clientSecret =>
      dotenv.env['CLIENT_SECRET'] ?? 'default_client_secret';
  static String get backendUrl =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000/auth/google/callback';
}
