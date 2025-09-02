import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:http/http.dart' as http;
import 'package:timelyst_flutter/config/envVarConfig.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([ApiClient, FlutterSecureStorage])
void main() {
  group('AuthService', () {
    late MockApiClient mockApiClient;
    late MockFlutterSecureStorage mockSecureStorage;
    late AuthService authService;

    setUp(() {
      mockApiClient = MockApiClient();
      mockSecureStorage = MockFlutterSecureStorage();
      authService = AuthService.test(mockApiClient, mockSecureStorage);
      when(mockSecureStorage.read(key: 'authToken')).thenAnswer((_) async => null);
    });

    test('register should return user data on successful registration', () async {
      // Arrange
      final responsePayload = {
        'data': {
          'registerUser': {
            'token': 'some_token',
            'userId': '1',
            'role': 'USER'
          }
        }
      };
      when(mockApiClient.post(any, body: anyNamed('body'), token: anyNamed('token')))
          .thenAnswer((_) async => http.Response(jsonEncode(responsePayload), 200));
      when(mockSecureStorage.write(key: 'authToken', value: 'some_token')).thenAnswer((_) async => Future.value());
      when(mockSecureStorage.write(key: 'userId', value: '1')).thenAnswer((_) async => Future.value());

      // Act
      final result = await authService.register('test@example.com', 'password', 'Test', 'User', true);

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['userId'], '1');
      expect(result['token'], 'some_token');
      verify(mockApiClient.post(any, body: anyNamed('body'), token: anyNamed('token'))).called(1);
      verify(mockSecureStorage.write(key: 'authToken', value: 'some_token')).called(1);
      verify(mockSecureStorage.write(key: 'userId', value: '1')).called(1);
    });

    test('register should throw an exception on failed registration', () async {
      // Arrange
      when(mockApiClient.post(any, body: anyNamed('body'), token: anyNamed('token')))
          .thenAnswer((_) async => http.Response('{"error": "Registration failed"}', 400));

      Object? exception;
      // Act
      try {
        await authService.register('test@example.com', 'password', 'Test', 'User', true);
      } catch (e) {
        exception = e;
      }

      // Assert
      expect(exception, isA<Exception>());
      verify(mockApiClient.post(any, body: anyNamed('body'), token: anyNamed('token'))).called(1);
      verifyNever(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')));
    });
  });
}