import 'dart:async';

enum AuthEvent {
  unauthorized,
}

class AuthEventBus {
  static final StreamController<AuthEvent> _controller =
      StreamController<AuthEvent>.broadcast();

  static Stream<AuthEvent> get stream => _controller.stream;

  static void emit(AuthEvent event) {
    _controller.add(event);
  }
}
