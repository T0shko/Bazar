import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class GlassBackground extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  const GlassBackground({
    super.key,
    required this.child,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = Stack(
      children: [
        // Base background
        Container(
          color: isDark 
              ? const Color(0xFF060714) 
              : const Color(0xFFFAFAFF),
        ),

        // Large radial gradient auras
        Positioned(
          top: -140,
          left: -60,
          child: _AuraCircle(
            size: 320,
            colors: isDark 
                ? const [Color(0xFF6366F1), Color(0xFF8B5CF6)]
                : const [Color(0xFF7B7EFF), Color(0xFFB5A9FF)],
            opacity: isDark ? 0.35 : 0.12,
          ),
        ),
        Positioned(
          bottom: -120,
          right: -40,
          child: _AuraCircle(
            size: 280,
            colors: isDark 
                ? const [Color(0xFF10B981), Color(0xFF06B6D4)]
                : const [Color(0xFF00D4E8), Color(0xFF8DE5FF)],
            opacity: isDark ? 0.30 : 0.10,
          ),
        ),
        Positioned(
          top: 160,
          right: -100,
          child: _AuraCircle(
            size: 220,
            colors: isDark 
                ? const [Color(0xFFF59E0B), Color(0xFFEC4899)]
                : const [Color(0xFFFF8A50), Color(0xFFFFB4D6)],
            opacity: isDark ? 0.18 : 0.08,
          ),
        ),

        BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: isDark ? 24 : 32,
            sigmaY: isDark ? 24 : 32,
          ),
          child: const SizedBox.expand(),
        ),


        IgnorePointer(
          ignoring: true,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: 0.06),
                        Colors.white.withValues(alpha: 0.0),
                      ]
                    : [
                        theme.colorScheme.primary.withValues(alpha: 0.04),
                        Colors.transparent,
                      ],
                stops: const [0.0, 0.6],
              ),
            ),
          ),
        ),

        // Page content
        Positioned.fill(
          child: useSafeArea ? SafeArea(child: child) : child,
        ),
      ],
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: content,
    );
  }
}

class _AuraCircle extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final double opacity;

  const _AuraCircle({
    required this.size,
    required this.colors,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colors.first.withValues(alpha: opacity),
            colors.last.withValues(alpha: opacity * 0.5),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        boxShadow: AppTheme.shadowColored(colors.last),
      ),
    );
  }
}


