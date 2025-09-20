import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBlue = Color(0xFF1E3A8A);      // Dark blue
  static const Color secondaryBlue = Color(0xFF3B4FB8);    // Medium blue
  static const Color accentBlue = Color(0xFF8B9DC3);       // Light blue
  static const Color lightBlue = Color(0xFFB8C5E0);        // Very light blue
  
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryBlue, secondaryBlue, accentBlue, lightBlue],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondaryBlue, accentBlue],
  );
}

