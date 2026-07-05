import 'package:flutter/material.dart';

/// Design system colors as defined in Prix Book Master Spec v1.1 Section 4.2
abstract class AppColors {
  // Primary
  static const Color primaryNavy = Color(0xFF1A3C5E);
  static const Color emeraldGreen = Color(0xFF2ECC71);
  static const Color amberOrange = Color(0xFFE67E22);
  static const Color dangerRed = Color(0xFFE74C3C);

  // Text
  static const Color textDark = Color(0xFF1C1C1E);
  static const Color textMid = Color(0xFF4A4A4A);
  static const Color textMuted = Color(0xFF8E8E93);

  // Backgrounds
  static const Color background = Color(0xFFF2F4F8);
  static const Color white = Color(0xFFFFFFFF);
  static const Color altRow = Color(0xFFEBF5FF);
  static const Color sessionActive = Color(0xFFFFF3E0);

  // Best price state
  static const Color bestPriceBackground = Color(0xFFEAFAF1);
  static const Color bestPriceBorder = emeraldGreen;

  // Card border
  static const Color cardBorder = Color(0xFFE0E0E0);

  // Price age indicators
  static const Color priceFresh = emeraldGreen;     // < 7 days
  static const Color priceAging = amberOrange;      // 7-30 days
  static const Color priceStale = dangerRed;        // > 30 days
}
