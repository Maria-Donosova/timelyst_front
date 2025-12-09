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



  static String get redirectUri {
    final value = _configService.get('REDIRECT_URI');
    return value ?? 'http://localhost:8080';
  } 

  static String get microsoftRedirectUri {
    final baseUrl = frontendURL.endsWith('/') 
        ? frontendURL.substring(0, frontendURL.length - 1) 
        : frontendURL;
    return '$baseUrl/'; // Ensure it ends with a slash if it's the root
  }
  

  static String get frontendURL {
    return _configService.get('FRONTEND_URL') ?? 'https://timelyst-core.fly.dev';
  }

  static String get backendURL {
    return _configService.get('BACKEND_URL') ?? 'https://timelyst-core.fly.dev';
  }

  // Legacy GraphQL URL - keeping it just in case, but it should probably be removed or updated
  static String get backendGraphqlURL {
    final value = _configService.get('BACKEND_URL_GRAPHQL');
    return value ?? 'https://timelyst-core.fly.dev/graphql';
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
  static String get backendMicrosoftConnect {
    return '$backendURL/integrations/microsoft/connect';
  }

  static String get backendMicrosoftSync {
    return '$backendURL/integrations/microsoft/sync';
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
  static String get backendAppleConnect {
    return '$backendURL/integrations/apple/connect';
  }

  static String get backendAppleSync {
    return '$backendURL/integrations/apple/sync';
  }

  // Google Backend Endpoints
  static String get backendGoogleConnect {
    return '$backendURL/integrations/google/connect';
  }

  static String get backendGoogleSync {
    return '$backendURL/integrations/google/sync';
  }
}
