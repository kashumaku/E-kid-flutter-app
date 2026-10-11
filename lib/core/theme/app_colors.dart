import 'package:flutter/material.dart';

/// App color palette featuring curated, harmonious hues for both Dark & Light themes.
class AppColors {
  AppColors._();

  // Primary & Accent Brand Colors
  static const Color primary = Color(0xFF6366F1); // Indigo / Electric Purple
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color accent = Color(0xFFF43F5E); // Rose / Pink accent

  // Functional Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF3B82F6); // Blue

  // Priority Colors
  static const Color priorityUrgent = Color(0xFFEF4444);
  static const Color priorityHigh = Color(0xFFF97316);
  static const Color priorityMedium = Color(0xFFFBBF24);
  static const Color priorityLow = Color(0xFF10B981);

  // Dark Theme Palette (Obsidian & Deep Space)
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkSurfaceVariant = Color(0xFF1E293B);
  static const Color darkCard = Color(0xFF162036);
  static const Color darkBorder = Color(0xFF283548);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Light Theme Palette (Clean & Airy)
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // Category Accent Colors & Gradients
  static const List<Color> categoryGradientsWork = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> categoryGradientsPersonal = [Color(0xFFEC4899), Color(0xFFF43F5E)];
  static const List<Color> categoryGradientsHealth = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> categoryGradientsStudy = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const List<Color> categoryGradientsDesign = [Color(0xFF8B5CF6), Color(0xFFC084FC)];
  static const List<Color> categoryGradientsFinance = [Color(0xFF06B6D4), Color(0xFF0284C7)];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x266366F1), Color(0x108B5CF6)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
  );
}
