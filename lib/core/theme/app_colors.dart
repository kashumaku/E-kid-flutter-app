import 'package:flutter/material.dart';

/// App color palette matching the modern Cyan/Teal task manager design.
class AppColors {
  AppColors._();

  // Primary Brand Color (Coral / Sunset - matching the signup and signin buttons)
  static const Color primary = Color(0xFFFF6B4A); // Vibrant Coral / Sunset
  static const Color primaryLight = Color(0xFFFF8A65);
  static const Color primaryDark = Color(0xFFF05330);
  static const Color secondary = Color(0xFF00B4D8); // Vibrant Cyan
  static const Color secondaryLight = Color(0xFF48CAE4);
  static const Color secondaryDark = Color(0xFF0077B6);
  static const Color accent = Color(0xFF8B5CF6); // Purple

  // Feature Cards from Mockup
  static const Color heroDark = Color(0xFF1E232E); // Dark daily task banner
  static const Color cardCyan = Color(0xFF00B4D8); // Today's Task Cyan card
  static const Color cardCoral = Color(0xFFFF6B4A); // Today's Task Coral card
  static const Color cardPurple = Color(0xFF8B5CF6);

  // Pie Chart Colors
  static const Color chartFinishOnTime = Color(0xFF00B4D8); // 40%
  static const Color chartPastDeadline = Color(0xFFFF6B4A); // 40%
  static const Color chartOngoing = Color(0xFF7000FF); // 20%

  // Functional Status Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color error = Color(0xFFEF4444); // Red
  static const Color info = Color(0xFF00B4D8); // Cyan

  // Priority Colors
  static const Color priorityUrgent = Color(0xFFEF4444);
  static const Color priorityHigh = Color(0xFFFF6B4A);
  static const Color priorityMedium = Color(0xFFFBBF24);
  static const Color priorityLow = Color(0xFF10B981);

  // Light Theme Palette (Default from Mockup)
  static const Color lightBackground = Color(0xFFF6F9FD);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF2F8);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE5EBF2);
  static const Color lightTextPrimary = Color(0xFF1E232E);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextMuted = Color(0xFF9CA3AF);

  // Dark Theme Palette
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // Category Accent Colors & Gradients
  static const List<Color> categoryGradientsWork = [Color(0xFF00B4D8), Color(0xFF0077B6)];
  static const List<Color> categoryGradientsPersonal = [Color(0xFFFF6B4A), Color(0xFFEA580C)];
  static const List<Color> categoryGradientsHealth = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> categoryGradientsStudy = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const List<Color> categoryGradientsDesign = [Color(0xFF8B5CF6), Color(0xFF7C3AED)];
  static const List<Color> categoryGradientsFinance = [Color(0xFF06B6D4), Color(0xFF0284C7)];

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B4A), Color(0xFFF05330)],
  );

  static const LinearGradient coralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B4A), Color(0xFFFF5722)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E232E), Color(0xFF2B3242)],
  );
}
