import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/services/googleIntegration/googleAuthService.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:http/http.dart' as http;

import 'google_auth_service_test.mocks.dart';

@GenerateMocks([ApiClient, AuthService])
void main() {
  group('GoogleAuthService', () {
    late MockApiClient mockApiClient;
    late MockAuthService mockAuthService;
    late GoogleAuthService googleAuthService;

    setUp(() {
      mockApiClient = MockApiClient();
      mockAuthService = MockAuthService();
      googleAuthService = GoogleAuthService.test(mockApiClient, mockAuthService);
    });

    test('sendAuthCodeToBackend should return success on successful response', () async {
      // Arrange
      final authCode = 'test_auth_code';
      final token = 'test_token';
      final responsePayload = {'email': 'test@example.com'};
      when(mockAuthService.getAuthToken()).thenAnswer((_) async => token);
      when(mockApiClient.post(any, body: anyNamed('body'), token: token))
          .thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));

      // Act
      final result = await googleAuthService.sendAuthCodeToBackend(authCode);

      // Assert
      expect(result['success'], true);
      expect(result['email'], 'test@example.com');
      verify(mockApiClient.post(any, body: {'code': authCode}, token: token)).called(1);
    });

    test('sendAuthCodeToBackend should return failure on failed response', () async {
      // Arrange
      final authCode = 'test_auth_code';
      final token = 'test_token';
      when(mockAuthService.getAuthToken()).thenAnswer((_) async => token);
      when(mockApiClient.post(any, body: anyNamed('body'), token: token))
          .thenAnswer((_) async => http.Response('{"error": "Failed to send auth code"}', 400));

      // Act
      final result = await googleAuthService.sendAuthCodeToBackend(authCode);

      // Assert
      expect(result['success'], false);
      verify(mockApiClient.post(any, body: {'code': authCode}, token: token)).called(1);
    });
  });
}
