import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'package:timelyst_flutter/providers/authProvider.dart';
import 'package:timelyst_flutter/providers/taskProvider.dart';
import 'package:timelyst_flutter/providers/eventProvider.dart';
import 'package:timelyst_flutter/providers/calendarProvider.dart';
import 'package:timelyst_flutter/widgets/screens/common/logIn.dart';
import 'package:timelyst_flutter/widgets/shared/customAppbar.dart';
import '../mocks/mockAuthService.dart';
import 'package:timelyst_flutter/models/customApp.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

class MockTaskProvider extends Mock implements TaskProvider {
  @override
  Future<void> fetchTasks({bool forceRefresh = false}) => Future.value();
}

class MockEventProvider extends Mock implements EventProvider {
  @override
  List<CustomAppointment> get events => [];
  @override
  void invalidateCache() {}
  @override
  Future<void> fetchDayViewEvents({DateTime? date, bool isParallelLoad = false, bool isParallelLoadTimeout = false}) => Future.value();
}

class MockCalendarProvider extends Mock implements CalendarProvider {
  @override
  Future<void> loadInitialCalendars() => Future.value();
}

class MockAuthServiceWithMockito extends Mock implements AuthService {
  @override
  Future<Map<String, dynamic>> login(String? email, String? password) =>
      super.noSuchMethod(Invocation.method(#login, [email, password]),
          returnValue: Future.value(<String, dynamic>{}));
  
  @override
  Future<bool> isLoggedIn() => super.noSuchMethod(Invocation.getter(#isLoggedIn), returnValue: Future.value(false));

  @override
  Future<void> logout() => super.noSuchMethod(Invocation.method(#logout, []), returnValue: Future.value());

  @override
  Future<void> clearAuthToken() => super.noSuchMethod(Invocation.method(#clearAuthToken, []), returnValue: Future.value());

  @override
  Future<void> clearUserId() => super.noSuchMethod(Invocation.method(#clearUserId, []), returnValue: Future.value());

  @override
  Future<String?> getAuthToken() => super.noSuchMethod(Invocation.method(#getAuthToken, []), returnValue: Future.value(null));

  @override
  Future<String?> getUserId() => super.noSuchMethod(Invocation.method(#getUserId, []), returnValue: Future.value(null));

  @override
  Future<void> saveAuthToken(String? token) => super.noSuchMethod(Invocation.method(#saveAuthToken, [token]), returnValue: Future.value());

  @override
  Future<void> saveUserId(String? userId) => super.noSuchMethod(Invocation.method(#saveUserId, [userId]), returnValue: Future.value());
}

void main() {
  late MockAuthServiceWithMockito mockAuthService;
  late AuthProvider authProvider;
  late MockTaskProvider mockTaskProvider;
  late MockEventProvider mockEventProvider;
  late MockCalendarProvider mockCalendarProvider;

  setUp(() {
    mockAuthService = MockAuthServiceWithMockito();
    authProvider = AuthProvider(mockAuthService);
    mockTaskProvider = MockTaskProvider();
    mockEventProvider = MockEventProvider();
    mockCalendarProvider = MockCalendarProvider();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<TaskProvider>.value(value: mockTaskProvider),
        ChangeNotifierProvider<EventProvider>.value(value: mockEventProvider),
        ChangeNotifierProvider<CalendarProvider>.value(value: mockCalendarProvider),
      ],
      child: const MaterialApp(
        home: LogInScreen(),
      ),
    );
  }

  group('LogInScreen Widget Tests', () {
    testWidgets('should display email and password fields', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Log In'), findsOneWidget);
    });

    testWidgets('should show validation errors on empty submission', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      await tester.pumpWidget(createWidgetUnderTest());

      final loginButton = find.text('Log In');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pump();

      expect(find.text('Please provide a value.'), findsNWidgets(2));
    });

    testWidgets('should show error snackbar on failed login', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      
      when(mockAuthService.login(any, any)).thenAnswer((_) async {
        throw Exception('Invalid credentials');
      });

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'wrong@test.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrong');

      final loginButton = find.text('Log In');
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      
      await tester.pump(); 
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(); 

      expect(find.textContaining('Login failed'), findsOneWidget);
      expect(find.textContaining('Invalid credentials'), findsOneWidget);
    });
  });

  group('CustomAppBar Widget Tests', () {
    testWidgets('should show logo and title', (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 1000));
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
            ChangeNotifierProvider<TaskProvider>.value(value: mockTaskProvider),
            ChangeNotifierProvider<EventProvider>.value(value: mockEventProvider),
            ChangeNotifierProvider<CalendarProvider>.value(value: mockCalendarProvider),
          ],
          child: MaterialApp(
            home: Scaffold(appBar: CustomAppBar()),
          ),
        ),
      );

      expect(find.text('Tame the Time'), findsOneWidget); // Title
      expect(find.byType(Image), findsOneWidget); // Logo
    });
  });
}
