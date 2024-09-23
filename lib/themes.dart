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
        secondary: const Color.fromRGBO(238, 243, 246, 1.0),
        onSecondary: Colors.grey[900]!,
        tertiary: Colors.grey[600]!,
        error: Colors.redAccent,
        onError: Colors.grey[900]!,
        surface: Colors.white,
        onSurface: Colors.grey[900]!,
        shadow: const Color.fromRGBO(207, 204, 215, 100),
      ),
      fontFamily: 'Lora',
      iconTheme: IconThemeData(
        color: Colors.grey[800],
        size: 16,
      ),
      chipTheme: ChipThemeData(side: BorderSide.none, showCheckmark: false),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey[900]!, // Button text color
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.grey[900]!,
        selectionColor: Color.fromRGBO(207, 204, 215, 100),
        selectionHandleColor: Colors.grey[800]!,
      ),
      radioTheme: RadioThemeData(
        fillColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.grey[900]!; // Color when the radio button is selected
          }
          return Colors
              .grey[900]!; // Color when the radio button is not selected
        }),
        // Color of the ripple effect
      ),
      checkboxTheme: CheckboxThemeData(
        checkColor:
            WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return Colors
                .grey[900]!; // Color of the check icon when it's selected
          }
          return Colors
              .transparent; // Color of the check icon when it's not selected
        }),
        side: BorderSide(color: Colors.grey[900]!),
      ),
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
