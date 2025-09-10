import 'package:flutter/material.dart';

final ThemeData purpleLavenderTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF6A1B9A), // глубокий фиолетовый
  scaffoldBackgroundColor: const Color(0xFF121212), // очень тёмный фон
  cardColor: const Color(0xFF1E1E1E), // тёмные карточки
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF6A1B9A),
    foregroundColor: Color(0xFFE1BEE7),
    iconTheme: IconThemeData(color: Color(0xFFE1BEE7)),
    titleTextStyle: TextStyle(
      color: Color(0xFFE1BEE7),
      fontWeight: FontWeight.w900,
      fontSize: 24,
      fontFamily: 'Montserrat',
      letterSpacing: 1.2,
      shadows: [
        Shadow(
          color: Colors.black38,
          blurRadius: 6,
          offset: Offset(1, 2),
        ),
      ],
    ),
    elevation: 3,
    shadowColor: Colors.black87,
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF6A1B9A),
    secondary: Color(0xFFE1BEE7),
    background: Color(0xFF121212),
    surface: Color(0xFF1E1E1E),
    onPrimary: Color(0xFFE1BEE7),
    onSecondary: Color(0xFF6A1B9A),
    onBackground: Colors.white,
    onSurface: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(
      color: Color(0xFFE1BEE7),
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
      letterSpacing: 1.1,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFE1BEE7),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Color(0xFF6A1B9A), // текст и иконки на кнопке
      backgroundColor: Color(0xFFE1BEE7), // лавандовый фон
      shadowColor: Color(0xFF6A1B9A),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
        fontFamily: 'Montserrat',
        letterSpacing: 1.1,
      ),
    ),
  ),
  cardTheme: CardThemeData(
    color: const Color(0xFF1E1E1E),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    shadowColor: Colors.black54,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF232323),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE1BEE7), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE1BEE7), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE1BEE7), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFFE1BEE7)),
    hintStyle:
        const TextStyle(color: Color(0xFFE1BEE7), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFFE1BEE7)),
  ),
  dividerColor: const Color(0xFFE1BEE7),
  highlightColor: Colors.purple[100],
  splashColor: Colors.purple[200],
  hoverColor: Colors.purple[50],
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF1E1E1E),
    textStyle: const TextStyle(color: Color(0xFFE1BEE7)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: Color(0xFFE1BEE7), width: 1),
    ),
    elevation: 8,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFE1BEE7),
    foregroundColor: Color(0xFF6A1B9A),
    elevation: 6,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    scrimColor: Colors.black54,
    elevation: 10,
  ),
);
