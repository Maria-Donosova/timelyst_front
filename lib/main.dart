import 'package:flutter/material.dart';

import 'themes.dart';

//import 'screens/common/sign_up.dart';
// import 'screens/common/log_in.dart';
import 'screens/common/agenda.dart';

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
      title: 'Agenda',
      theme: CustomTheme.lightTheme,
      themeMode: currentTheme.currentTheme,
      home: const Agenda(),
    );
  }
}
