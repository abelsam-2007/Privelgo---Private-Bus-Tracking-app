import 'package:flutter/material.dart';

class PrivelgoTheme {
  // Brand Color Palette
  static const Color darkBlue = Color(0xFF184E6C);
  static const Color steelBlue = Color(0xFF387EA2);
  static const Color skyBlue = Color(0xFF5BA3C6);
  static const Color lightBlue = Color(0xFF9BCBE5);
  static const Color backgroundWhite = Color(0xFFDDECF6);
  
  static const Color textDark = Color(0xFF1C2A38);
  static const Color textLight = Color(0xFFF1F6FA);
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: darkBlue,
        secondary: steelBlue,
        tertiary: skyBlue,
        background: backgroundWhite,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onBackground: textDark,
      ),
      scaffoldBackgroundColor: backgroundWhite,
      cardTheme: CardTheme(
        color: Colors.white.withOpacity(0.9), // Glassmorphic translucent white
        elevation: 6,
        shadowColor: darkBlue.withOpacity(0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.bold, color: darkBlue),
        titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: darkBlue),
        bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, color: textDark),
        bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, color: textDark),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: skyBlue,
        secondary: steelBlue,
        tertiary: darkBlue,
        background: Color(0xFF101C24),
        surface: Color(0xFF182834),
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onBackground: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF101C24),
      cardTheme: CardTheme(
        color: const Color(0xFF182834).withOpacity(0.85),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Inter', fontSize: 32, fontWeight: FontWeight.bold, color: textLight),
        titleLarge: TextStyle(fontFamily: 'Inter', fontSize: 20, fontWeight: FontWeight.w600, color: textLight),
        bodyLarge: TextStyle(fontFamily: 'Inter', fontSize: 16, color: textLight),
        bodyMedium: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Colors.white70),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF182834),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
