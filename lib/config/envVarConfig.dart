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
    return value ?? '${backendURL}/google/calendars/save';
  }

  static String? get redirectUri {
    final value = _configService.get('REDIRECT_URI');
    return value ?? 'http://localhost:8080';
  } 
  

  static String get frontendURL {
    return _configService.get('FRONTEND_URL') ?? 'https://timelyst-back.fly.dev';
  }

  static String get backendURL {
    return _configService.get('BACKEND_URL') ?? 'https://timelyst-back.fly.dev';
  }

  static String get backendGraphqlURL {
    final value = _configService.get('BACKEND_URL_GRAPHQL');
    return value ?? 'http://localhost:8081/graphql';
  }

  // Microsoft OAuth Configuration
  static String get microsoftClientId {
    final value = _configService.get('MICROSOFT_CLIENT_ID');
    return value ?? '3193f9e8-2fa4-4fb2-b75b-70a1d65918af';
  }

  static String get microsoftClientSecret {
    final value = _configService.get('MICROSOFT_CLIENT_SECRET');
    return value ?? 'test_microsoft_client_secret';
  }

  static String get microsoftTenantId {
    final value = _configService.get('MICROSOFT_TENANT_ID');
    return value ?? 'common';
  }

  static String get microsoftScopes {
    final value = _configService.get('MICROSOFT_SCOPE');
    return value ?? 'https://graph.microsoft.com/calendars.read https://graph.microsoft.com/calendars.readwrite';
  }

  static String get microsoftAuthUrl {
    return 'https://login.microsoftonline.com/common/oauth2/v2.0/authorize';
  }

  static String get microsoftTokenUrl {
    return 'https://login.microsoftonline.com/common/oauth2/v2.0/token';
  }

  // Microsoft Backend Endpoints
  static String get backendMicrosoftAuth {
    final value = _configService.get('BACKEND_MICROSOFT_AUTH');
    return value ?? '${backendURL}/microsoft/auth';
  }

  static String get backendMicrosoftCalendarsSave {
    final value = _configService.get('BACKEND_MICROSOFT_CALENDARS_SAVE');
    return value ?? '${backendURL}/microsoft/calendars/save';
  }

  static String get backendMicrosoftCalendarsFetch {
    final value = _configService.get('BACKEND_MICROSOFT_CALENDARS_FETCH');
    return value ?? '${backendURL}/microsoft/calendars/fetch';
  }

  // Apple iCloud OAuth Configuration
  static String get appleClientId {
    final value = _configService.get('APPLE_CLIENT_ID');
    return value ?? 'test_apple_client_id';
  }

  static String get appleClientSecret {
    final value = _configService.get('APPLE_CLIENT_SECRET');
    return value ?? 'test_apple_client_secret';
  }

  static String get appleTeamId {
    final value = _configService.get('APPLE_TEAM_ID');
    return value ?? 'test_apple_team_id';
  }

  static String get appleKeyId {
    final value = _configService.get('APPLE_KEY_ID');
    return value ?? 'test_apple_key_id';
  }

  static String get appleScopes {
    final value = _configService.get('APPLE_SCOPE');
    return value ?? 'https://www.icloud.com/calendar https://www.icloud.com/contacts';
  }

  static String get appleAuthUrl {
    return 'https://appleid.apple.com/auth/authorize';
  }

  static String get appleTokenUrl {
    return 'https://appleid.apple.com/auth/token';
  }

  // Apple Backend Endpoints
  static String get backendAppleAuth {
    final value = _configService.get('BACKEND_APPLE_AUTH');
    return value ?? '${backendURL}/apple/auth';
  }

  static String get backendAppleCalendarsSave {
    final value = _configService.get('BACKEND_APPLE_CALENDARS_SAVE');
    return value ?? '${backendURL}/apple/calendars/save';
  }

  static String get backendAppleCalendarsFetch {
    final value = _configService.get('BACKEND_APPLE_CALENDARS_FETCH');
    return value ?? '${backendURL}/apple/calendars/fetch';
  }
}
