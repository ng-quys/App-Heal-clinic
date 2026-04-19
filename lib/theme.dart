import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF185FA5);
  static const primaryLight = Color(0xFFE6F1FB);
  static const primaryDark = Color(0xFF0C447C);

  static const success = Color(0xFF3B6D11);
  static const successLight = Color(0xFFEAF3DE);

  static const warning = Color(0xFF854F0B);
  static const warningLight = Color(0xFFFAEEDA);

  static const danger = Color(0xFFA32D2D);
  static const dangerLight = Color(0xFFFCEBEB);

  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF5F6F8);
  static const border = Color(0xFFE5E5E5);

  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);

  static const avatarColors = [
    Color(0xFFE1F5EE),
    Color(0xFFE6F1FB),
    Color(0xFFFBEAF0),
    Color(0xFFFAEEDA),
    Color(0xFFEEEDFE),
  ];

  static const avatarTextColors = [
    Color(0xFF085041),
    Color(0xFF0C447C),
    Color(0xFF72243E),
    Color(0xFF633806),
    Color(0xFF3C3489),
  ];

  static Color avatarBg(int index) => avatarColors[index % avatarColors.length];
  static Color avatarText(int index) => avatarTextColors[index % avatarTextColors.length];
}

class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border, width: 0.5),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.5,
        space: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F0F2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.primary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
        unselectedLabelStyle: TextStyle(fontSize: 10),
      ),
    );
  }
}
