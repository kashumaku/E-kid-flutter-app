import 'package:flutter/material.dart';

enum TaskFilter {
  all,
  today,
  upcoming,
  highPriority,
  completed;

  String get displayName {
    switch (this) {
      case TaskFilter.all:
        return 'All Tasks';
      case TaskFilter.today:
        return 'Today';
      case TaskFilter.upcoming:
        return 'Upcoming';
      case TaskFilter.highPriority:
        return 'Priority';
      case TaskFilter.completed:
        return 'Completed';
    }
  }

  IconData get icon {
    switch (this) {
      case TaskFilter.all:
        return Icons.dashboard_outlined;
      case TaskFilter.today:
        return Icons.today_rounded;
      case TaskFilter.upcoming:
        return Icons.event_note_rounded;
      case TaskFilter.highPriority:
        return Icons.flag_rounded;
      case TaskFilter.completed:
        return Icons.task_alt_rounded;
    }
  }
}

enum TaskSortOption {
  dueDateAsc,
  priorityDesc,
  titleAsc,
  createdDesc;

  String get displayName {
    switch (this) {
      case TaskSortOption.dueDateAsc:
        return 'Due Date (Earliest)';
      case TaskSortOption.priorityDesc:
        return 'Priority (Highest)';
      case TaskSortOption.titleAsc:
        return 'Alphabetical';
      case TaskSortOption.createdDesc:
        return 'Recently Added';
    }
  }
}
