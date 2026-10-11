import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Represents a Category or Project to group tasks.
class TaskCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  const TaskCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  static const TaskCategory work = TaskCategory(
    id: 'work',
    name: 'Work',
    icon: Icons.work_outline_rounded,
    color: Color(0xFF6366F1),
    gradient: AppColors.categoryGradientsWork,
  );

  static const TaskCategory personal = TaskCategory(
    id: 'personal',
    name: 'Personal',
    icon: Icons.person_outline_rounded,
    color: Color(0xFFEC4899),
    gradient: AppColors.categoryGradientsPersonal,
  );

  static const TaskCategory health = TaskCategory(
    id: 'health',
    name: 'Health',
    icon: Icons.favorite_border_rounded,
    color: Color(0xFF10B981),
    gradient: AppColors.categoryGradientsHealth,
  );

  static const TaskCategory study = TaskCategory(
    id: 'study',
    name: 'Study',
    icon: Icons.menu_book_rounded,
    color: Color(0xFFF59E0B),
    gradient: AppColors.categoryGradientsStudy,
  );

  static const TaskCategory design = TaskCategory(
    id: 'design',
    name: 'Design',
    icon: Icons.palette_outlined,
    color: Color(0xFF8B5CF6),
    gradient: AppColors.categoryGradientsDesign,
  );

  static const TaskCategory finance = TaskCategory(
    id: 'finance',
    name: 'Finance',
    icon: Icons.account_balance_wallet_outlined,
    color: Color(0xFF06B6D4),
    gradient: AppColors.categoryGradientsFinance,
  );

  static const List<TaskCategory> defaultCategories = [
    work,
    personal,
    health,
    study,
    design,
    finance,
  ];

  static TaskCategory findById(String id) {
    return defaultCategories.firstWhere(
      (c) => c.id == id,
      orElse: () => work,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  factory TaskCategory.fromMap(Map<String, dynamic> map) {
    return findById(map['id'] as String? ?? 'work');
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskCategory &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
