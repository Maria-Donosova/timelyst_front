import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  // Google OAuth2
  static String? get clientId =>
      dotenv.env['CLIENT_ID'] ??
      '287872468745-3s590is0k581repee2ngshs1ngucghgm.apps.googleusercontent.com';
  static String? get clientSecret =>
      dotenv.env['CLIENT_SECRET'] ?? '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';
  static String? get googleOath =>
      dotenv.env['GOOGLE_OATH_URL'] ??
      'https://accounts.google.com/o/oauth2/auth';
  static String? get googleOath2Token =>
      dotenv.env['GOOGLE_OATH2_TOKEN_URL'] ??
      'https://accounts.google.com/o/oauth2/token';

// Backend google APIs
  static String get backendGoogleCallback =>
      dotenv.env['BACKEND_GOOGLE_CALLBACK'] ??
      'http://localhost:3000/google/callback';
  static String get backendGoogleCalendars =>
      dotenv.env['BACKEND_GOOGLE_CALENDARS'] ??
      'http://localhost:3000/google/calendars';
  // static String get backendFetchGoogleCalendars =>
  //     dotenv.env['BACKEND_FETCH_GOOGLE_CALENDARS'] ??
  //     'http://localhost:3000/google/fetch-calendars';
  // static String get backendSaveSelectedGoogleCalendars =>
  //     dotenv.env['BACKEND_SAVE_SELECTED_GOOGLE_CALENDARS'] ??
  //     'http://localhost:3000/google/save-calendars';
  //static String? get redirectUri => dotenv.env['REDIRECT_URI'];

  static String get frontendURL =>
      dotenv.env['FRONTEND_URL'] ?? 'http://localhost:7357';
  static String get backendURL =>
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';
}
