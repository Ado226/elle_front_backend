import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Primary Colors (Extracted from mockup)
  static const Color primaryPink = Color(0xFFFF69B4);
  static const Color lightPink = Color(0xFFFFC0CB);
  static const Color softPink = Color(0xFFF8BBD9);
  static const Color softPinkBackground = Color(0xFFF8E8F0);
  static const Color blobPink = Color(0xFFFFE4ED);
  static const Color lightPinkBackground = Color(0xFFF8E8F0);
  static const Color blobBorder = Color(0xFFFFB6C1);
  static const Color notificationRed = Color(0xFFFF3B30);
  static const Color consultationOrange = Color(0xFFFF9500);
  static const Color darkPink = Color(0xFFD63384);

  // Ce mois-ci Section Colors - Simple Circle Design
  static const Color ceMoisCiBackground = Color(0xFFF5F5F5);
  static const Color titleColor = Color(0xFF000000);
  static const Color circleBackground = Color(0xFFFFE4E6);
  static const Color circleBorder = Color(0xFFFF69B4);
  static const Color nextPeriodText = Color(0xFFFF69B4);
  static const Color mainDateText = Color(0xFFFF1493);
  static const Color descriptionText = Color(0xFF333333);

  // Week Calendar Colors
  static const Color weekCalendarBackground = Color(0xFFF8E8F0);
  static const Color dayHeaderBlue = Color(0xFF007AFF);
  static const Color selectedDateBackground = Color(0xFF2C2C2C);
  static const Color selectedDateText = Color(0xFFFFFFFF);
  static const Color regularDateText = Color(0xFF666666);
  static const Color inactiveDateText = Color(0xFFCCCCCC);

  // Header Colors
  static const Color headerBackground = Color(0xFFF8F8F8);
  static const Color greetingText = Color(0xFF2C2C2C);
  static const Color dateText = Color(0xFF666666);
  static const Color iconColor = Color(0xFF2C2C2C);
  static const Color badgeBackground = Color(0xFFFF9500);
  static const Color badgeText = Color(0xFFFFFFFF);

  // Text Colors
  static const Color darkText = Color(0xFF2C2C2C);
  static const Color darkGray = Color(0xFF2C2C2C);
  static const Color mediumGray = Color(0xFF666666);
  static const Color lightGray = Color(0xFF999999);
  static const Color white = Color(0xFFFFFFFF);
  static const Color bubbleText = Color(0xFF333333);

  // Background Colors
  static const Color screenBackground = Color(0xFFF8F8F8);
  static const Color calendarBackground = Color(0xFFFAFAFA);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color selectedDate = Color(0xFF2C2C2C);
  static const Color backgroundPink = Color(0xFFFFF0F5);
  
  // Add missing background color properties
  static const Color backgroundColor = Color(0xFFF8F8F8);
  static const Color cardBackgroundColor = Color(0xFFFFFFFF);

  // Accent Colors
  static const Color accentBlue = Color(0xFF007AFF);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentRed = Color(0xFFFF3B30);

  // Text Styles (Exact mockup specifications)
  static TextStyle get homeTextStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: mediumGray,
  );

  static TextStyle get greetingStyle => GoogleFonts.poppins(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: darkText,
  );

  static TextStyle get dateStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: mediumGray,
  );

  static TextStyle get sectionTitleStyle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkText,
  );

  static TextStyle get bodyTextStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: mediumGray,
  );

  static TextStyle get calendarHeaderStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: darkText,
  );

  static TextStyle get calendarDateStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: lightGray,
  );

  static TextStyle get selectedDateStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: white,
  );

  static TextStyle get blobTextStyle => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: bubbleText,
  );

  static TextStyle get blobLargeTextStyle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: bubbleText,
  );

  static TextStyle get blobCaptionStyle => GoogleFonts.poppins(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: bubbleText,
  );

  static TextStyle get blobTitleStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: bubbleText,
  );

  static TextStyle get blobSubtitleStyle => GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: bubbleText,
  );

  static TextStyle get bubbleNumberStyle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: bubbleText,
  );

  static TextStyle get bubbleMainTextStyle => GoogleFonts.poppins(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: bubbleText,
  );

  // Circle content text styles
  static TextStyle get circleNextPeriodStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: nextPeriodText,
  );

  static TextStyle get circleDateStyle => GoogleFonts.poppins(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: mainDateText,
  );

  static TextStyle get circleDescriptionStyle => GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: descriptionText,
    height: 1.3,
  );

  static TextStyle get logoStyle => GoogleFonts.dancingScript(
    fontSize: 48,
    fontWeight: FontWeight.w300,
    color: white,
  );

  static TextStyle get sloganStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: white,
  );

  // Additional styles for backward compatibility
  static TextStyle get headerStyle => GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: darkText,
  );

  static TextStyle get subHeaderStyle => GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkText,
  );

  static TextStyle get bodyStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: darkText,
  );

  static TextStyle get captionStyle => GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: lightGray,
  );

  // Button Styles (Exact mockup specifications)
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: primaryPink,
    foregroundColor: white,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(25), // Fully rounded
    ),
    elevation: 0,
  );

  static TextStyle get buttonTextStyle => GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: white,
  );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: white,
    foregroundColor: primaryPink,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: primaryPink),
    ),
    elevation: 0,
  );

  // Card Decoration (Exact mockup specifications)
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: cardBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration get calendarDecoration => BoxDecoration(
    color: calendarBackground,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.03),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  );

  // Gradients
  static LinearGradient get splashGradient => const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryPink, lightPink],
  );

  static LinearGradient get pinkBlobGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softPink, lightPink],
  );

  // Theme Data (Updated for exact mockup)
  static ThemeData get themeData => ThemeData(
    primarySwatch: Colors.pink,
    primaryColor: primaryPink,
    scaffoldBackgroundColor: screenBackground,
    fontFamily: GoogleFonts.poppins().fontFamily,
    appBarTheme: AppBarTheme(
      backgroundColor: screenBackground,
      foregroundColor: darkText,
      elevation: 0,
      titleTextStyle: sectionTitleStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: primaryButtonStyle,
    ),
    cardTheme: CardTheme(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 1,
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryPink,
      brightness: Brightness.light,
    ),
  );

  // Static light theme for backward compatibility
  static ThemeData get lightTheme => themeData;
}