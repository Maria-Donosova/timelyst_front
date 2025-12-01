import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:timelyst_flutter/utils/apiClient.dart';
import 'package:timelyst_flutter/utils/auth_event_bus.dart';

void main() {
  group('ApiClient', () {
    test('should emit AuthEvent.unauthorized when 401 response is received',
        () async {
      // Arrange
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

      // Act
      await apiClient.get('https://example.com/api/test');

      // Wait for stream event to be processed
      await Future.delayed(Duration.zero);

      // Assert
      expect(unauthorizedEmitted, isTrue);

      // Cleanup
      await subscription.cancel();
    });

    test('should not emit AuthEvent.unauthorized when 200 response is received',
        () async {
      // Arrange
      final mockClient = MockClient((request) async {
        return http.Response('OK', 200);
      });

      final apiClient = ApiClient(client: mockClient);
      bool unauthorizedEmitted = false;

      final subscription = AuthEventBus.stream.listen((event) {
        if (event == AuthEvent.unauthorized) {
          unauthorizedEmitted = true;
        }
      });

      // Act
      await apiClient.get('https://example.com/api/test');

      // Wait for stream event to be processed
      await Future.delayed(Duration.zero);

      // Assert
      expect(unauthorizedEmitted, isFalse);

      // Cleanup
      await subscription.cancel();
    });
  });
}
