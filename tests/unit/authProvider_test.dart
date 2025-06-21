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
      await authProvider.checkAuthState();
      expect(authProvider.isLoggedIn, true);
      expect(authProvider.userId, '123');

      // Act: Call the logout method
      await authProvider.logout();

      // Assert: Verify the user is logged out
      expect(authProvider.isLoggedIn, false);
      expect(authProvider.userId, null);
    });
  });
}
