import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AfricanColors {
  // Primary cycle colors as specified
  static const Color menstruationColor = Color(0xFFA0522D); // Sienna
  static const Color fertileColor = Color(0xFF228B22); // Forest Green
  static const Color ovulationColor = Color(0xFFDAA520); // Golden
  static const Color safeColor = Color(0xFF87CEEB); // Sky Blue
  static const Color backgroundColor = Color(0xFFFFF8E7); // Light Cream
  static const Color primaryColor = Color(0xFF8B4513); // Earth Brown

  // Extended African-inspired palette
  static const Color baobabBrown = Color(0xFF8B4513); // Primary
  static const Color safariSand = Color(0xFFF5DEB3); // Wheat
  static const Color sunsetOrange = Color(0xFFFF6347); // Tomato
  static const Color acaciaGreen = Color(0xFF9ACD32); // Yellow Green
  static const Color nileBlueDark = Color(0xFF4682B4); // Steel Blue
  static const Color desertRose = Color(0xFFBC8F8F); // Rosy Brown
  static const Color ivoryWhite = Color(0xFFFFFFF0); // Ivory
  static const Color charcoalGray = Color(0xFF36454F); // Dark Gray
  
  // Accent colors
  static const Color goldAccent = Color(0xFFFFD700); // Gold
  static const Color copperAccent = Color(0xFFB87333); // Copper
  static const Color terracottaAccent = Color(0xFFE2725B); // Terracotta
  
  // Text colors
  static const Color textPrimary = Color(0xFF2D2D2D); // Dark Gray
  static const Color textSecondary = Color(0xFF666666); // Medium Gray
  static const Color textLight = Color(0xFFFFFFFF); // White
  static const Color textOnDark = Color(0xFFFFF8E7); // Light Cream
  
  // Status colors
  static const Color successGreen = Color(0xFF228B22); // Forest Green
  static const Color warningOrange = Color(0xFFFF8C00); // Dark Orange
  static const Color errorRed = Color(0xFFDC143C); // Crimson
  static const Color infoBlue = Color(0xFF4169E1); // Royal Blue
  
  // Shadow and overlay colors
  static const Color shadowColor = Color(0x1A000000); // Light shadow
  static const Color overlayColor = Color(0x80000000); // Semi-transparent black
  static const Color dividerColor = Color(0xFFE0E0E0); // Light gray
  
  // Get cycle color by type
  static Color getCycleColor(String type) {
    switch (type.toLowerCase()) {
      case 'menstruation':
        return menstruationColor;
      case 'fertile':
        return fertileColor;
      case 'ovulation':
        return ovulationColor;
      case 'safe':
        return safeColor;
      default:
        return backgroundColor;
    }
  }
}

class AfricanTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AfricanColors.primaryColor,
        secondary: AfricanColors.goldAccent,
        surface: AfricanColors.ivoryWhite,
        background: AfricanColors.backgroundColor,
        error: AfricanColors.errorRed,
        onPrimary: AfricanColors.textLight,
        onSecondary: AfricanColors.textPrimary,
        onSurface: AfricanColors.textPrimary,
        onBackground: AfricanColors.textPrimary,
        onError: AfricanColors.textLight,
      ),
      
      // Typography using Google Fonts
      textTheme: GoogleFonts.notoSansTextTheme().copyWith(
        displayLarge: GoogleFonts.notoSans(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AfricanColors.textPrimary,
        ),
        displayMedium: GoogleFonts.notoSans(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: AfricanColors.textPrimary,
        ),
        headlineLarge: GoogleFonts.notoSans(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AfricanColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AfricanColors.textPrimary,
        ),
        titleLarge: GoogleFonts.notoSans(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AfricanColors.textPrimary,
        ),
        titleMedium: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AfricanColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.notoSans(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: AfricanColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.notoSans(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: AfricanColors.textPrimary,
        ),
        bodySmall: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: AfricanColors.textSecondary,
        ),
      ),
      
      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AfricanColors.primaryColor,
        foregroundColor: AfricanColors.textLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AfricanColors.textLight,
        ),
      ),
      
      // Card Theme
      cardTheme: const CardTheme(
        color: AfricanColors.ivoryWhite,
        elevation: 4,
        shadowColor: AfricanColors.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AfricanColors.primaryColor,
          foregroundColor: AfricanColors.textLight,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AfricanColors.primaryColor,
          side: const BorderSide(color: AfricanColors.primaryColor, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: GoogleFonts.notoSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AfricanColors.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: GoogleFonts.notoSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AfricanColors.ivoryWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AfricanColors.dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AfricanColors.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AfricanColors.primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AfricanColors.errorRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: GoogleFonts.notoSans(
          color: AfricanColors.textSecondary,
          fontSize: 14,
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AfricanColors.goldAccent,
        foregroundColor: AfricanColors.textPrimary,
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AfricanColors.ivoryWhite,
        selectedItemColor: AfricanColors.primaryColor,
        unselectedItemColor: AfricanColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AfricanColors.safariSand,
        selectedColor: AfricanColors.primaryColor,
        labelStyle: GoogleFonts.notoSans(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      
      // Dialog Theme
      dialogTheme: DialogTheme(
        backgroundColor: AfricanColors.ivoryWhite,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        titleTextStyle: GoogleFonts.notoSans(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AfricanColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.notoSans(
          fontSize: 14,
          color: AfricanColors.textPrimary,
        ),
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AfricanColors.dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: AfricanColors.textPrimary,
        size: 24,
      ),
      
      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: AfricanColors.textLight,
        size: 24,
      ),
    );
  }
  
  // Custom decorations for African-inspired design
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: AfricanColors.ivoryWhite,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AfricanColors.shadowColor,
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration get primaryGradientDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AfricanColors.primaryColor,
        AfricanColors.copperAccent,
      ],
    ),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
  
  static BoxDecoration get sunsetGradientDecoration => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AfricanColors.sunsetOrange,
        AfricanColors.goldAccent,
      ],
    ),
    borderRadius: BorderRadius.all(Radius.circular(16)),
  );
}