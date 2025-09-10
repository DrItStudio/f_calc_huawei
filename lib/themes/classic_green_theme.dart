import 'package:flutter/material.dart';

final ThemeData classicGreenTheme = ThemeData(
  brightness: Brightness.light,

  primaryColor: const Color(0xFF388E3C),
  scaffoldBackgroundColor: const Color(0xFFF6FFF7),

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF388E3C),
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w900,
      fontSize: 24,
      fontFamily: 'Montserrat',
      letterSpacing: 1.2,
      shadows: [
        Shadow(
          color: Colors.black26,
          blurRadius: 4,
          offset: Offset(1, 2),
        ),
      ],
    ),
    elevation: 2,
    shadowColor: Colors.black38,
  ),

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF388E3C),
    secondary: Color(0xFF388E3C),
    background: Color(0xFFF6FFF7),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Color(0xFF388E3C),
    onBackground: Color(0xFF222D23),
    onSurface: Color(0xFF388E3C),
    error: Colors.red,
    onError: Colors.white,
  ),

  iconTheme: const IconThemeData(color: Color(0xFF388E3C)),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF388E3C),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(22)),
      ),
      side: const BorderSide(color: Color(0xFF388E3C), width: 2),
      elevation: 2,
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Color(0xFF388E3C),
      side: const BorderSide(color: Color(0xFF388E3C), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Color(0xFF388E3C),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF388E3C),
    foregroundColor: Colors.white,
  ),

  dialogBackgroundColor: Colors.white,

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFF388E3C)),
    hintStyle: const TextStyle(color: Color(0xFF388E3C), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFF388E3C)),
  ),

  cardColor: Colors.white,
  dividerColor: Color.fromARGB(255, 243, 243, 243),
  highlightColor: Colors.green[100],
  splashColor: Colors.green[200],
  hoverColor: Colors.green[50],

  popupMenuTheme: PopupMenuThemeData(
    color: Colors.white,
    textStyle: const TextStyle(color: Color(0xFF388E3C)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFF388E3C), width: 1),
    ),
    elevation: 6,
  ),

  // Основные стили текста
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF222D23)),
    bodyMedium: TextStyle(color: Color(0xFF222D23)),
    titleLarge: TextStyle(
      color: Colors.white, // Заголовки AppBar белые
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.black26,
          blurRadius: 4,
          offset: Offset(1, 2),
        ),
      ],
    ),
    titleMedium: TextStyle(
      color: Color(0xFF388E3C), // Подзаголовки тёмно-зелёные
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: Color(0xFF388E3C),
      fontWeight: FontWeight.w600,
    ),
    labelLarge: TextStyle(
      color: Color(0xFF388E3C),
      fontWeight: FontWeight.bold,
    ),
  ),
);