import 'package:flutter/material.dart';

class AppTheme {
  // Light mode - matching web shadcn/ui gray palette
  static const Color primary = Color(0xFF111827);
  static const Color primaryForeground = Color(0xFFF9FAFB);
  static const Color secondary = Color(0xFFF3F4F6);
  static const Color secondaryForeground = Color(0xFF111827);
  static const Color background = Color(0xFFFFFFFF);
  static const Color foreground = Color(0xFF111827);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardForeground = Color(0xFF111827);
  static const Color popover = Color(0xFFFFFFFF);
  static const Color popoverForeground = Color(0xFF111827);
  static const Color muted = Color(0xFFF3F4F6);
  static const Color mutedForeground = Color(0xFF6B7280);
  static const Color accent = Color(0xFFF3F4F6);
  static const Color accentForeground = Color(0xFF111827);
  static const Color destructive = Color(0xFFDC2626);
  static const Color border = Color(0xFFE5E7EB);
  static const Color input = Color(0xFFE5E7EB);
  static const Color ring = Color(0xFF9CA3AF);

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
      scaffoldBackgroundColor: Colors.white,
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
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.04),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
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

  // Dark mode - matching web shadcn/ui zinc palette
  static const Color darkPrimary = Color(0xFFE5E7EB);
  static const Color darkPrimaryForeground = Color(0xFF18181B);
  static const Color darkBackground = Color(0xFF18181B);
  static const Color darkSurface = Color(0xFF27272A);
  static const Color darkForeground = Color(0xFFF8FAFC);
  static const Color darkCard = Color(0xFF27272A);
  static const Color darkBorder = Color(0x14FFFFFF);
  static const Color darkMutedForeground = Color(0xFFA1A1AA);
  static const Color darkDestructive = Color(0xFFEF4444);
  static const Color darkInputBg = Color(0x1AFFFFFF);
  static const Color darkAccent = Color(0xFF3F3F46);
  static const Color darkAccentForeground = Color(0xFFF8FAFC);

  // Dark mode badge colors - matching web dark:bg-*-900/35 and dark:text-*-200/300
  static const Color darkBadgeBlueBg = Color(0x591E3A8A);
  static const Color darkBadgeBlueText = Color(0xFFBFDBFE);
  static const Color darkBadgeGreenBg = Color(0x5914532D);
  static const Color darkBadgeGreenText = Color(0xFF86EFAC);
  static const Color darkBadgeRedBg = Color(0x597F1D1D);
  static const Color darkBadgeRedText = Color(0xFFFCA5A5);
  static const Color darkBadgeOrangeBg = Color(0x597C2D12);
  static const Color darkBadgeOrangeText = Color(0xFFFDBA74);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: darkPrimary,
        onPrimary: darkPrimaryForeground,
        secondary: darkSurface,
        onSecondary: darkForeground,
        surface: darkSurface,
        onSurface: darkForeground,
        error: darkDestructive,
        outline: darkBorder,
      ),
      scaffoldBackgroundColor: darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: darkSurface,
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
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: darkBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
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
          borderSide: const BorderSide(color: darkPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: darkPrimary,
          foregroundColor: darkPrimaryForeground,
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
        style: TextButton.styleFrom(foregroundColor: darkPrimary),
      ),
      dividerTheme: const DividerThemeData(color: Color(0x14FFFFFF), thickness: 1),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: darkForeground),
        headlineMedium: TextStyle(color: darkForeground),
        headlineSmall: TextStyle(color: darkForeground),
        titleLarge: TextStyle(color: darkForeground),
        titleMedium: TextStyle(color: darkForeground),
        titleSmall: TextStyle(color: darkForeground),
        bodyLarge: TextStyle(color: darkForeground),
        bodyMedium: TextStyle(color: darkForeground),
        bodySmall: TextStyle(color: darkForeground),
        labelLarge: TextStyle(color: darkForeground),
        labelMedium: TextStyle(color: darkForeground),
        labelSmall: TextStyle(color: darkForeground),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: darkPrimary,
        selectionColor: darkPrimary.withValues(alpha: 0.3),
        selectionHandleColor: darkPrimary,
      ),
    );
  }
}
