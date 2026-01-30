import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class Helpers {
  // Show SnackBar
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: AppConstants.snackBarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Format Date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format Time
  static String formatTime(DateTime dateTime) {
    return DateFormat('hh:mm a').format(dateTime);
  }

  // Format DateTime
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  // Get Sport Icon
  static IconData getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case AppConstants.sportFootball:
        return Icons.sports_soccer;
      case AppConstants.sportCricket:
        return Icons.sports_cricket;
      case AppConstants.sportBasketball:
        return Icons.sports_basketball;
      case AppConstants.sportVolleyball:
        return Icons.sports_volleyball;
      default:
        return Icons.sports;
    }
  }

  // Get Sport Color
  static Color getSportColor(String sport) {
    switch (sport.toLowerCase()) {
      case AppConstants.sportFootball:
        return AppColors.footballColor;
      case AppConstants.sportCricket:
        return AppColors.cricketColor;
      case AppConstants.sportBasketball:
        return AppColors.basketballColor;
      case AppConstants.sportVolleyball:
        return AppColors.volleyballColor;
      default:
        return AppColors.primary;
    }
  }

  // Get Sport Gradient
  static List<Color> getSportGradient(String sport) {
    switch (sport.toLowerCase()) {
      case AppConstants.sportFootball:
        return AppColors.footballGradient;
      case AppConstants.sportCricket:
        return AppColors.cricketGradient;
      case AppConstants.sportBasketball:
        return AppColors.basketballGradient;
      case AppConstants.sportVolleyball:
        return AppColors.volleyballGradient;
      default:
        return AppColors.primaryGradient;
    }
  }

  // Get Status Color
  static Color getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusScheduled:
        return AppColors.statusScheduled;
      case AppConstants.statusLive:
        return AppColors.statusLive;
      case AppConstants.statusCompleted:
        return AppColors.statusCompleted;
      case AppConstants.statusCancelled:
        return AppColors.statusCancelled;
      default:
        return AppColors.textSecondary;
    }
  }

  // Get Position Color
  static Color getPositionColor(String? position) {
    if (position == null) return AppColors.textSecondary;
    
    if (position.toLowerCase().contains('forward') || 
        position.toLowerCase().contains('striker') ||
        position.toLowerCase().contains('batsman') ||
        position.toLowerCase().contains('batter')) {
      return AppColors.positionForward;
    } else if (position.toLowerCase().contains('mid') ||
               position.toLowerCase().contains('all-rounder')) {
      return AppColors.positionMidfielder;
    } else if (position.toLowerCase().contains('defense') ||
               position.toLowerCase().contains('bowler')) {
      return AppColors.positionDefender;
    } else if (position.toLowerCase().contains('goal') ||
               position.toLowerCase().contains('keeper') ||
               position.toLowerCase().contains('wicket')) {
      return AppColors.positionGoalkeeper;
    }
    
    return AppColors.textSecondary;
  }

  // Validate Email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate Phone
  static bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone);
  }

  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }
    
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}'.toUpperCase();
  }

  // Generate unique color from string (team name, etc)
  static Color generateUniqueColor(String input) {
    if (input.isEmpty) return AppColors.primary;
    
    // Better hash function using a more distributed approach
    int hash = 5381;
    for (int i = 0; i < input.length; i++) {
      hash = ((hash << 5) + hash) + input.codeUnitAt(i);
    }
    
    final colors = [
      const Color(0xFF6C5CE7), // Vibrant Purple
      const Color(0xFF0984E3), // Bright Blue
      const Color(0xFF00B894), // Fresh Green
      const Color(0xFFE17055), // Warm Orange
      const Color(0xFF6C3483), // Deep Purple
      const Color(0xFF1E8449), // Forest Green
      const Color(0xFFC0392B), // Bold Red
      const Color(0xFF2980B9), // Deep Blue
      const Color(0xFFF39C12), // Golden Yellow
      const Color(0xFFE74C3C), // Coral Red
      const Color(0xFF8E44AD), // Royal Violet
      const Color(0xFF16A085), // Teal
      const Color(0xFFC23B22), // Dark Coral
      const Color(0xFF27AE60), // Green
      const Color(0xFF2E86AB), // Steel Blue
    ];
    
    // Use absolute value and modulo for safe indexing
    final index = (hash.abs() % colors.length);
    return colors[index];
  }

  // Generate gradient from team name
  static List<Color> generateUniqueGradient(String input) {
    final baseColor = generateUniqueColor(input);
    return [
      baseColor,
      baseColor.withOpacity(0.7),
    ];
  }
}
