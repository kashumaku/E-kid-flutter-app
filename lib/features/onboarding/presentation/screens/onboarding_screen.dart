import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/onboarding_repository.dart';
import '../widgets/onboarding_graphic.dart';
import '../../../navigation/main_nav_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  final IOnboardingRepository onboardingRepository;
  final bool isReplay;

  const OnboardingScreen({
    super.key,
    required this.onboardingRepository,
    this.isReplay = false,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _currentPage = 2; // Active page matching the mockup's 3rd dot

  void _onStart() async {
    if (!widget.isReplay) {
      await widget.onboardingRepository.setOnboardingCompleted(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavScaffold(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Central Illustration from mockup
              const Center(
                child: OnboardingGraphic(),
              ),

              const SizedBox(height: 36),

              // Dots indicator (4 dots with active cyan pill)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final isActive = index == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 36),

              // Heading: "Manage your task"
              Text(
                'Manage your task',
                textAlign: TextAlign.center,
                style: AppTypography.displaySmall.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Increase your productivity by managing\nyour personal and team task',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: const Color(0xFF6B7280),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const Spacer(flex: 3),

              // Bottom Button: "Let's Start"
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _onStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    widget.isReplay ? 'Back to App' : "Let's Start",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
