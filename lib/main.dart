import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';

import 'package:timelyst_flutter/screens/common/log_in.dart';

import 'themes.dart';

void main() {
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sign Up',
        theme: CustomTheme.lightTheme,
        themeMode: currentTheme.currentTheme,
        home: const LogInScreen(),
      ),
    );
  }
}
