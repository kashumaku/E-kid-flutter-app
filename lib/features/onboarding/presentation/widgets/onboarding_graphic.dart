import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/onboarding_slide.dart';

class OnboardingGraphic extends StatelessWidget {
  final GraphicType type;
  final List<Color> gradient;

  const OnboardingGraphic({
    super.key,
    required this.type,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: SizedBox(
        height: 260,
        width: 320,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background soft glowing aura
            Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    gradient.first.withValues(alpha: 0.28),
                    gradient.last.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),

          // Render type-specific graphic
          switch (type) {
            GraphicType.taskFlow => _buildTaskFlowGraphic(context),
            GraphicType.prioritySchedule => _buildPriorityScheduleGraphic(context),
            GraphicType.analyticsInsights => _buildAnalyticsGraphic(context),
          },
        ],
      ),
    ),
  );
}

  Widget _buildTaskFlowGraphic(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF162036) : Colors.white;
    final borderColor = isDark ? const Color(0xFF283548) : const Color(0xFFE2E8F0);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background tilted card
        Transform.rotate(
          angle: -0.06,
          child: Container(
            width: 280,
            height: 160,
            decoration: BoxDecoration(
              color: cardBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor.withValues(alpha: 0.5)),
            ),
          ),
        ),

        // Main Primary Task Card
        Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: gradient),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'DESIGN SYSTEM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.priorityUrgent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.priority_high_rounded, size: 12, color: AppColors.priorityUrgent),
                        SizedBox(width: 2),
                        Text(
                          'URGENT',
                          style: TextStyle(
                            color: AppColors.priorityUrgent,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Ship High-Impact Release 2.0',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              // Subtask 1
              _buildMiniCheckRow('Tokens & Glassmorphism polish', true, gradient.first),
              const SizedBox(height: 8),
              // Subtask 2
              _buildMiniCheckRow('Interactive physics & haptics', true, gradient.first),
              const SizedBox(height: 8),
              // Subtask 3
              _buildMiniCheckRow('Verify 100% test coverage', false, gradient.first),
            ],
          ),
        ),

        // Floating badge
        Positioned(
          top: 15,
          right: 25,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                SizedBox(width: 6),
                Text(
                  '2/3 Done',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityScheduleGraphic(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF162036) : Colors.white;
    final borderColor = isDark ? const Color(0xFF283548) : const Color(0xFFE2E8F0);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Main Calendar Schedule Box
        Container(
          width: 300,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: gradient.first.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.calendar_today_rounded, size: 18, color: gradient.first),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Today\'s Agenda',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '3 Tasks',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildScheduleSlot('09:00 AM', 'Sprint Architecture Review', AppColors.primary, true),
              const SizedBox(height: 10),
              _buildScheduleSlot('01:30 PM', 'Figma Prototype Review', AppColors.accent, false),
              const SizedBox(height: 10),
              _buildScheduleSlot('05:00 PM', '5km Sunset Trail Cardio', AppColors.success, false),
            ],
          ),
        ),

        // Floating Priority Pill
        Positioned(
          bottom: 20,
          right: 30,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.bolt_rounded, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Never Fall Behind',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsGraphic(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF162036) : Colors.white;
    final borderColor = isDark ? const Color(0xFF283548) : const Color(0xFFE2E8F0);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 300,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: gradient.first.withValues(alpha: 0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Velocity',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'Top 5% of Productive Weeks',
                        style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.trending_up_rounded, color: AppColors.success, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 7 Day Bars
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildDayBar('M', 45, false),
                  _buildDayBar('T', 70, false),
                  _buildDayBar('W', 55, false),
                  _buildDayBar('T', 85, true),
                  _buildDayBar('F', 65, false),
                  _buildDayBar('S', 95, true),
                  _buildDayBar('S', 110, true),
                ],
              ),
            ],
          ),
        ),

        // Floating Streak Badge
        Positioned(
          top: 15,
          left: 25,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department_rounded, size: 16, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  '🔥 5 Day Streak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCheckRow(String text, bool completed, Color accentColor) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: completed ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: completed ? accentColor : const Color(0xFF94A3B8),
              width: 1.5,
            ),
          ),
          child: completed
              ? const Icon(Icons.check, size: 12, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              decoration: completed ? TextDecoration.lineThrough : null,
              color: completed ? const Color(0xFF94A3B8) : null,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleSlot(String time, String title, Color dotColor, bool isNext) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isNext ? dotColor.withValues(alpha: 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNext ? dotColor.withValues(alpha: 0.3) : const Color(0x1FFFFFFF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            time,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayBar(String day, double height, bool isPeak) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: isPeak
                  ? [AppColors.success, const Color(0xFF34D399)]
                  : [AppColors.primary.withValues(alpha: 0.3), AppColors.primary],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isPeak ? FontWeight.w700 : FontWeight.w500,
            color: isPeak ? AppColors.success : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }
}
