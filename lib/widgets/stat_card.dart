import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient? accentGradient;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.accentGradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradients = AppTheme.gradients(context);
    final palette = accentGradient ?? gradients.primary;
    final textTheme = Theme.of(context).textTheme;
    final titleStyle = AppTheme.bodySmall(context).copyWith(
      letterSpacing: 0.6,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.72),
    );

    return GlassContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.spacing20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: palette,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: AppTheme.spacing16),
              Flexible(
                child: Text(
                  title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: AppTheme.spacing8),
                Icon(
                  Icons.north_east_rounded,
                  size: 20,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.45),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => palette.createShader(bounds),
            child: Text(
              value,
              style: textTheme.headlineLarge,
            ),
          ),
        ],
      ),
    );
  }
}

