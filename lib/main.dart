// Version: d1e4c10 - Fixed recurring events and GraphQL schema compatibility
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:timelyst_flutter/services/authService.dart';

import 'themes.dart';

import 'providers/authProvider.dart';
import 'providers/calendarProvider.dart';
import 'providers/eventProvider.dart';
import 'providers/taskProvider.dart';

import 'package:timelyst_flutter/widgets/screens/common/wrapper.dart';

Future main() async {
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
          create: (_) => TaskProvider(authService: authService),
          update: (_, auth, previous) => previous!..setAuth(auth.authService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, EventProvider>(
          create: (_) => EventProvider(authService: authService),
          update: (_, auth, previous) => previous!..setAuth(auth.authService),
        ),
        ChangeNotifierProxyProvider<AuthProvider, CalendarProvider>(
          create: (_) => CalendarProvider(authService: authService),
          update: (_, auth, previous) {
            // Set up the Google auth error callback to trigger re-auth notification
            previous!.setGoogleAuthErrorCallback(() {
              auth.setGoogleReAuthRequired(true);
            });
            return previous..updateAuth(auth.authService);
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sign-up',
        theme: CustomTheme.lightTheme,
        themeMode: currentTheme.currentTheme,
        home: Wrapper(),
      ),
    );
  }
}