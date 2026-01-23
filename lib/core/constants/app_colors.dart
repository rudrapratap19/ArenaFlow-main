import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryBlue = Color(0xFF1565C0);

  // Accent Colors
  static const Color accent = Color(0xFF4CAF50);
  static const Color accentDark = Color(0xFF388E3C);
  static const Color accentLight = Color(0xFF66BB6A);

  // Sports Colors
  static const Color footballColor = Color(0xFF42A5F5);
  static const Color cricketColor = Color(0xFFFF7043);
  static const Color basketballColor = Color(0xFFFF9800);
  static const Color volleyballColor = Color(0xFFEF5350);

  // Status Colors
  static const Color statusScheduled = Color(0xFFFF9800);
  static const Color statusLive = Color(0xFF4CAF50);
  static const Color statusCompleted = Color(0xFF9E9E9E);
  static const Color statusCancelled = Color(0xFFF44336);

  // Position Colors
  static const Color positionForward = Color(0xFFE91E63);
  static const Color positionMidfielder = Color(0xFF9C27B0);
  static const Color positionDefender = Color(0xFF2196F3);
  static const Color positionGoalkeeper = Color(0xFFFF9800);

  // Background Colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Colors.white;
  static const Color cardBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Colors.white;

  // UI Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

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
  static const Color scheduledOrange = Color(0xFFFF9800); // Orange shade for scheduled/registration

  // Live Color
  static const Color liveGreen = Color(0xFF43A047); // Example green, adjust as needed

  // Completed Color
  static const Color completedGrey = Color(0xFF9E9E9E); // or any grey shade you prefer
}
