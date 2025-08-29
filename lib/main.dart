import 'package:flutter/foundation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:timelyst_flutter/services/authService.dart';

import 'themes.dart';

import 'providers/authProvider.dart';
import 'providers/calendarProvider.dart';
import 'providers/eventProvider.dart';
import 'providers/taskProvider.dart';

import 'widgets/screens/common/logIn.dart';

import 'package:timelyst_flutter/services/googleIntegration/googleSignInOut.dart';
import 'package:timelyst_flutter/widgets/screens/common/wrapper.dart';

Future main() async {
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
        ChangeNotifierProxyProvider<AuthProvider, TaskProvider>(
          create: (_) => TaskProvider(),
          update: (_, auth, previous) => previous!..updateAuth(auth.authService),
        ),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CalendarProvider>(
          create: (_) => CalendarProvider(authService: authService),
          update: (_, auth, previous) =>
              previous!..updateAuth(auth.authService),
        ),
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
