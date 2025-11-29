import 'package:flutter/material.dart';

class AppColors {
  // Main colors
  static const Color primaryRed = Color(0xFFE74C3C);
  static const Color darkBackground = Color(0xFF1A1D2E);
  static const Color cardBackground = Color(0xFF22253A);
  static const Color darkGrey = Color(0xFF2D3142);

  // Timer colors
  static const Color focusColor = Color(0xFFE74C3C);
  static const Color shortBreakColor = Color(0xFF3498DB);
  static const Color longBreakColor = Color(0xFF9B59B6);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B3B8);
  static const Color textTertiary = Color(0xFF6B6E76);

  // Accent colors
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);

  // Progress colors
  static const Color progressActive = Color(0xFFE74C3C);
  static const Color progressInactive = Color(0xFF3D4052);

  // Gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2D3142),
      Color(0xFF22253A),
    ],
  );
}
