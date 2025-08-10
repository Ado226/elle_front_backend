import 'package:flutter/material.dart';

class AppTheme {
  // African-inspired color palette
  static const Color primaryBrown = Color(0xFF8B4513);
  static const Color backgroundCream = Color(0xFFFFF8E7);
  static const Color menstruationBrown = Color(0xFFA0522D);
  static const Color fertileGreen = Color(0xFF228B22);
  static const Color ovulationGold = Color(0xFFDAA520);
  static const Color safeDaysBlue = Color(0xFF87CEEB);
  static const Color accentTerracotta = Color(0xFFCD853F);
  static const Color warmBeige = Color(0xFFF5E6D3);
  static const Color earthyOrange = Color(0xFFCC8400);

  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: createMaterialColor(primaryBrown),
      primaryColor: primaryBrown,
      scaffoldBackgroundColor: backgroundCream,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBrown,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBrown,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        color: warmBeige,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: primaryBrown,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: primaryBrown,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: primaryBrown,
        ),
        bodyMedium: TextStyle(
          color: primaryBrown,
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: backgroundCream,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: warmBeige,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBrown, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBrown, width: 2),
        ),
      ),
    );
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  // Day type colors for calendar
  static Color getDayColor(String dayType) {
    switch (dayType) {
      case 'menstruation':
        return menstruationBrown;
      case 'fertile':
        return fertileGreen;
      case 'ovulation':
        return ovulationGold;
      case 'safe':
        return safeDaysBlue;
      default:
        return Colors.transparent;
    }
  }

  // French messages for different phases
  static String getPhaseMessage(String phase) {
    switch (phase) {
      case 'menstruation':
        return 'Période de règles en cours';
      case 'fertile':
        return 'Aujourd\'hui est un jour fertile 🌿';
      case 'ovulation':
        return 'Jour d\'ovulation 🌟';
      case 'safe':
        return 'Jour sûr';
      default:
        return '';
    }
  }

  // Gradients for African-inspired styling
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBrown, accentTerracotta],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [backgroundCream, warmBeige],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}