import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/providers/authProvider.dart';
import 'package:timelyst_flutter/widgets/screens/common/logIn.dart';
import 'package:timelyst_flutter/services/authService.dart';
import 'mocks/mock_auth_service.mocks.dart';

void main() {
  testWidgets('LogInScreen should render correctly', (WidgetTester tester) async {
    final mockAuthService = MockAuthService();

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>(
        create: (_) => AuthProvider(mockAuthService),
        child: MaterialApp(
          home: LogInScreen(),
        ),
      ),
    );

    expect(find.text('Welcome Friend'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Log In'), findsOneWidget);
  });
}