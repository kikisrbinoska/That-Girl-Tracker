import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color rosePink = Color(0xFFF4A7B9);
  static const Color lavender = Color(0xFFC4A8E0);
  static const Color deepPurple = Color(0xFF7C3AED);

  // Backgrounds
  static const Color lightBackground = Color(0xFFFFF5F7);
  static const Color darkBackground = Color(0xFF1A0A1E);

  // Text
  static const Color textDark = Color(0xFF1F2937);
  static const Color textLight = Colors.white;
  static const Color textMuted = Color(0xFF9CA3AF);

  // Glass card
  static const Color glassWhite = Color(0x26FFFFFF); // 15% white
  static const Color glassBorder = Color(0x4DFFFFFF); // 30% white
  static const Color glassDark = Color(0x1AFFFFFF); // 10% white for dark mode
  static const Color glassBorderDark = Color(0x33FFFFFF); // 20% white

  // Shadows
  static const Color pinkShadow = Color(0x4DF4A7B9); // rgba(244,167,185,0.3)

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [rosePink, lavender, deepPurple],
  );

  static const LinearGradient softGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [rosePink, lavender],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightBackground, Color(0xFFFCE4EC)],
  );

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBackground, Color(0xFF2D1235)],
  );
}
