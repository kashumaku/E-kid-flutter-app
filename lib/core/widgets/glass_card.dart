import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final BorderSide? borderSide;
  final Color? backgroundColor;
  final double borderRadius;
  final double elevation;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.borderSide,
    this.backgroundColor,
    this.borderRadius = 18,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = backgroundColor ?? (isDark ? AppColors.darkCard : AppColors.lightCard);
    final defaultBorder = borderSide ??
        BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        );

    Widget content = Material(
      color: defaultBg,
      elevation: elevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: defaultBorder,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}
