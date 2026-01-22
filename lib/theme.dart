import 'package:flutter/material.dart';

class AppColors {
  static const Color peach = Color(0xFFFFA38F);
  static const Color peachSoft = Color(0xFFFFD3BF);
  static const Color mint = Color(0xFF8FD6C1);
  static const Color cream = Color(0xFFFDF3E7);
  static const Color deepNavy = Color(0xFF1F2844);
  static const Color darkBg = Color(0xFF171D32);

  static Color subtleShadow = Colors.black.withOpacity(0.12);
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  scaffoldBackgroundColor: AppColors.cream,
  primaryColor: AppColors.peach,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.peach,
    primary: AppColors.peach,
    secondary: AppColors.mint,
    surface: AppColors.cream,
    background: AppColors.cream,
    onPrimary: Colors.white,
    onSecondary: AppColors.deepNavy,
  ),
  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: AppColors.deepNavy),
    displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w500, color: AppColors.deepNavy),
    headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: AppColors.deepNavy),
    headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppColors.deepNavy),
    titleLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppColors.deepNavy),
    bodyLarge: TextStyle(fontSize: 16, color: AppColors.deepNavy),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.deepNavy),
    bodySmall: TextStyle(fontSize: 12, color: AppColors.deepNavy),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.peach,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.deepNavy,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Poppins'),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.deepNavy,
    selectedItemColor: AppColors.peach,
    unselectedItemColor: Colors.white70,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
);
