import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get googleClientId {
    final value = dotenv.env['GOOGLE_CLIENT_ID'];
    if (value == null) throw Exception('GOOGLE_CLIENT_ID is not set in .env file');
    return value;
  }

  static String get googleClientSecret {
    final value = dotenv.env['GOOGLE_CLIENT_SECRET'];
    if (value == null) throw Exception('GOOGLE_CLIENT_SECRET is not set in .env file');
    return value;
  }

  static String get googleOath {
    return dotenv.env['GOOGLE_OATH_URL'] ?? 'https://accounts.google.com/o/oauth2/auth';
  }

  static String get googleOath2Token {
    return dotenv.env['GOOGLE_OATH2_TOKEN_URL'] ?? 'https://accounts.google.com/o/oauth2/token';
  }

  static String get backendGoogleCalendar {
    final value = dotenv.env['BACKEND_GOOGLE_CALENDAR'];
    if (value == null) throw Exception('BACKEND_GOOGLE_CALENDAR is not set in .env file');
    return value;
  }

  static String get backendFetchGoogleCalendars {
    final value = dotenv.env['BACKEND_FETCH_GOOGLE_CALENDARS'];
    if (value == null) throw Exception('BACKEND_FETCH_GOOGLE_CALENDARS is not set in .env file');
    return value;
  }

  static String get backendSaveSelectedGoogleCalendars {
    final value = dotenv.env['BACKEND_SAVE_SELECTED_GOOGLE_CALENDARS'];
    if (value == null) throw Exception('BACKEND_SAVE_SELECTED_GOOGLE_CALENDARS is not set in .env file');
    return value;
  }

  static String? get redirectUri {
    final value = dotenv.env['REDIRECT_URI'];
    if (value == null) throw Exception('REDIRECT_URI is not set in .env file');
    return value;
  } 
  

  static String get frontendURL {
    return dotenv.env['FRONTEND_URL'] ?? 'https://timelyst-front.fly.dev';
  }

  static String get backendURL {
    return dotenv.env['BACKEND_URL'] ?? 'https://timelyst-back.fly.dev';
  }

  static String get backendGraphqlURL {
    final value = dotenv.env['BACKEND_URL_GRAPHQL'];
    if (value == null) throw Exception('BACKEND_URL_GRAPHQL is not set in .env file');
    return value;
  }
}
