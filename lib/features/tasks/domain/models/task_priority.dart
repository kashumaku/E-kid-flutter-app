import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.low:
        return AppColors.priorityLow;
      case TaskPriority.medium:
        return AppColors.priorityMedium;
      case TaskPriority.high:
        return AppColors.priorityHigh;
      case TaskPriority.urgent:
        return AppColors.priorityUrgent;
    }
  }

  IconData get icon {
    switch (this) {
      case TaskPriority.low:
        return Icons.arrow_downward_rounded;
      case TaskPriority.medium:
        return Icons.horizontal_rule_rounded;
      case TaskPriority.high:
        return Icons.arrow_upward_rounded;
      case TaskPriority.urgent:
        return Icons.priority_high_rounded;
    }
  }

  int get weight {
    switch (this) {
      case TaskPriority.low:
        return 1;
      case TaskPriority.medium:
        return 2;
      case TaskPriority.high:
        return 3;
      case TaskPriority.urgent:
        return 4;
    }
  }

  static TaskPriority fromString(String? value) {
    switch (value?.toLowerCase()) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'medium':
        return TaskPriority.medium;
      case 'low':
      default:
        return TaskPriority.low;
    }
  }
}
