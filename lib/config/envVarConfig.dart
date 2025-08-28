import 'package:timelyst_flutter/services/config_service.dart';

class Config {
  static final ConfigService _configService = ConfigService();

  static String get googleClientId {
    final value = _configService.get('GOOGLE_CLIENT_ID');
    if (value == null) throw Exception('GOOGLE_CLIENT_ID is not set');
    return value;
  }

  static String get googleClientSecret {
    final value = _configService.get('GOOGLE_CLIENT_SECRET');
    if (value == null) throw Exception('GOOGLE_CLIENT_SECRET is not set');
    return value;
  }

  static String get googleOath {
    return _configService.get('GOOGLE_OATH_URL') ?? 'https://accounts.google.com/o/oauth2/auth';
  }

  static String get googleOath2Token {
    return _configService.get('GOOGLE_OATH2_TOKEN_URL') ?? 'https://accounts.google.com/o/oauth2/token';
  }

  static String get backendGoogleCalendar {
    final value = _configService.get('BACKEND_GOOGLE_CALENDAR');
    if (value == null) throw Exception('BACKEND_GOOGLE_CALENDAR is not set');
    return value;
  }

  static String get backendFetchGoogleCalendars {
    final value = _configService.get('BACKEND_FETCH_GOOGLE_CALENDARS');
    if (value == null) throw Exception('BACKEND_FETCH_GOOGLE_CALENDARS is not set');
    return value;
  }

  static String get backendSaveSelectedGoogleCalendars {
    final value = _configService.get('BACKEND_SAVE_SELECTED_GOOGLE_CALENDARS');
    if (value == null) throw Exception('BACKEND_SAVE_SELECTED_GOOGLE_CALENDARS is not set');
    return value;
  }

  static String? get redirectUri {
    final value = _configService.get('REDIRECT_URI');
    if (value == null) throw Exception('REDIRECT_URI is not set');
    return value;
  } 
  

  static String get frontendURL {
    return _configService.get('FRONTEND_URL') ?? 'https://timelyst-front.fly.dev';
  }

  static String get backendURL {
    return _configService.get('BACKEND_URL') ?? 'https://timelyst-back.fly.dev';
  }

  static String get backendGraphqlURL {
    final value = _configService.get('BACKEND_URL_GRAPHQL');
    if (value == null) throw Exception('BACKEND_URL_GRAPHQL is not set');
    return value;
  }
}
