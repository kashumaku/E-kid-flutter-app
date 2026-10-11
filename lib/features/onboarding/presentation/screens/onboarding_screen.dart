import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/onboarding_repository.dart';
import '../../models/onboarding_slide.dart';
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
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onFinish() async {
    if (!widget.isReplay) {
      await widget.onboardingRepository.setOnboardingCompleted(true);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
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

  void _onNext() {
    if (_currentPage < OnboardingSlide.slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _onFinish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLastPage = _currentPage == OnboardingSlide.slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.task_alt_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'ApexTask',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  if (!isLastPage || widget.isReplay)
                    TextButton(
                      onPressed: _onFinish,
                      style: TextButton.styleFrom(
                        foregroundColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                      ),
                      child: Text(
                        widget.isReplay ? 'Close' : 'Skip',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                ],
              ),
            ),

            // PageView Slider
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: OnboardingSlide.slides.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final slide = OnboardingSlide.slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Center(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated graphic illustration
                            OnboardingGraphic(
                              type: slide.graphicType,
                              gradient: slide.gradient,
                            ),
                            const SizedBox(height: 16),

                            // Pill badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: slide.gradient.first.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: slide.gradient.first.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Text(
                                slide.badge,
                                style: TextStyle(
                                  color: slide.gradient.first,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Title
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: AppTypography.displayMedium.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.8,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Subtitle
                            Text(
                              slide.subtitle,
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Navigation Area
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Smooth Animated Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      OnboardingSlide.slides.length,
                      (index) {
                        final isSelected = index == _currentPage;
                        final activeColor = OnboardingSlide.slides[_currentPage].gradient.first;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: isSelected ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? activeColor
                                : (isDark ? const Color(0xFF283548) : const Color(0xFFCBD5E1)),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: activeColor.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Call to Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _onNext,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.zero,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: OnboardingSlide.slides[_currentPage].gradient,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: OnboardingSlide.slides[_currentPage].gradient.first.withValues(alpha: 0.35),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastPage
                                    ? (widget.isReplay ? 'Back to App' : 'Get Started With ApexTask')
                                    : 'Continue',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastPage ? Icons.check_circle_outline_rounded : Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
