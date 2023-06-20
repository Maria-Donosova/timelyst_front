import 'package:flutter/material.dart';

CustomTheme currentTheme = CustomTheme();

class CustomTheme with ChangeNotifier {
  static bool _isDarkTheme = true;
  ThemeMode get currentTheme => _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    _isDarkTheme = !_isDarkTheme;
    notifyListeners();
  }

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: Colors.white,
      scaffoldBackgroundColor: Colors.white,
      shadowColor: const Color.fromRGBO(207, 204, 215, 100),
      hintColor: Colors.grey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'FontAwesome',
      iconTheme: IconThemeData(
        color: Colors.grey[900],
        size: 28,
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.grey[900], fontSize: 20),
        displayMedium: TextStyle(color: Colors.grey[900], fontSize: 18),
        bodyLarge: TextStyle(color: Colors.grey[900], fontSize: 16),
        bodyMedium: TextStyle(color: Colors.grey[800], fontSize: 16),
        titleMedium: TextStyle(color: Colors.grey[900], fontSize: 16),
        titleSmall: TextStyle(color: Colors.grey[800], fontSize: 16),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: Colors.grey[700],
      scaffoldBackgroundColor: Colors.grey[900],
      shadowColor: const Color.fromRGBO(207, 204, 215, 100),
      hintColor: Colors.grey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      fontFamily: 'FontAwesome',
      iconTheme: const IconThemeData(
        color: Colors.white70,
        size: 28,
      ),
      textTheme: TextTheme(
          displayLarge: const TextStyle(color: Colors.white10, fontSize: 20),
          displayMedium: const TextStyle(color: Colors.white10, fontSize: 18),
          bodyLarge: const TextStyle(color: Colors.white10, fontSize: 16),
          labelLarge: TextStyle(backgroundColor: Colors.grey[900])),
    );
  }
}
