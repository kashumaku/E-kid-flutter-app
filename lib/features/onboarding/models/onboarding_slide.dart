import 'package:flutter/material.dart';

enum GraphicType {
  taskFlow,
  prioritySchedule,
  analyticsInsights,
}

class OnboardingSlide {
  final String title;
  final String subtitle;
  final String badge;
  final GraphicType graphicType;
  final List<Color> gradient;

  const OnboardingSlide({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.graphicType,
    required this.gradient,
  });

  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      badge: 'SEAMLESS FLOW',
      title: 'Conquer Your Day With Precision',
      subtitle: 'Organize high-impact goals into dynamic projects, actionable subtasks, and rich tags designed for maximum focus.',
      graphicType: GraphicType.taskFlow,
      gradient: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
    ),
    OnboardingSlide(
      badge: 'SMART PRIORITIES',
      title: 'Never Miss Critical Deadlines',
      subtitle: 'Intelligent urgent-to-low priority tagging and unified day scheduling keep you ahead of your most demanding commitments.',
      graphicType: GraphicType.prioritySchedule,
      gradient: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
    ),
    OnboardingSlide(
      badge: 'PEAK MOMENTUM',
      title: 'Visualize Your Productivity Growth',
      subtitle: 'Track completion streaks, weekly velocity charts, and category balance to unlock your highest potential every single week.',
      graphicType: GraphicType.analyticsInsights,
      gradient: [Color(0xFF10B981), Color(0xFF059669)],
    ),
  ];
}
