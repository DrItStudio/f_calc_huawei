import 'package:flutter/material.dart';

final ThemeData neonLimeTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF00FF00), // неоновый лайм
  scaffoldBackgroundColor: const Color(0xFF000000), // чёрный фон
  cardColor: const Color(0xFF1C1C1C), // тёмные карточки
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1B5E20), // тёмно-зелёный
    foregroundColor: Color(0xFF00FF00), // неоновый текст и иконки
    iconTheme: IconThemeData(color: Color(0xFF00FF00)),
    titleTextStyle: TextStyle(
      color: Color(0xFF00FF00),
      fontWeight: FontWeight.w900,
      fontSize: 24,
      fontFamily: 'Montserrat',
      letterSpacing: 1.3,
      shadows: [
        Shadow(
          color: Color(0x8800FF00),
          blurRadius: 10,
          offset: Offset(0, 2),
        ),
      ],
    ),
    elevation: 3,
    shadowColor: Color(0xFF00FF00),
  ),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF00FF00),
    secondary: Color(0xFF1B5E20),
    background: Color(0xFF000000),
    surface: Color(0xFF1C1C1C),
    onPrimary: Color(0xFF000000),
    onSecondary: Color(0xFF00FF00),
    onBackground: Color(0xFF00FF00),
    onSurface: Color(0xFF00FF00),
    error: Colors.redAccent,
    onError: Colors.white,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF00FF00)),
    bodyMedium: TextStyle(color: Color(0xFF00FF00)),
    titleLarge: TextStyle(
      color: Color(0xFF00FF00),
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
      letterSpacing: 1.1,
      shadows: [
        Shadow(
          color: Color(0x8800FF00),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
  ),
  iconTheme: const IconThemeData(
    color: Color(0xFF00FF00),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Color(0xFF000000), // чёрный текст на неоновом фоне
      backgroundColor: Color(0xFF00FF00), // неоновый фон
      shadowColor: Color(0xFF00FF00),
      elevation: 8,
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
    color: const Color(0xFF1C1C1C),
    elevation: 6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    shadowColor: const Color(0xFF00FF00),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF1C1C1C),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF00FF00), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF00FF00), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF00FF00), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFF00FF00)),
    hintStyle:
        const TextStyle(color: Color(0xFF00FF00), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFF00FF00)),
  ),
  dividerColor: const Color(0xFF00FF00),
  highlightColor: Colors.greenAccent[100],
  splashColor: Colors.greenAccent[400],
  hoverColor: Colors.greenAccent[700],
  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF1C1C1C),
    textStyle: const TextStyle(color: Color(0xFF00FF00)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFF00FF00), width: 1),
    ),
    elevation: 8,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF00FF00),
    foregroundColor: Color(0xFF000000),
    elevation: 8,
  ),
  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF1C1C1C),
    scrimColor: Colors.black54,
    elevation: 12,
  ),
);
