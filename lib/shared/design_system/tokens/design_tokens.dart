import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Master Design Tokens for Winger 2.0 Material 3 Design System.
abstract class WingerTokens {
  // Brand Color Tokens (Approved Palette: #FF8A00, #10B981, #3882F6, #F59E0B, #EF4444, #1F2937, #111827)
  static const Color primaryOrange = Color(0xFFFF8A00);
  static const Color primaryEmerald = Color(0xFF10B981);
  static const Color secondaryBlue = Color(0xFF3882F6);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color dangerCoral = Color(0xFFEF4444);

  // Legacy mappings for backwards compatibility
  static const Color primaryLight = Color(0xFFFF9D26);
  static const Color primaryDark = Color(0xFFE67C00);
  static const Color secondaryIndigo = Color(0xFF3882F6);
  static const Color secondaryLight = Color(0xFF60A5FA);
  static const Color secondaryDark = Color(0xFF1D4ED8);
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color successGreen = Color(0xFF10B981);

  // Surface & Background Tokens
  static const Color darkBackground = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkSurfaceVariant = Color(0xFF374151);

  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE2E8F0);

  // Spacing Tokens
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;

  // Border Radius Tokens
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusPill = 999.0;

  // Elevation Tokens
  static const double elevationLow = 1.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  // Typography Scales (Poppins)
  static TextStyle displayLarge(Color color) => GoogleFonts.poppins(
      fontSize: 32, fontWeight: FontWeight.bold, color: color);
  static TextStyle displayMedium(Color color) => GoogleFonts.poppins(
      fontSize: 28, fontWeight: FontWeight.bold, color: color);
  static TextStyle headlineLarge(Color color) => GoogleFonts.poppins(
      fontSize: 24, fontWeight: FontWeight.w700, color: color);
  static TextStyle headlineMedium(Color color) => GoogleFonts.poppins(
      fontSize: 20, fontWeight: FontWeight.w600, color: color);
  static TextStyle titleLarge(Color color) => GoogleFonts.poppins(
      fontSize: 18, fontWeight: FontWeight.w600, color: color);
  static TextStyle titleMedium(Color color) => GoogleFonts.poppins(
      fontSize: 16, fontWeight: FontWeight.w600, color: color);
  static TextStyle bodyLarge(Color color) => GoogleFonts.poppins(
      fontSize: 16, fontWeight: FontWeight.normal, color: color);
  static TextStyle bodyMedium(Color color) => GoogleFonts.poppins(
      fontSize: 14, fontWeight: FontWeight.normal, color: color);
  static TextStyle bodySmall(Color color) => GoogleFonts.poppins(
      fontSize: 12, fontWeight: FontWeight.normal, color: color);
  static TextStyle labelSmall(Color color) => GoogleFonts.poppins(
      fontSize: 11, fontWeight: FontWeight.w500, color: color);
}
