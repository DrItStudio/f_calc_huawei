import 'package:flutter/material.dart';

final ThemeData brownBeigeTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF3E2723), // Тёмно-коричневый фон
  primaryColor: const Color(0xFF8D6E63), // Светло-коричневый
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF3E2723), // Тёмно-коричневый AppBar
    foregroundColor: Color(0xFFFFECB3), // Бежевый текст и иконки
    iconTheme: IconThemeData(color: Color(0xFFFFECB3)),
    titleTextStyle: TextStyle(
      color: Color(0xFFFFECB3),
      fontWeight: FontWeight.bold,
      fontSize: 22,
      letterSpacing: 1.2,
      fontFamily: 'Montserrat',
      shadows: [
        Shadow(
          color: Colors.black26,
          blurRadius: 4,
          offset: Offset(1, 2),
        ),
      ],
    ),
    elevation: 2,
    shadowColor: Colors.black54,
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF8D6E63),
    secondary: Color(0xFF6D4C41),
    background: Color(0xFF3E2723),
    surface: Color(0xFF6D4C41),
    onPrimary: Color(0xFFFFECB3),
    onSecondary: Color(0xFFFFECB3),
    onBackground: Color(0xFFFFECB3),
    onSurface: Color(0xFFFFECB3),
    error: Colors.red,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFFFECB3)),
    bodyMedium: TextStyle(color: Color(0xFFFFECB3)),
    titleLarge: TextStyle(
      color: Color(0xFFFFECB3),
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFFFECB3),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Color(0xFFFFECB3),
      backgroundColor: Colors.transparent,
      shadowColor: Colors.black54,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        fontFamily: 'Montserrat',
      ),
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF6D4C41),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF6D4C41),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFFECB3), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFFECB3), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFFFECB3), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFFFFECB3)),
    hintStyle:
        const TextStyle(color: Color(0xFFFFECB3), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFFFFECB3)),
  ),
  dividerColor: const Color(0xFFFFECB3),
  highlightColor: Colors.brown[200],
  splashColor: Colors.brown[300],
  hoverColor: Colors.brown[100],
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF6D4C41),
    textStyle: const TextStyle(color: Color(0xFFFFECB3)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFFFECB3), width: 1),
    ),
    elevation: 6,
  ),
);
