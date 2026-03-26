import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0A0A0F);
  static const bg2 = Color(0xFF12121A);
  static const bg3 = Color(0xFF1A1A26);
  static const surface = Color(0x0AFFFFFF);
  static const surfaceH = Color(0x14FFFFFF);
  static const border = Color(0x14FFFFFF);
  static const red = Color(0xFFE63946);
  static const redGlow = Color(0x4DE63946);
  static const blue = Color(0xFF4CC9F0);
  static const gold = Color(0xFFF5A623);
  static const green = Color(0xFF2EC27E);
  static const purple = Color(0xFFA855F7);
  static const text = Color(0xFFF0F0F5);
  static const text2 = Color(0xFF9090A8);
  static const text3 = Color(0xFF5A5A70);
}

class AppTheme {
  static TextStyle headingStyle(double size, {Color color = AppColors.text}) =>
      GoogleFonts.bebasNeue(fontSize: size, color: color, letterSpacing: 1.5);

  static TextStyle bodyStyle(double size,
          {FontWeight weight = FontWeight.w400,
          Color color = AppColors.text}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: weight, color: color);

  static ThemeData darkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.red,
        surface: AppColors.bg,
        onSurface: AppColors.text,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).apply(
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg2,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
