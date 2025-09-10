import 'package:flutter/material.dart';

final ThemeData forestTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor:
      const Color(0xFF388E3C), // глубокий лесной зелёный (основной акцент)
  scaffoldBackgroundColor:
      const Color(0xFFE8F5E9), // очень светлый зелёный (фон)
  cardColor: const Color(0xFFF5F5F5), // светло-серый для карточек

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF388E3C), // глубокий зелёный
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
          color: Color(0x33388E3C),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    elevation: 2,
    shadowColor: Color(0x33388E3C),
  ),

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF388E3C), // глубокий зелёный для акцентов и активных
    secondary: Color(0xFF1B5E20), // ещё более тёмный зелёный для выделения
    background: Color(0xFFE8F5E9), // очень светлый зелёный
    surface: Color(0xFFF5F5F5), // светло-серый
    onPrimary: Colors.white, // белый текст/иконки на зелёном фоне
    onSecondary: Colors.white,
    onBackground: Color(0xFF222D23), // почти чёрный для текста
    onSurface: Color(0xFF222D23),
    error: Colors.red,
    onError: Colors.white,
  ),

  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFF222D23)),
    bodyMedium: TextStyle(color: Color(0xFF444444)),
    titleLarge: TextStyle(
      color: Color(0xFF1B5E20),
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
      letterSpacing: 1.1,
    ),
    titleMedium: TextStyle(
      color: Color(0xFF1B5E20),
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: Color(0xFF1B5E20),
      fontWeight: FontWeight.w600,
    ),
    labelLarge: TextStyle(
      color: Color(0xFF388E3C),
      fontWeight: FontWeight.bold,
    ),
  ),

  iconTheme: const IconThemeData(
    color: Color(0xFF1B5E20), // тёмно-зелёный
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, // белый текст на зелёном фоне
      backgroundColor: Color(0xFF388E3C), // глубокий зелёный фон
      shadowColor: Color(0x33388E3C),
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
      foregroundColor: Color(0xFF1B5E20),
      side: const BorderSide(color: Color(0xFF388E3C), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle:
          const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Color(0xFF1B5E20),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF388E3C),
    foregroundColor: Colors.white,
    elevation: 7,
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFFF5F5F5),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    shadowColor: const Color(0x33388E3C),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFE8F5E9), // очень светлый зелёный
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFF1B5E20)),
    hintStyle:
        const TextStyle(color: Color(0xFF888888), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFF388E3C)),
  ),

  dividerColor: const Color(0xFF388E3C),
  highlightColor: const Color(0xFFC8E6C9), // светло-зелёный
  splashColor: const Color(0xFFA5D6A7), // светло-зелёный
  hoverColor: const Color(0xFFF5F5F5), // светло-серый

  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFFF5F5F5),
    textStyle: const TextStyle(color: Color(0xFF1B5E20)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFF388E3C), width: 1),
    ),
    elevation: 8,
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFFE8F5E9), // очень светлый зелёный
    scrimColor: Colors.black26,
    elevation: 10,
  ),

  listTileTheme: const ListTileThemeData(
    iconColor: Color(0xFF1B5E20), // неактивная иконка — тёмно-зелёная
    textColor: Color(0xFF1B5E20), // неактивный текст — тёмно-зелёный
    tileColor: Color(0xFFE8F5E9), // неактивный фон — очень светлый зелёный
    selectedColor: Colors.white, // активная иконка и текст — белые
    selectedTileColor: Color(0xFF388E3C), // активный фон — глубокий зелёный
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    dense: true,
  ),
);
