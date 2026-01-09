import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/utils/auth_event_bus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('flutter_timezone');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall methodCall) async {
      if (methodCall.method == 'getLocalTimezone') {
        return 'UTC';
      }
      return null;
    });
  });

  group('ApiClient', () {
    test('should emit AuthEvent.unauthorized when 401 response is received',
        () async {
      final mockClient = MockClient((request) async {
        return http.Response('Unauthorized', 401);
      });

      final apiClient = ApiClient(client: mockClient);
      bool unauthorizedEmitted = false;

      final subscription = AuthEventBus.stream.listen((event) {
        if (event == AuthEvent.unauthorized) {
          unauthorizedEmitted = true;
        }
      });

      await apiClient.get('https://example.com/api/test');
      await Future.delayed(Duration.zero);

      expect(unauthorizedEmitted, isTrue);
      await subscription.cancel();
    });

    test('get should include default headers and token', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.headers['Content-Type'], 'application/json');
        expect(request.headers['Authorization'], 'Bearer test-token');
        expect(request.headers['X-Timezone'], 'UTC');
        return http.Response('OK', 200);
      });

      final apiClient = ApiClient(client: mockClient);
      await apiClient.get('https://example.com/api/test', token: 'test-token');
    });

    test('post should include body and custom headers', () async {
      final testBody = {'key': 'value'};
      final mockClient = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.headers['Custom-Header'], 'custom-value');
        expect(request.headers['X-Timezone'], 'UTC');
        expect(request.body, jsonEncode(testBody));
        return http.Response('Created', 201);
      });

      final apiClient = ApiClient(client: mockClient);
      await apiClient.post(
        'https://example.com/api/test',
        body: testBody,
        headers: {'Custom-Header': 'custom-value'},
      );
    });

    test('put should encode body correctly', () async {
      final testBody = {'id': 1};
      final mockClient = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.body, jsonEncode(testBody));
        return http.Response('OK', 200);
      });

      final apiClient = ApiClient(client: mockClient);
      await apiClient.put('https://example.com/api/test', body: testBody);
    });

    test('delete should handle optional body', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        return http.Response('No Content', 204);
      });

      final apiClient = ApiClient(client: mockClient);
      await apiClient.delete('https://example.com/api/test');
    });
  });
}
