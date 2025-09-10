import 'package:flutter/material.dart';

final ThemeData greenTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFF388E3C),
  scaffoldBackgroundColor: const Color(0xFFE8F5E9),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF1B5E20),
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF388E3C),
    secondary: Colors.black,
    background: Color(0xFFE8F5E9),
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black,
    onSurface: Colors.black,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black87),
    titleLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF388E3C)),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF388E3C),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(color: Color(0xFF388E3C)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: const Color(0xFF388E3C),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF388E3C),
    foregroundColor: Colors.white,
  ),
  dialogBackgroundColor: const Color(0xFFE8F5E9),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.black, width: 2.5),
    ),
    labelStyle: const TextStyle(color: Colors.black),
    hintStyle: const TextStyle(color: Colors.black54),
    suffixStyle: const TextStyle(color: Colors.black),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF388E3C), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.black, width: 2.5),
      ),
      labelStyle: const TextStyle(color: Colors.black),
      hintStyle: const TextStyle(color: Colors.black54),
      suffixStyle: const TextStyle(color: Colors.black),
    ),
    menuStyle: MenuStyle(
      backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
      surfaceTintColor: MaterialStateProperty.all<Color>(Color(0xFFE8F5E9)),
      elevation: MaterialStateProperty.all<double>(2),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
    textStyle: const TextStyle(color: Colors.black),
  ),
  cardColor: Colors.white,
  dividerColor: Colors.green,
  highlightColor: Colors.green[100],
  splashColor: Colors.green[200],
  hoverColor: Colors.green[50],
  // Для PopupMenuButton (контекстные меню)
  popupMenuTheme: PopupMenuThemeData(
    color: Colors.white,
    textStyle: const TextStyle(color: Colors.black),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: const BorderSide(color: Color(0xFF388E3C), width: 1),
    ),
    elevation: 4,
  ),
);