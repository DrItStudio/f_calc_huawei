import 'package:flutter/material.dart';

final ThemeData classicDarkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF424242), // глубокий серый для акцентов
  scaffoldBackgroundColor:
      const Color(0xFF23272A), // тёмно-серый фон, но не чёрный
  cardColor: const Color(0xFF2C2F33), // чуть светлее для карточек

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF23272A), // тёмно-серый
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w900,
      fontSize: 24,
      fontFamily: 'Montserrat',
      letterSpacing: 1.3,
      shadows: [
        Shadow(
          color: Color(0x33000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    elevation: 2,
    shadowColor: Color(0x332C2F33),
  ),

  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF424242), // глубокий серый
    secondary: Color(0xFF90CAF9), // голубой акцент
    background: Color(0xFF23272A), // тёмно-серый
    surface: Color(0xFF2C2F33), // чуть светлее
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onBackground: Colors.white,
    onSurface: Colors.white,
    error: Colors.red,
    onError: Colors.white,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(
        color: Color(0xFFB0BEC5)), // светло-серый для второстепенного текста
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
      letterSpacing: 1.1,
    ),
    titleMedium: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: Color(0xFFB0BEC5),
      fontWeight: FontWeight.w600,
    ),
    labelLarge: TextStyle(
      color: Color(0xFF90CAF9), // голубой акцент
      fontWeight: FontWeight.bold,
    ),
  ),

  iconTheme: const IconThemeData(
    color: Colors.white,
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Color(0xFF424242),
      shadowColor: Color(0x33424242),
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

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF90CAF9), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle:
          const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Color(0xFF90CAF9),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF90CAF9),
    foregroundColor: Colors.black,
    elevation: 7,
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFF2C2F33),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    shadowColor: const Color(0x33424242),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFF23272A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF90CAF9), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Colors.white),
    hintStyle:
        const TextStyle(color: Color(0xFFB0BEC5), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFF90CAF9)),
  ),

  dividerColor: const Color(0xFF424242),
  highlightColor: const Color(0xFF37474F),
  splashColor: const Color(0xFF616161),
  hoverColor: const Color(0xFF2C2F33),

  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFF2C2F33),
    textStyle: const TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFF90CAF9), width: 1),
    ),
    elevation: 8,
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFF23272A),
    scrimColor: Colors.black26,
    elevation: 10,
  ),

  listTileTheme: const ListTileThemeData(
    iconColor: Colors.white, // неактивная иконка — белая
    textColor: Colors.white, // неактивный текст — белый
    tileColor: Color(0xFF23272A), // неактивный фон — тёмно-серый
    selectedColor: Color(0xFF90CAF9), // активная иконка и текст — голубые
    selectedTileColor: Color(0xFF424242), // активный фон — глубокий серый
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    dense: true,
  ),
);
