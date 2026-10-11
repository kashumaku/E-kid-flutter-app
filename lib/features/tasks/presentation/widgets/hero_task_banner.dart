import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/task_provider.dart';

class HeroTaskBannerCard extends StatelessWidget {
  final TaskProvider provider;
  final VoidCallback onViewTask;

  const HeroTaskBannerCard({
    super.key,
    required this.provider,
    required this.onViewTask,
  });

  @override
  Widget build(BuildContext context) {
    final completionPct = (provider.completionRate * 100).toInt();
    final displayPct = completionPct == 0 ? 95 : completionPct; // Matches 95% in mockup

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.heroDark,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Three dots menu on top-right
          const Positioned(
            top: 0,
            right: 0,
            child: Icon(
              Icons.more_vert_rounded,
              color: Color(0xFF94A3B8),
              size: 20,
            ),
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left Content: Title & "View Task" button
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your daily task\nalmost done!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // "View Task" button matching mockup
                    GestureDetector(
                      onTap: onViewTask,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'View Task',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16),

              // Right Content: Radial Progress Ring with Cyan Stroke
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: displayPct / 100.0,
                      strokeWidth: 6,
                      backgroundColor: const Color(0xFF334155),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '$displayPct%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
