import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF353535);
  static const Color primaryForeground = Color(0xFFFCFCFC);
  static const Color secondary = Color(0xFFF6F6F6);
  static const Color secondaryForeground = Color(0xFF353535);
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF222222);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF222222);
  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF222222);
  static const Color muted = Color(0xFFF6F6F6);
  static const Color mutedForeground = Color(0xFF71717A);
  static const Color accent = Color(0xFFF6F6F6);
  static const Color accentForeground = Color(0xFF353535);
  static const Color destructive = Color(0xFFE53935);
  static const Color border = Color(0xFFE5E5E5);
  static const Color input = Color(0xFFE5E5E5);
  static const Color ring = Color(0xFFB4B4B4);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        onPrimary: primaryForeground,
        secondary: secondary,
        onSecondary: secondaryForeground,
        surface: background,
        onSurface: foreground,
        error: destructive,
        outline: border,
      ),
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: foreground,
        elevation: 1,
        titleTextStyle: TextStyle(
          color: foreground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: primaryForeground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: border),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: primary),
      ),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
    );
  }

  static const Color darkPrimary = Color(0xFF4B4B4B);
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkForeground = Color(0xFFF5F5F5);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkBorder = Color(0xFF404040);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: Colors.blue,
        onPrimary: Colors.white,
        secondary: Colors.blueGrey,
        onSecondary: Colors.white,
        surface: darkSurface,
        onSurface: darkForeground,
        error: destructive,
        outline: darkBorder,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF2D2D2D),
        foregroundColor: darkForeground,
        elevation: 1,
        titleTextStyle: TextStyle(
          color: darkForeground,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.blue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkForeground,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.blue),
      ),
      dividerTheme: const DividerThemeData(color: darkBorder, thickness: 1),
    );
  }
}
