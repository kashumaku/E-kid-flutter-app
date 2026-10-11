import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TaskPieChart extends StatelessWidget {
  const TaskPieChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Pie Chart graphic
        SizedBox(
          width: 120,
          height: 120,
          child: CustomPaint(
            painter: _PieChartPainter(),
          ),
        ),

        const SizedBox(width: 20),

        // Legend
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: AppColors.chartFinishOnTime,
                label: 'Finish on time',
              ),
              SizedBox(height: 10),
              _LegendItem(
                color: AppColors.chartPastDeadline,
                label: 'Past the deadline',
              ),
              SizedBox(height: 10),
              _LegendItem(
                color: AppColors.chartOngoing,
                label: 'Still ongoing',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
            ),
          ),
        ),
      ],
    );
  }
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Segment 1: Cyan (40% => 0.40 * 2pi = 1.44 pi ~ 144 degrees)
    final paint1 = Paint()
      ..color = AppColors.chartFinishOnTime
      ..style = PaintingStyle.fill;
    const startAngle1 = -math.pi / 2;
    const sweepAngle1 = 0.40 * 2 * math.pi;
    canvas.drawArc(rect, startAngle1, sweepAngle1, true, paint1);

    // Segment 2: Orange (40% => 144 degrees)
    final paint2 = Paint()
      ..color = AppColors.chartPastDeadline
      ..style = PaintingStyle.fill;
    const startAngle2 = startAngle1 + sweepAngle1;
    const sweepAngle2 = 0.40 * 2 * math.pi;
    canvas.drawArc(rect, startAngle2, sweepAngle2, true, paint2);

    // Segment 3: Purple (20% => 72 degrees)
    final paint3 = Paint()
      ..color = AppColors.chartOngoing
      ..style = PaintingStyle.fill;
    const startAngle3 = startAngle2 + sweepAngle2;
    const sweepAngle3 = 0.20 * 2 * math.pi;
    canvas.drawArc(rect, startAngle3, sweepAngle3, true, paint3);

    // Text labels inside the slices matching mockup ("40%", "40%", "20%")
    _drawText(canvas, '40%', Offset(center.dx + 12, center.dy - 22));
    _drawText(canvas, '40%', Offset(center.dx + 14, center.dy + 14));
    _drawText(canvas, '20%', Offset(center.dx - 28, center.dy + 4));
  }

  void _drawText(Canvas canvas, String text, Offset position) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w700,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
