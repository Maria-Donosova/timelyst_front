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
      colorScheme: ColorScheme.light(
        primary: Colors.white,
        onPrimary: Colors.grey[900]!,
        secondary: Colors.grey[800]!,
        onSecondary: Colors.white,
        error: Colors.redAccent,
        onError: Colors.grey[900]!,
        surface: Colors.white,
        onSurface: Colors.grey[900]!,
        shadow: const Color.fromRGBO(207, 204, 215, 100),
      ),
      // buttonTheme: ButtonThemeData(
      //   buttonColor: Colors.grey[700]!,
      // ),

      fontFamily: 'FontAwesome',
      iconTheme: IconThemeData(
        color: Colors.grey[900],
        size: 20,
      ),
      chipTheme: ChipThemeData(side: BorderSide.none, showCheckmark: false),
      textTheme: TextTheme(
        displayLarge: TextStyle(color: Colors.grey[900], fontSize: 20),
        displayMedium: TextStyle(color: Colors.grey[900], fontSize: 18),
        displaySmall: TextStyle(color: Colors.grey[900], fontSize: 16),
        bodyLarge: TextStyle(color: Colors.grey[900], fontSize: 14),
        bodyMedium: TextStyle(color: Colors.grey[800], fontSize: 12),
        bodySmall: TextStyle(color: Colors.grey[800], fontSize: 10),
        titleMedium: TextStyle(color: Colors.grey[900], fontSize: 16),
        titleSmall: TextStyle(color: Colors.grey[800], fontSize: 12),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      colorScheme: ColorScheme.dark(
        primary: Colors.grey[700]!,
        onPrimary: Colors.white,
        secondary: Colors.white,
        onSecondary: Colors.grey[800]!,
        error: Colors.redAccent,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: Colors.grey[700]!,
        shadow: Colors.grey[500]!,
      ),
      fontFamily: 'FontAwesome',
      iconTheme: const IconThemeData(
        color: Colors.black45,
        size: 28,
      ),
      textTheme: TextTheme(
          displayLarge: const TextStyle(color: Colors.white10, fontSize: 20),
          displayMedium: const TextStyle(color: Colors.white10, fontSize: 18),
          displaySmall: const TextStyle(color: Colors.white10, fontSize: 12),
          bodyLarge: const TextStyle(color: Colors.white10, fontSize: 16),
          bodySmall: TextStyle(color: Colors.white10, fontSize: 8),
          labelLarge: TextStyle(backgroundColor: Colors.grey[900])),
    );
  }
}
