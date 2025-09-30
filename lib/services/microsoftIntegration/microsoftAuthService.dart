import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/models/calendars.dart';

class MicrosoftAuthService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();
  
  // PKCE (Proof Key for Code Exchange) implementation for security
  String? _codeVerifier;
  String? _codeChallenge;

  /// Generates PKCE code verifier and challenge for secure OAuth flow
  void _generatePKCECodes() {
    // Generate a random code verifier (43-128 chars)
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    _codeVerifier = base64UrlEncode(bytes).replaceAll('=', '');
    
    // Create code challenge using SHA256
    final challenge = sha256.convert(utf8.encode(_codeVerifier!));
    _codeChallenge = base64UrlEncode(challenge.bytes).replaceAll('=', '');
  }

  /// Generates Microsoft OAuth authorization URL
  String generateAuthUrl() {
    // Add prompt=select_account to always prompt for account selection
    final params = {
      'client_id': Config.microsoftClientId,
      'response_type': 'code',
      'redirect_uri': 'https://timelyst-back.fly.dev/microsoft/callback',
      'scope': 'openid profile email https://graph.microsoft.com/calendars.read https://graph.microsoft.com/calendars.readwrite offline_access',
      'prompt': 'select_account', // Force account selection every time
    };
    
    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
    
    final authUrl = '${Config.microsoftAuthUrl}?$queryString';
    
    print('🔍 [MicrosoftAuthService] Microsoft Tenant ID: ${Config.microsoftTenantId}');
    print('🔍 [MicrosoftAuthService] Microsoft Auth URL: ${Config.microsoftAuthUrl}');
    print('🔍 [MicrosoftAuthService] Full OAuth URL: $authUrl');
    return authUrl;
  }

  /// Generates random state for OAuth security
  String _generateState() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64UrlEncode(bytes).replaceAll('=', '');
  }

  /// Sends Microsoft authorization code to backend for token exchange
  Future<Map<String, dynamic>> sendAuthCodeToBackend(String authCode) async {
    try {
      print('🔍 [MicrosoftAuthService] Starting to send auth code to backend...');
      print('🔍 [MicrosoftAuthService] Backend URL: ${Config.backendMicrosoftAuth}');
      
      final authToken = await _authService.getAuthToken();
      final maskedToken = (authToken?.length ?? 0) > 10 ? '${authToken?.substring(0, 10)}...' : authToken;
      print('🔍 [MicrosoftAuthService] Auth token obtained: $maskedToken');
      
      final body = {
        'code': authCode,
        'codeVerifier': _codeVerifier, // Include PKCE code verifier
        'redirectUri': 'https://timelyst-back.fly.dev/microsoft/callback',
      };
      print('🔍 [MicrosoftAuthService] Request body prepared with auth code');

      final response = await _apiClient.post(
        Config.backendMicrosoftAuth,
        body: body,
        token: authToken,
      );
      
      print('🔍 [MicrosoftAuthService] Backend response status code: ${response.statusCode}');
      print('🔍 [MicrosoftAuthService] Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ [MicrosoftAuthService] Backend response successful');
        print('🔍 [MicrosoftAuthService] Response data keys: ${responseData.keys.toList()}');
        print('🔍 [MicrosoftAuthService] User email: ${responseData['email']}');
        
        // Extract calendars from the unified response
        List<Calendar> calendars = [];
        if (responseData['calendars'] != null) {
          final calendarsData = responseData['calendars'] as List;
          print('🔍 [MicrosoftAuthService] Found ${calendarsData.length} calendars in response');
          calendars = <Calendar>[];
          for (var item in calendarsData) {
            if (item is Map<String, dynamic>) {
              calendars.add(Calendar.fromMicrosoftJson(item));
            } else {
              print('❌ [MicrosoftAuthService] Found invalid item in calendars list: $item');
            }
          }
          print('🔍 [MicrosoftAuthService] Parsed ${calendars.length} calendar objects');
        } else {
          print('⚠️ [MicrosoftAuthService] No calendars found in backend response');
          print('🔍 [MicrosoftAuthService] Available response fields: ${responseData.keys.toList()}');
        }

        // Get email from backend response, fallback to Microsoft Graph if not provided
        String? email = responseData['email'];
        if (email == null) {
          print('⚠️ [MicrosoftAuthService] Email not found in backend response');
          // Could implement Microsoft Graph API call here as fallback
        }

        return {
          'success': true,
          'message': 'Microsoft auth successful',
          'email': email,
          'data': responseData,
          'calendars': calendars,
        };
      } else {
        final errorData = jsonDecode(response.body);
        print('❌ [MicrosoftAuthService] Backend request failed with status: ${response.statusCode}');
        print('🔍 [MicrosoftAuthService] Error response: $errorData');
        return {
          'success': false,
          'message': 'Failed to authenticate with Microsoft: ${response.statusCode}',
          'error': errorData,
        };
      }
    } catch (e) {
      print('❌ [MicrosoftAuthService] Exception occurred: $e');
      return {
        'success': false,
        'message': 'Failed to send auth code to backend: $e',
        'error': e.toString(),
      };
    }
  }

  /// Gets current user's email from Microsoft Graph (if needed as fallback)
  Future<String?> getCurrentUserEmail() async {
    try {
      print('🔍 [MicrosoftAuthService] Getting current Microsoft user email...');
      // This would require a Microsoft Graph API call with the access token
      // For now, return null and rely on backend providing email
      print('⚠️ [MicrosoftAuthService] Email fallback not implemented yet');
      return null;
    } catch (e, stackTrace) {
      print('❌ [MicrosoftAuthService] Error getting user email: $e');
      print('🔍 [MicrosoftAuthService] Stack trace: $stackTrace');
      return null;
    }
  }
}