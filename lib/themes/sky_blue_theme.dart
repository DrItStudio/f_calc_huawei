import 'package:flutter/material.dart';

final ThemeData skyBlueTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF2196F3), // насыщенный голубой (основной акцент)
  scaffoldBackgroundColor:
      const Color(0xFFE3F2FD), // очень светлый голубой (фон)
  cardColor: const Color(0xFFF5F5F5), // светло-серый для карточек

  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF2196F3), // насыщенный голубой
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
          color: Color(0x33000099),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    elevation: 2,
    shadowColor: Color(0x332196F3),
  ),

  colorScheme: const ColorScheme.light(
    primary: Color(0xFF2196F3), // голубой для акцентов и активных
    secondary: Color(0xFF1565C0), // тёмно-голубой для выделения
    background: Color(0xFFE3F2FD), // очень светлый голубой
    surface: Color(0xFFF5F5F5), // светло-серый
    onPrimary: Colors.white, // белый текст/иконки на голубом фоне
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
      color: Color(0xFF1565C0),
      fontSize: 24,
      fontWeight: FontWeight.bold,
      fontFamily: 'Montserrat',
      letterSpacing: 1.1,
    ),
    titleMedium: TextStyle(
      color: Color(0xFF1565C0),
      fontWeight: FontWeight.bold,
    ),
    titleSmall: TextStyle(
      color: Color(0xFF1565C0),
      fontWeight: FontWeight.w600,
    ),
    labelLarge: TextStyle(
      color: Color(0xFF2196F3),
      fontWeight: FontWeight.bold,
    ),
  ),

  iconTheme: const IconThemeData(
    color: Color(0xFF1565C0), // тёмно-голубой
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white, // белый текст на голубом фоне
      backgroundColor: Color(0xFF2196F3), // голубой фон
      shadowColor: Color(0x332196F3),
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
      foregroundColor: Color(0xFF1565C0),
      side: const BorderSide(color: Color(0xFF2196F3), width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle:
          const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Color(0xFF1565C0),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF2196F3),
    foregroundColor: Colors.white,
    elevation: 7,
  ),

  cardTheme: CardThemeData(
    color: const Color(0xFFF5F5F5),
    elevation: 5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    shadowColor: const Color(0x332196F3),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFE3F2FD), // очень светлый голубой
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2.5),
    ),
    labelStyle: const TextStyle(color: Color(0xFF1565C0)),
    hintStyle:
        const TextStyle(color: Color(0xFF888888), fontWeight: FontWeight.w400),
    suffixStyle: const TextStyle(color: Color(0xFF2196F3)),
  ),

  dividerColor: const Color(0xFF2196F3),
  highlightColor: const Color(0xFFBBDEFB), // светло-голубой
  splashColor: const Color(0xFF90CAF9), // светло-голубой
  hoverColor: const Color(0xFFF5F5F5), // светло-серый

  popupMenuTheme: PopupMenuThemeData(
    color: const Color(0xFFF5F5F5),
    textStyle: const TextStyle(color: Color(0xFF1565C0)),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFF2196F3), width: 1),
    ),
    elevation: 8,
  ),

  drawerTheme: const DrawerThemeData(
    backgroundColor: Color(0xFFE3F2FD), // очень светлый голубой
    scrimColor: Colors.black26,
    elevation: 10,
  ),

  listTileTheme: const ListTileThemeData(
    iconColor: Color(0xFF1565C0), // неактивная иконка — тёмно-голубая
    textColor: Color(0xFF1565C0), // неактивный текст — тёмно-голубой
    tileColor: Color(0xFFE3F2FD), // неактивный фон — очень светлый голубой
    selectedColor: Colors.white, // активная иконка и текст — белые
    selectedTileColor: Color(0xFF2196F3), // активный фон — голубой
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
    dense: true,
  ),
);
