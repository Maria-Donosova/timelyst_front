import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/providers/authProvider.dart';
import '../mocks/mockAuthService.dart';

void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      authProvider = AuthProvider(mockAuthService);
    });

    test('logout should clear user session', () async {
      // Arrange: Simulate a logged-in user
      mockAuthService.setLoginState(true, userId: '123');
      await authProvider.tryAutoLogin();
      expect(authProvider.isLoggedIn, true);
      expect(authProvider.userId, '123');

      // Act: Call the logout method
      await authProvider.logout();

      // Assert: Verify the user is logged out
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.userId, null);
    });

    test('login with valid credentials should log the user in', () async {
      // Act
      await authProvider.login('test@test.com', 'password');

      // Assert
      expect(authProvider.isLoggedIn, true);
      expect(authProvider.userId, '123');
      expect(authProvider.errorMessage, null);
    });

    test('login with invalid credentials should fail', () async {
      // Act & Assert
      await expectLater(
        authProvider.login('wrong@test.com', 'wrongpassword'),
        throwsA(isA<Exception>()),
      );
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.userId, null);
      expect(authProvider.errorMessage, isNotNull);
    });

    test('register should create a new user and log them in', () async {
      // Act
      await authProvider.register('new@test.com', 'newpassword', 'Test', 'User', true);

      // Assert
      expect(authProvider.isLoggedIn, true);
      expect(authProvider.userId, '456');
      expect(authProvider.errorMessage, null);
    });
  });
}
