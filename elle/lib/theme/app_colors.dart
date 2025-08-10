import 'package:flutter/material.dart';

class AppColors {
  // Afro-centric cycle colors
  static const Color periodColor = Color(0xFF8B4513); // Mother Earth Brown
  static const Color fertileColor = Color(0xFF228B22); // Forest Green
  static const Color ovulationColor = Color(0xFFDAA520); // Gold
  static const Color normalColor = Color(0xFFF5F5DC); // Neutral Beige
  
  // UI colors
  static const Color primaryColor = Color(0xFF8B4513); // Mother Earth Brown
  static const Color secondaryColor = Color(0xFFDAA520); // Gold
  static const Color backgroundColor = Color(0xFFFFFFF0); // Ivory
  static const Color surfaceColor = Color(0xFFFFFFFF); // White
  
  // Text colors
  static const Color textPrimary = Color(0xFF2F2F2F); // Dark Gray
  static const Color textSecondary = Color(0xFF666666); // Medium Gray
  static const Color textLight = Color(0xFFFFFFFF); // White
  
  // Accent colors
  static const Color accentOrange = Color(0xFFFF6B35); // African Sunset
  static const Color accentPurple = Color(0xFF9B3192); // Royal Purple
  static const Color accentTeal = Color(0xFF20B2AA); // Light Sea Green
  
  // Status colors
  static const Color successColor = Color(0xFF228B22); // Forest Green
  static const Color warningColor = Color(0xFFDAA520); // Gold
  static const Color errorColor = Color(0xFFDC143C); // Crimson
  
  // Shadow and borders
  static const Color shadowColor = Color(0x1A000000); // Light shadow
  static const Color borderColor = Color(0xFFE0E0E0); // Light border
  
  // Get cycle color by type
  static Color getCycleColor(String type) {
    switch (type.toLowerCase()) {
      case 'period':
        return periodColor;
      case 'fertile':
        return fertileColor;
      case 'ovulation':
        return ovulationColor;
      default:
        return normalColor;
    }
  }
  
  // Get cycle color with opacity
  static Color getCycleColorWithOpacity(String type, double opacity) {
    return getCycleColor(type).withOpacity(opacity);
  }
}