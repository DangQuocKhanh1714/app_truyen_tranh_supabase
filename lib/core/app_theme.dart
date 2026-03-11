import 'package:flutter/material.dart';

class AppTheme {
  // Theme Tối (Mặc định hiện tại của bạn)
  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.redAccent,
    scaffoldBackgroundColor: const Color(0xFF121212),
    cardColor: const Color(0xFF1E1E1E),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF121212),
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: Colors.white70),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
    ),
  );

  // Theme Sáng (Mới thêm vào)
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.redAccent,
    scaffoldBackgroundColor: const Color(0xFFF2F2F7),
    cardColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0.5,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    iconTheme: const IconThemeData(color: Colors.black54),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Cho tiêu đề lớn
      bodyLarge: TextStyle(color: Color(0xFF1C1C1E)),
      bodyMedium: TextStyle(color: Colors.black54),
    ),
  );
}