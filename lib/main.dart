import 'package:flutter/material.dart';
import 'package:timelyst_flutter/screens/common/connect_calendars.dart';
import 'package:timelyst_flutter/screens/common/log_in.dart';
import 'package:timelyst_flutter/screens/common/sign_up.dart';

import 'themes.dart';

//import 'screens/common/sign_up.dart';
// import 'screens/common/log_in.dart';
//import 'screens/common/agenda.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Up',
      theme: CustomTheme.lightTheme,
      themeMode: currentTheme.currentTheme,
      home: const LogInScreen(),
    );
  }
}
