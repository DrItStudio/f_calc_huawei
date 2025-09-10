import 'package:flutter/material.dart';

final ThemeData springGrassTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor:
      const Color(0xFF8BC34A), // насыщенный салатовый (основной акцент)
  scaffoldBackgroundColor:
      const Color(0xFFF1FEEA), // очень светлый салатовый (фон)
  cardColor: const Color(0xFFF5F5F5), // светло-серый для карточек

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF8BC34A), // насыщенный салатовый
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
          color: Color(0x338BC34A),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    elevation: 2,
    shadowColor: Color(0x338BC34A),
  ),

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF8BC34A), // салатовый для акцентов и активных
    secondary: Color(0xFF558B2F), // тёмно-зелёный для выделения
    background: Color(0xFFF1FEEA), // очень светлый салатовый
    surface: Color(0xFFF5F5F5), // светло-серый
    onPrimary: Colors.white, // белый текст/иконки на салатовом фоне
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
      color: Color(0xFF558B2F),
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
      letterSpacing: 1.1,
    ),
    titleMedium: TextStyle(
      color: Color(0xFF558B2F),
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: Color(0xFF558B2F),
      fontWeight: FontWeight.w600,
    ),
    labelLarge: TextStyle(
      color: Color(0xFF8BC34A),
      fontWeight: FontWeight.bold,
    ),
  ),

  iconTheme: const IconThemeData(
    color: Color(0xFF558B2F), // тёмно-зелёный
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, // белый текст на салатовом фоне
      backgroundColor: Color(0xFF8BC34A), // салатовый фон
      shadowColor: Color(0x338BC34A),
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
      foregroundColor: Color(0xFF558B2F),
      side: const BorderSide(color: Color(0xFF8BC34A), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle:
          const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Color(0xFF558B2F),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF8BC34A),
    foregroundColor: Colors.white,
    elevation: 7,
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFFF5F5F5),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    shadowColor: const Color(0x338BC34A),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF1FEEA), // очень светлый салатовый
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF8BC34A), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF8BC34A), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF558B2F), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFF558B2F)),
    hintStyle:
        const TextStyle(color: Color(0xFF888888), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFF8BC34A)),
  ),

  dividerColor: const Color(0xFF8BC34A),
  highlightColor: const Color(0xFFD0F8CE), // светло-салатовый
  splashColor: const Color(0xFFAED581), // светло-зелёный
  hoverColor: const Color(0xFFF5F5F5), // светло-серый

  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFFF5F5F5),
    textStyle: const TextStyle(color: Color(0xFF558B2F)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFF8BC34A), width: 1),
    ),
    elevation: 8,
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFFF1FEEA), // очень светлый салатовый
    scrimColor: Colors.black26,
    elevation: 10,
  ),

  listTileTheme: const ListTileThemeData(
    iconColor: Color(0xFF558B2F), // неактивная иконка — тёмно-зелёная
    textColor: Color(0xFF558B2F), // неактивный текст — тёмно-зелёный
    tileColor: Color(0xFFF1FEEA), // неактивный фон — очень светлый салатовый
    selectedColor: Colors.white, // активная иконка и текст — белые
    selectedTileColor: Color(0xFF8BC34A), // активный фон — салатовый
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    dense: true,
  ),
);
