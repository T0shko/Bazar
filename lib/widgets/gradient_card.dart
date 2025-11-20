import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  final LinearGradient? gradient;
  final Color? color;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.color,
    this.padding,
    this.onTap,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          color: color,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppTheme.radiusLarge,
          ),
          boxShadow: boxShadow ?? AppTheme.shadowMedium,
        ),
        padding: padding ?? const EdgeInsets.all(AppTheme.spacing20),
        child: child,
      ),
    );
  }
}

