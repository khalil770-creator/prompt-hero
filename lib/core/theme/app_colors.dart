import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary brand colors
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF6D64F0);
  static const Color primaryDark = Color(0xFF3730A3);

  // Secondary / accent
  static const Color secondary = Color(0xFFF59E0B);
  static const Color secondaryLight = Color(0xFFFBBF24);
  static const Color secondaryDark = Color(0xFFD97706);

  // Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color(0xFF0F172A);

  // Surfaces
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E293B);

  // Text
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Divider
  static const Color divider = Color(0xFFE2E8F0);
  static const Color dividerDark = Color(0xFF334155);

  // Card shadows
  static const Color shadow = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);

  // Rating star color
  static const Color starActive = Color(0xFFF59E0B);
  static const Color starInactive = Color(0xFFE2E8F0);

  // Category gradient colors
  static const List<List<Color>> categoryGradients = [
    [Color(0xFF4F46E5), Color(0xFF7C3AED)], // Indigo → Purple
    [Color(0xFF0EA5E9), Color(0xFF6366F1)], // Sky → Indigo
    [Color(0xFF10B981), Color(0xFF0EA5E9)], // Emerald → Sky
    [Color(0xFFF59E0B), Color(0xFFEF4444)], // Amber → Red
    [Color(0xFFEC4899), Color(0xFF8B5CF6)], // Pink → Violet
    [Color(0xFF14B8A6), Color(0xFF10B981)], // Teal → Emerald
    [Color(0xFFF97316), Color(0xFFF59E0B)], // Orange → Amber
    [Color(0xFF6366F1), Color(0xFFEC4899)], // Indigo → Pink
  ];

  // Header gradient
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
  );

  // Hero gradient
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4F46E5), Color(0xFF6D28D9), Color(0xFF7C3AED)],
  );
}
