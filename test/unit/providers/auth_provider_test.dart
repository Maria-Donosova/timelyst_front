import 'package:flutter_test/flutter_test.dart';
import 'package:timelyst_flutter/providers/authProvider.dart';
import 'package:timelyst_flutter/utils/auth_event_bus.dart';
import '../../mocks/mockAuthService.dart';

class TestAuthService extends MockAuthService {
  bool logoutCalled = false;

  @override
  Future<void> logout() async {
    logoutCalled = true;
    await super.logout();
  }
}

void main() {
  group('AuthProvider', () {
    test('should call logout when AuthEvent.unauthorized is emitted', () async {
      // Arrange
      final authService = TestAuthService();
      final authProvider = AuthProvider(authService);

      // Simulate logged in state
      authService.setLoginState(true, userId: '123', token: 'token');
      await authProvider.refreshAuthState();
      expect(authProvider.isLoggedIn, isTrue);

      // Act
      AuthEventBus.emit(AuthEvent.unauthorized);

      // Wait for the event to be processed
      await Future.delayed(Duration.zero);
      // Wait a bit more for the async logout to complete
      await Future.delayed(Duration(milliseconds: 50));

      // Assert
      expect(authProvider.isLoggedIn, isFalse);
      
      // Cleanup
      authProvider.dispose();
    });
  });
}
