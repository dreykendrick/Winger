import 'package:flutter/material.dart';

/// Design tokens for Winger application color system (Material 3).
abstract class AppColors {
  // Primary Palette (Emerald Trust & Escrow)
  static const Color primaryEmerald = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF10B981);
  static const Color primaryDark = Color(0xFF047857);
  static const Color primaryContainer = Color(0xFFD1FAE5);

  // Secondary Palette (Indigo Platform Kernel)
  static const Color secondaryIndigo = Color(0xFF4F46E5);
  static const Color secondaryLight = Color(0xFF6366F1);
  static const Color secondaryDark = Color(0xFF3730A3);

  // Accent & Status Palette (Amber Pending & Escrow Hold)
  static const Color accentAmber = Color(0xFFD97706);
  static const Color accentLight = Color(0xFFF59E0B);
  static const Color dangerCoral = Color(0xFFDC2626);
  static const Color successGreen = Color(0xFF16A34A);

  // Neutral Palette (Dark Slate)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);

  // Neutral Palette (Light Slate)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFE2E8F0);

  // Glassmorphic Overlay
  static Color glassWhite = Colors.white.withValues(alpha: 0.08);
  static Color glassBorder = Colors.white.withValues(alpha: 0.15);
}
