import 'package:timelyst_flutter/services/config_service.dart';

class Config {
  static final ConfigService _configService = ConfigService();

  static String get googleClientId {
    final value = _configService.get('GOOGLE_CLIENT_ID');
    return value ?? 'test_google_client_id';
  }

  static String get googleClientSecret {
    final value = _configService.get('GOOGLE_CLIENT_SECRET');
    return value ?? 'test_google_client_secret';
  }

  static String get googleOath {
    return _configService.get('GOOGLE_OATH_URL') ?? 'https://accounts.google.com/o/oauth2/auth';
  }

  static String get googleOath2Token {
    return _configService.get('GOOGLE_OATH2_TOKEN_URL') ?? 'https://accounts.google.com/o/oauth2/token';
  }

  static String get backendGoogleCalendar {
    final value = _configService.get('BACKEND_GOOGLE_CALENDAR');
    return value ?? 'test_backend_google_calendar';
  }

  static String get backendFetchGoogleCalendars {
    final value = _configService.get('BACKEND_FETCH_GOOGLE_CALENDARS');
    return value ?? 'test_backend_fetch_google_calendars';
  }

  static String get backendSaveSelectedGoogleCalendars {
    final value = _configService.get('BACKEND_SAVE_SELECTED_GOOGLE_CALENDARS');
    return value ?? 'test_backend_save_selected_google_calendars';
  }

  static String? get redirectUri {
    final value = _configService.get('REDIRECT_URI');
    return value ?? 'http://localhost:8080';
  } 
  

  static String get frontendURL {
    return _configService.get('FRONTEND_URL') ?? 'https://timelyst-front.fly.dev';
  }

  static String get backendURL {
    return _configService.get('BACKEND_URL') ?? 'https://timelyst-back.fly.dev';
  }

  static String get backendGraphqlURL {
    final value = _configService.get('BACKEND_URL_GRAPHQL');
    return value ?? 'http://localhost:8081/graphql';
  }
}
