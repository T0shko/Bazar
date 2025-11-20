import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final glass = AppTheme.glassStyle(context);
    return GlassContainer(
      onTap: onTap,
      padding: padding ?? const EdgeInsets.all(AppTheme.spacing16),
      overlayColor: color ?? glass.overlay,
      child: child,
    );
  }
}

