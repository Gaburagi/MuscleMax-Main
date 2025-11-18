import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors (from Figma)
  static const Color primaryRed = Color(0xFFC22F42);
  static const Color primaryRedDark = Color(0xFF8A2230);
  static const Color darkBackground = Color(0xFF0F0F0F);
  static const Color darkGray = Color(0xFF333333);
  
  // Accent Colors
  static const Color accentOrange = Color(0xFFF6A010);
  static const Color accentOrangeDeep = Color(0xFFD46403);
  static const Color accentRed = Color(0xFFC22F42);
  static const Color accentRedDeep = Color(0xFF8A2230);
  
  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF999999);
  static const Color textDarkGray = Color(0xFF686868);
  
  // Background Colors (from Figma)
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color backgroundDarker = Color(0xFF0F0F0F);
  static const Color backgroundCard = Color(0xFF333333);
  
  // Input & Border Colors
  static const Color inputBorder = Color(0xFF333333);
  static const Color inputFill = Color(0xFF1A1A1A);
  
  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [backgroundDark, Color(0xFF1A1A1A)],
  );
  
  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryRed, primaryRedDark],
  );
  
  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [accentOrange, accentOrangeDeep],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkGray, Color(0xFF1A1A1A)],
  );
}
