import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/utils/auth_event_bus.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  StreamSubscription? _authSubscription;

  AuthProvider(this._authService) {
    _authSubscription = AuthEventBus.stream.listen((event) {
      if (event == AuthEvent.unauthorized) {
        logout();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  AuthService get authService => _authService;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userId;
  String? get userId => _userId;

  bool _googleReAuthRequired = false;
  bool get googleReAuthRequired => _googleReAuthRequired;

  void setGoogleReAuthRequired(bool required) {
    _googleReAuthRequired = required;
    notifyListeners();
  }

  void clearGoogleReAuthRequired() {
    _googleReAuthRequired = false;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    final token = await _authService.getAuthToken();
    if (token != null) {
      _isLoggedIn = true;
      _userId = await _authService.getUserId();
      notifyListeners();
    }
  }

  // Refresh authentication state (useful after external auth operations)
  Future<void> refreshAuthState() async {
    final token = await _authService.getAuthToken();
    final userId = await _authService.getUserId();
    
    if (token != null && userId != null) {
      _isLoggedIn = true;
      _userId = userId;
    } else {
      _isLoggedIn = false;
      _userId = null;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final result = await _authService.login(email, password);
      _userId = result['userId'];
      _isLoggedIn = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name,
      String lastName, bool consent) async {
    try {
      final result =
          await _authService.register(email, password, name, lastName, consent);
      _userId = result['userId'];
      _isLoggedIn = true;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.clearAuthToken();
    await _authService.clearUserId();
    _isLoggedIn = false;
    _userId = null;
    notifyListeners();
  }
}
