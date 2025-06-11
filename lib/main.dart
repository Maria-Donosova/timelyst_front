import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

import 'themes.dart';

import 'providers/authProvider.dart';
import 'providers/calendarProvider.dart';
import 'providers/eventProvider.dart';
import 'providers/taskProvider.dart';

import '../../screens/common/logIn.dart';
import '../../services/googleIntegration/googleSignInOut.dart';

Future main() async {
  await dotenv.load(fileName: 'lib/.env');
  GoogleSignInOutService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        // ChangeNotifierProvider(create: (_) => CalendarProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sign Up',
        theme: CustomTheme.lightTheme,
        themeMode: currentTheme.currentTheme,
        home: LogInScreen(),
      ),
    );
  }
}
