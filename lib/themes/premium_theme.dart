import 'package:flutter/material.dart';

final ThemeData premiumTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFA8FF04), // Салатовый
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Color(0xFFA8FF04),
    iconTheme: IconThemeData(color: Color(0xFFA8FF04)),
    titleTextStyle: TextStyle(
      color: Color(0xFFA8FF04),
      fontWeight: FontWeight.bold,
      fontSize: 22,
      letterSpacing: 1.2,
    ),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFA8FF04),      // Салатовый
    secondary: Colors.red,           // Красный акцент
    background: Colors.black,
    surface: Color(0xFF222222),
    onPrimary: Colors.black,
    onSecondary: Colors.white,
    onBackground: Color(0xFFA8FF04),
    onSurface: Color(0xFFA8FF04),
    error: Colors.red,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFA8FF04)),
    bodyMedium: TextStyle(color: Color(0xFFA8FF04)),
    titleLarge: TextStyle(color: Color(0xFFA8FF04), fontWeight: FontWeight.bold),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFA8FF04)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFA8FF04),
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      shadowColor: Colors.redAccent,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFA8FF04),
      side: const BorderSide(color: Color(0xFFA8FF04), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFA8FF04),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFA8FF04),
    foregroundColor: Colors.black,
  ),
  dialogBackgroundColor: const Color(0xFF181818),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF222222),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFA8FF04), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFA8FF04), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFA8FF04), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFFA8FF04)),
    hintStyle: const TextStyle(color: Color(0xFFA8FF04), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFFA8FF04)),
  ),
  cardColor: const Color(0xFF222222),
  dividerColor: Color(0xFFA8FF04),
  highlightColor: Colors.red[100],
  splashColor: Colors.red[200],
  hoverColor: Colors.red[50],
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF222222),
    textStyle: const TextStyle(color: Color(0xFFA8FF04)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFA8FF04), width: 1),
    ),
    elevation: 6,
  ),
);