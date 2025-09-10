import 'package:flutter/material.dart';

final ThemeData blueGoldTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF0D47A1), // глубокий синий
  scaffoldBackgroundColor: const Color(0xFF0A0E21), // тёмный фон
  cardColor: const Color(0xFF1E2746), // тёмно-синий для карточек
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0D47A1),
    foregroundColor: Color(0xFFFFD700),
    iconTheme: IconThemeData(color: Color(0xFFFFD700)),
    titleTextStyle: TextStyle(
      color: Color(0xFFFFD700),
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
    primary: Color(0xFF0D47A1),
    secondary: Color(0xFFFFD700),
    background: Color(0xFF0A0E21),
    surface: Color(0xFF1E2746),
    onPrimary: Color(0xFFFFD700),
    onSecondary: Color(0xFF0D47A1),
    onBackground: Colors.white,
    onSurface: Colors.white,
    error: Colors.red,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(
      color: Color(0xFFFFD700),
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFFFD700),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Color(0xFF0D47A1), // текст и иконки на кнопке
      backgroundColor: Color(0xFFFFD700), // золотой фон
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
    color: const Color(0xFF1E2746),
    elevation: 3,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1E2746),
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
    hintStyle:
        const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFFFFD700)),
  ),
  dividerColor: const Color(0xFFFFD700),
  highlightColor: Colors.yellow[100],
  splashColor: Colors.yellow[300],
  hoverColor: Colors.yellow[50],
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF1E2746),
    textStyle: const TextStyle(color: Color(0xFFFFD700)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFFFD700), width: 1),
    ),
    elevation: 6,
  ),
);
