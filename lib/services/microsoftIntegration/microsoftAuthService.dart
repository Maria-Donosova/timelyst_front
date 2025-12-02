import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/models/calendars.dart';

class MicrosoftAuthService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // PKCE (Proof Key for Code Exchange) implementation for security
  static const String _codeVerifierKey = 'microsoft_code_verifier';
  static const String _codeChallengeKey = 'microsoft_code_challenge';

  String? _codeVerifier;
  String? _codeChallenge;

  /// Generates PKCE code verifier and challenge for secure OAuth flow
  Future<void> _generatePKCECodes() async {
    // Generate a random code verifier (43-128 chars)
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    _codeVerifier = base64UrlEncode(bytes).replaceAll('=', '');

    // Create code challenge using SHA256
    final challenge = sha256.convert(utf8.encode(_codeVerifier!));
    _codeChallenge = base64UrlEncode(challenge.bytes).replaceAll('=', '');

    // Persist PKCE codes to secure storage for cross-instance access
    await _secureStorage.write(key: _codeVerifierKey, value: _codeVerifier);
    await _secureStorage.write(key: _codeChallengeKey, value: _codeChallenge);
    print('🔍 [MicrosoftAuthService] Generated and stored PKCE codes');
  }

  /// Generates Microsoft OAuth authorization URL
  Future<String> generateAuthUrl() async {
    // Generate PKCE codes before creating the auth URL
    await _generatePKCECodes();

    // Add prompt=select_account to always prompt for account selection
    final params = {
      'client_id': Config.microsoftClientId,
      'response_type': 'code',
      'redirect_uri': Config.microsoftRedirectUri,
      'scope': 'openid profile email https://graph.microsoft.com/calendars.read https://graph.microsoft.com/calendars.readwrite offline_access',
      'code_challenge': _codeChallenge!,
      'code_challenge_method': 'S256',
      'prompt': 'select_account', // Force account selection every time
    };

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final authUrl = '${Config.microsoftAuthUrl}?$queryString';

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
      final authToken = await _authService.getAuthToken();
      
      // Load code verifier from secure storage if not in memory
      if (_codeVerifier == null) {
        _codeVerifier = await _secureStorage.read(key: _codeVerifierKey);
      }

      final body = {
        'code': authCode,
        'codeVerifier': _codeVerifier, // Include PKCE code verifier just in case
        'redirectUri': Config.microsoftRedirectUri, // Keep this or update if needed
      };

      final response = await _apiClient.post(
        Config.backendMicrosoftConnect,
        body: body,
        token: authToken,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Clear PKCE state after successful authentication
        clearAuthState();

        return {
          'success': true,
          'message': responseData['message'] ?? 'Microsoft account connected',
        };
      } else {
        print('❌ [MicrosoftAuthService] Backend request failed with status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to connect Microsoft account: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ [MicrosoftAuthService] Exception occurred: $e');
      return {
        'success': false,
        'message': 'Failed to send auth code to backend: $e',
      };
    }
  }

  /// Clears stored PKCE parameters (call after successful auth)
  Future<void> clearAuthState() async {
    _codeVerifier = null;
    _codeChallenge = null;

    // Clear from secure storage as well
    await _secureStorage.delete(key: _codeVerifierKey);
    await _secureStorage.delete(key: _codeChallengeKey);

    print('🔍 [MicrosoftAuthService] Cleared PKCE auth state from memory and storage');
  }

  /// Gets current user's email from Microsoft Graph (if needed as fallback)
  Future<String?> getCurrentUserEmail() async {
    try {
      // This would require a Microsoft Graph API call with the access token
      // For now, return null and rely on backend providing email
      print('⚠️ [MicrosoftAuthService] Email fallback not implemented yet');
      return null;
    } catch (e, stackTrace) {
      print('❌ [MicrosoftAuthService] Error getting user email: $e');
      return null;
    }
  }
}