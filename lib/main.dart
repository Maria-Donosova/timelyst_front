import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:timelyst_flutter/services/authService.dart';

import 'themes.dart';

import 'providers/authProvider.dart';
import 'providers/calendarProvider.dart';
import 'providers/eventProvider.dart';
import 'providers/taskProvider.dart';

import 'widgets/screens/common/logIn.dart';

import 'package:timelyst_flutter/services/googleIntegration/googleSignInOut.dart';

Future main() async {
  await dotenv.load(fileName: 'lib/.env');
  GoogleSignInOutService().initialize();
  // Create an instance of AuthService
  final authService = AuthService();
  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({super.key, required this.authService});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        // Provide the authService instance that was created in main()
        Provider<AuthService>.value(value: authService),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        // Pass the authService instance directly to CalendarProvider
        ChangeNotifierProvider(
            create: (_) => CalendarProvider(authService: authService)),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sign Up',
        theme: CustomTheme.lightTheme,
        themeMode: currentTheme.currentTheme,
        home: Wrapper(),
      ),
    );
  }
}
