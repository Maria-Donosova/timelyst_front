import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:timelyst_flutter/config/envVarConfig.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/services/authService.dart';

class AppleAuthService {
  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();
  
  // PKCE implementation for enhanced security
  String? _codeVerifier;
  String? _state;

  /// Generates a secure random string for PKCE
  String _generateRandomString(int length) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Generates code challenge from verifier using SHA256
  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }

  /// Generates Apple OAuth authorization URL with PKCE
  String generateAuthUrl() {
    print('🔍 [AppleAuthService] Generating Apple OAuth URL');
    
    // Generate PKCE parameters
    _codeVerifier = _generateRandomString(128);
    final codeChallenge = _generateCodeChallenge(_codeVerifier!);
    _state = _generateRandomString(32);
    
    print('🔍 [AppleAuthService] Generated PKCE parameters');
    print('🔍 [AppleAuthService] Code challenge: ${codeChallenge.substring(0, 10)}...');
    print('🔍 [AppleAuthService] State: ${_state!.substring(0, 10)}...');

    final params = {
      'client_id': Config.appleClientId,
      'redirect_uri': Config.redirectUri!,
      'response_type': 'code',
      'scope': Config.appleScopes,
      'state': _state!,
      'code_challenge': codeChallenge,
      'code_challenge_method': 'S256',
      'response_mode': 'form_post', // Apple requires form_post for web
    };

    final queryString = params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final authUrl = '${Config.appleAuthUrl}?$queryString';
    
    print('🔍 [AppleAuthService] Generated Apple OAuth URL successfully');
    print('🔍 [AppleAuthService] Auth URL: ${authUrl.substring(0, 50)}...');
    
    return authUrl;
  }

  /// Sends authorization code to backend for token exchange
  Future<Map<String, dynamic>> sendAuthCodeToBackend(String authCode) async {
    print('🔍 [AppleAuthService] Sending auth code to backend');
    print('🔍 [AppleAuthService] Auth code length: ${authCode.length}');
    print('🔍 [AppleAuthService] Code verifier length: ${_codeVerifier?.length ?? 0}');

    try {
      final authToken = await _authService.getAuthToken();
      if (authToken == null) {
        throw Exception('No authentication token available');
      }

      final response = await _apiClient.post(
        Config.backendAppleAuth,
        body: {
          'code': authCode,
          'codeVerifier': _codeVerifier,
          'state': _state,
          'redirectUri': Config.redirectUri,
        },
        token: authToken,
      );

      print('🔍 [AppleAuthService] Backend response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [AppleAuthService] Successfully exchanged auth code for tokens');
        print('🔍 [AppleAuthService] Response keys: ${data.keys.toList()}');
        
        return data;
      } else {
        final errorBody = response.body;
        print('❌ [AppleAuthService] Backend error: ${response.statusCode}');
        print('🔍 [AppleAuthService] Error response: $errorBody');
        
        throw Exception(
          'Failed to exchange authorization code: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      print('❌ [AppleAuthService] Exception sending auth code to backend: $e');
      rethrow;
    }
  }

  /// Clears stored PKCE parameters (call after successful auth)
  void clearAuthState() {
    print('🔍 [AppleAuthService] Clearing auth state');
    _codeVerifier = null;
    _state = null;
  }

  /// Gets the current state parameter (for validation)
  String? get currentState => _state;

  /// Validates the state parameter from callback
  bool validateState(String receivedState) {
    final isValid = _state != null && _state == receivedState;
    print('🔍 [AppleAuthService] State validation: ${isValid ? 'VALID' : 'INVALID'}');
    return isValid;
  }
}