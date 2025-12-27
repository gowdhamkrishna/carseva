import 'package:flutter/material.dart';

enum AppThemeData { darkTheme, LightTheme }

final AppData = {
  AppThemeData.darkTheme: ThemeData(
    brightness: Brightness.dark,
    primaryColor: const Color.fromARGB(255, 37, 37, 37),
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: Colors.white70,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.white,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.white70,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.white,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        color: Colors.white60,
      ),
    ),
  ),

  AppThemeData.LightTheme: ThemeData(
    brightness: Brightness.light,
    primaryColor: const Color.fromARGB(255, 255, 253, 253),
    scaffoldBackgroundColor: Colors.white,
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      displayMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.black,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.black87,
      ),
      titleMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        color: Colors.black54,
      ),
    ),
  ),
};
