import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

/// App theme as defined in Prix Book Master Spec v1.1 Section 4.2 & 4.3
class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryNavy,
      brightness: Brightness.light,
      primary: AppColors.primaryNavy,
      onPrimary: Colors.white,
      secondary: AppColors.emeraldGreen,
      onSecondary: Colors.white,
      error: AppColors.dangerRed,
      surface: AppColors.white,
      onSurface: AppColors.textDark,
    );

    final textTheme = _buildTextTheme();

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 22,
        ),
      ),

      // Cards
      cardTheme: CardTheme(
        color: AppColors.white,
        elevation: AppSizes.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.cardBorder, width: 0.5),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.xs,
        ),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryNavy,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.lg,
          vertical: AppSizes.md,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(
            color: AppColors.primaryNavy,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          borderSide: const BorderSide(color: AppColors.dangerRed),
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textMuted,
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textMid,
        ),
      ),

      // Elevated button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryNavy,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm),
          ),
          textStyle: textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryNavy,
        ),
      ),

      // Bottom nav bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryNavy,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.altRow,
        labelStyle: textTheme.labelSmall?.copyWith(
          color: AppColors.textDark,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.sm,
          vertical: AppSizes.xs,
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusSm),
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: AppColors.cardBorder,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: _tajawal(fontSize: 22, fontWeight: FontWeight.w700),
      displayMedium: _tajawal(fontSize: 18, fontWeight: FontWeight.w600),
      displaySmall: _tajawal(fontSize: 16, fontWeight: FontWeight.w600),
      headlineLarge: _tajawal(fontSize: 24, fontWeight: FontWeight.w700),
      headlineMedium: _tajawal(fontSize: 18, fontWeight: FontWeight.w600),
      headlineSmall: _tajawal(fontSize: 16, fontWeight: FontWeight.w600),
      titleLarge: _tajawal(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: _tajawal(fontSize: 16, fontWeight: FontWeight.w600),
      titleSmall: _tajawal(fontSize: 14, fontWeight: FontWeight.w500),
      bodyLarge: _tajawal(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: _tajawal(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall: _tajawal(fontSize: 12, fontWeight: FontWeight.w400),
      labelLarge: _tajawal(fontSize: 14, fontWeight: FontWeight.w500),
      labelMedium: _tajawal(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: _tajawal(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }

  static TextStyle _tajawal({
    required double fontSize,
    required FontWeight fontWeight,
    Color color = AppColors.textDark,
  }) {
    return GoogleFonts.tajawal(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}
