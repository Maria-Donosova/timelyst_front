import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:timelyst_flutter/models/calendars.dart';
import 'package:timelyst_flutter/screens/common/calendarSettings.dart';
import 'providers/authProvider.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
//import 'package:timelyst_flutter/screens/common/logIn.dart';

import 'themes.dart';

Future main() async {
  await dotenv.load(fileName: 'lib/.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    const dummyCalendars = <Calendar>[];
    const dummyUserId = 'test-user';
    const dummyEmail = 'test@example.com';

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sign Up',
        theme: CustomTheme.lightTheme,
        themeMode: currentTheme.currentTheme,
        home: const CalendarSettings(
          calendars: dummyCalendars,
          userId: dummyUserId,
          email: dummyEmail,
        ),
      ),
    );
  }
}
