import 'package:flutter/material.dart';

final ThemeData copperPeachTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFB87333), // медь
  scaffoldBackgroundColor: const Color(0xFF1A1A1A), // глубокий тёмный фон
  cardColor: const Color(0xFF2C2C2C), // тёмные карточки
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFB87333), // медный AppBar
    foregroundColor: Color(0xFFFFCC80), // персиковый текст и иконки
    iconTheme: IconThemeData(color: Color(0xFFFFCC80)),
    titleTextStyle: TextStyle(
      color: Color(0xFFFFCC80),
      fontWeight: FontWeight.w900,
      fontSize: 24,
      fontFamily: 'Montserrat',
      letterSpacing: 1.2,
      shadows: [
        Shadow(
          color: Colors.black45,
          blurRadius: 8,
          offset: Offset(1, 2),
        ),
      ],
    ),
    elevation: 4,
    shadowColor: Colors.black87,
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFB87333),
    secondary: Color(0xFFFFCC80),
    background: Color(0xFF1A1A1A),
    surface: Color(0xFF2C2C2C),
    onPrimary: Color(0xFFFFCC80),
    onSecondary: Color(0xFFB87333),
    onBackground: Colors.white,
    onSurface: Colors.white,
    error: Colors.redAccent,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
    titleLarge: TextStyle(
      color: Color(0xFFFFCC80),
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
      letterSpacing: 1.1,
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFFFFCC80),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Color(0xFFB87333), // текст и иконки на кнопке
      backgroundColor: Color(0xFFFFCC80), // персиковый фон
      shadowColor: Color(0xFFB87333),
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
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
    color: const Color(0xFF2C2C2C),
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    shadowColor: Colors.black54,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF232323),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFFCC80), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFFCC80), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFFFCC80), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFFFFCC80)),
    hintStyle:
        const TextStyle(color: Color(0xFFFFCC80), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFFFFCC80)),
  ),
  dividerColor: const Color(0xFFFFCC80),
  highlightColor: Colors.orange[100],
  splashColor: Colors.orange[200],
  hoverColor: Colors.orange[50],
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF2C2C2C),
    textStyle: const TextStyle(color: Color(0xFFFFCC80)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFFFFCC80), width: 1),
    ),
    elevation: 8,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFFFFCC80),
    foregroundColor: Color(0xFFB87333),
    elevation: 7,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF2C2C2C),
    scrimColor: Colors.black54,
    elevation: 12,
  ),
);
