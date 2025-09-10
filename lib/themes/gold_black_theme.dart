import 'package:flutter/material.dart';

final ThemeData goldBlackTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFFFD700), // Золотой
  scaffoldBackgroundColor: const Color(0xFF181818), // Чуть светлее, чем AppBar
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    foregroundColor: Color(0xFFFFD700),
    iconTheme: IconThemeData(color: Color(0xFFFFD700)),
    titleTextStyle: TextStyle(
      color: Color(0xFFFFD700),
      fontWeight: FontWeight.bold,
      fontSize: 22,
      letterSpacing: 1.2,
    ),
    elevation: 4, // Добавлено для тени
    shadowColor: Color(0xFFFFD700), // Золотой отблеск под AppBar
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFFFFD700),
    secondary: Colors.black,
    background: Colors.black,
    surface: Color(0xFF222222),
    onPrimary: Colors.black,
    onSecondary: Color(0xFFFFD700),
    onBackground: Color(0xFFFFD700),
    onSurface: Color(0xFFFFD700),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFFFD700)),
    bodyMedium: TextStyle(color: Color(0xFFFFD700)),
    titleLarge: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFFFD700)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFFFD700),
      foregroundColor: Colors.black,
      textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 4,
      shadowColor: Colors.black54,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: const Color(0xFFFFD700),
      side: const BorderSide(color: Color(0xFFFFD700), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFFFFD700),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFFD700),
    foregroundColor: Colors.black,
  ),
  dialogBackgroundColor: const Color(0xFF181818),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF222222),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFFFFD700)),
    hintStyle: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFFFFD700)),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF222222),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2.5),
      ),
      labelStyle: const TextStyle(color: Color(0xFFFFD700)),
      hintStyle: const TextStyle(color: Color(0xFFFFD700)),
      suffixStyle: const TextStyle(color: Color(0xFFFFD700)),
    ),
    menuStyle: MenuStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Color(0xFF222222)),
      surfaceTintColor: MaterialStateProperty.all<Color>(Color(0xFF181818)),
      elevation: MaterialStateProperty.all<double>(4),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textStyle: const TextStyle(color: Color(0xFFFFD700)),
  ),
  cardColor: const Color(0xFF222222),
  dividerColor: Color(0xFFFFD700),
  highlightColor: Colors.amber[100],
  splashColor: Colors.amber[200],
  hoverColor: Colors.amber[50],
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF222222),
    textStyle: const TextStyle(color: Color(0xFFFFD700)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFFFD700), width: 1),
    ),
    elevation: 6,
  ),
);