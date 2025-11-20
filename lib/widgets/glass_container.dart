import 'dart:ui';

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double blur;
  final Color? overlayColor;
  final Gradient? gradient;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;
  final GestureTapCallback? onTap;

  const GlassContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.spacing20),
    this.borderRadius,
    this.blur = 24,
    this.overlayColor,
    this.gradient,
    this.border,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        BorderRadius.circular(AppTheme.radiusXLarge);
    final style = AppTheme.glassStyle(context);

    final content = Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: gradient ?? style.gradient,
        border: border ?? style.border,
        boxShadow: boxShadow ?? style.shadows,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            color: overlayColor ?? style.overlay,
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: content,
      ),
    );
  }
}

