import 'package:flutter/material.dart';
import '../../features/tasks/domain/models/task_priority.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool showIcon;
  final double fontSize;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.showIcon = true,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    final color = priority.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              priority.icon,
              size: fontSize + 2,
              color: color,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            priority.displayName.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
