import 'package:flutter/material.dart';

class Styles {
  // Colors
  static const Color customColor = Color(0xFF88683E);
  static const Color customColor50 = Color(0x7388683E);
  static const Color primaryColor = Color(0xFF000000);
  static const Color seconderyColor = Color(0xFF131010);
  static const Color shineColor = Color(0xFFA8835A);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkcardBackground = Color(0xFF232121); // Dark mode background
  static const Color lightBackground = Color(0xFFFFFFFF); // Light mode background

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: customColor,
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    colorScheme: ColorScheme.light(
      primary: customColor,
      secondary: customColor50,
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: darkBackground,
    scaffoldBackgroundColor: darkBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: seconderyColor,
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    colorScheme: ColorScheme.dark(
      primary: shineColor,
      secondary: customColor,
    ),
  );
}
