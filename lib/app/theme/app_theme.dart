import 'package:flutter/material.dart';
import '../../shared/design_system/tokens/design_tokens.dart';

/// Centralized Winger 2.0 Material 3 Theme Configuration.
abstract class AppTheme {
  static ThemeData get darkTheme {
    final colorScheme = const ColorScheme.dark(
      primary: WingerTokens.primaryOrange,
      secondary: WingerTokens.secondaryBlue,
      tertiary: WingerTokens.accentAmber,
      error: WingerTokens.dangerCoral,
      surface: WingerTokens.darkSurface,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: WingerTokens.darkBackground,
      textTheme: TextTheme(
        displayLarge: WingerTokens.displayLarge(Colors.white),
        displayMedium: WingerTokens.displayMedium(Colors.white),
        headlineLarge: WingerTokens.headlineLarge(Colors.white),
        headlineMedium: WingerTokens.headlineMedium(Colors.white),
        titleLarge: WingerTokens.titleLarge(Colors.white),
        titleMedium: WingerTokens.titleMedium(Colors.white),
        bodyLarge: WingerTokens.bodyLarge(Colors.white),
        bodyMedium: WingerTokens.bodyMedium(Colors.white),
        labelLarge: WingerTokens.bodyMedium(Colors.white),
        labelSmall: WingerTokens.labelSmall(Colors.white),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: WingerTokens.darkBackground,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: WingerTokens.darkSurface,
        elevation: WingerTokens.elevationLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(WingerTokens.radiusMedium),
        ),
      ),
    );
  }

  static ThemeData get lightTheme => darkTheme;
}
