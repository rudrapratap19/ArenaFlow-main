import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Modern Gradient Blue
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryDark = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryVeryLight = Color(0xFFE0E7FF);

  // Accent Colors - Vibrant Cyan
  static const Color accent = Color(0xFF06B6D4);
  static const Color accentDark = Color(0xFF0891B2);
  static const Color accentLight = Color(0xFF22D3EE);

  // Sports Colors - Modern Palette
  static const Color footballColor = Color(0xFF3B82F6); // Blue
  static const Color cricketColor = Color(0xFFEC4899); // Pink
  static const Color basketballColor = Color(0xFFF59E0B); // Amber
  static const Color volleyballColor = Color(0xFFEF4444); // Red

  // Status Colors - Clear States
  static const Color statusScheduled = Color(0xFFF59E0B); // Amber
  static const Color statusLive = Color(0xFF10B981); // Emerald
  static const Color statusCompleted = Color(0xFF8B5CF6); // Violet
  static const Color statusCancelled = Color(0xFFEF4444); // Red

  // Position Colors - Professional
  static const Color positionForward = Color(0xFFEC4899); // Pink
  static const Color positionMidfielder = Color(0xFF8B5CF6); // Violet
  static const Color positionDefender = Color(0xFF3B82F6); // Blue
  static const Color positionGoalkeeper = Color(0xFFF59E0B); // Amber

  // Background Colors - Modern Grays
  static const Color background = Color(0xFFF8FAFC); // Almost white
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color surfaceLight = Color(0xFFF1F5F9);

  // Text Colors - Accessible
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textHint = Color(0xFFCBD5E1);
  static const Color textWhite = Colors.white;

  // UI Colors - Semantic
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color error = Color(0xFFEF4444); // Red
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color info = Color(0xFF06B6D4); // Cyan

  // Gradient Colors
  static List<Color> primaryGradient = [
    const Color(0xFF2196F3),
    const Color(0xFF1976D2),
  ];

  static List<Color> footballGradient = [
    const Color(0xFF42A5F5),
    const Color(0xFF1E88E5),
  ];

  static List<Color> cricketGradient = [
    const Color(0xFFFF7043),
    const Color(0xFFF4511E),
  ];

  static List<Color> basketballGradient = [
    const Color(0xFFFF9800),
    const Color(0xFFF57C00),
  ];

  static List<Color> volleyballGradient = [
    const Color(0xFFEF5350),
    const Color(0xFFE53935),
  ];

  // Overlay Colors
  static const Color overlay = Color(0x4D000000);
  static const Color overlayLight = Color(0x1A000000);
  static const Color overlayDark = Color(0x80000000);

  // Border Colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFFBDBDBD);

  // Shadow Colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Scheduled Color
  static const Color scheduledOrange = Color(0xFFFF9800); 

  // Live Color
  static const Color liveGreen = Color(0xFF43A047);

  
  static const Color completedGrey = Color(0xFF9E9E9E); 
}