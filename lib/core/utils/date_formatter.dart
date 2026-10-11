import 'package:intl/intl.dart';

/// Helper methods for human-friendly date and time formatting.
class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  static final DateFormat _shortDateFormat = DateFormat('MMM d');
  static final DateFormat _timeFormat = DateFormat('h:mm a');
  static final DateFormat _dayOfWeekFormat = DateFormat('EEEE');

  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  static String formatShortDate(DateTime date) {
    return _shortDateFormat.format(date);
  }

  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  static String formatDayOfWeek(DateTime date) {
    return _dayOfWeekFormat.format(date);
  }

  static String getRelativeDueDate(DateTime? dueDate) {
    if (dueDate == null) return 'No deadline';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final difference = target.difference(today).inDays;

    if (difference < -1) {
      return '${difference.abs()} days overdue';
    } else if (difference == -1) {
      return 'Yesterday (Overdue)';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference > 1 && difference < 7) {
      return 'In $difference days';
    } else {
      return _shortDateFormat.format(dueDate);
    }
  }

  static bool isOverdue(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(dueDate.year, dueDate.month, dueDate.day);
    return target.isBefore(today);
  }

  static bool isDueToday(DateTime? dueDate) {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day;
  }
}
