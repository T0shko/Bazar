import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class ModernButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final LinearGradient? gradient;
  final Color? color;
  final bool isOutlined;
  final bool isLoading;
  final double? width;
  final bool useGlass;

  const ModernButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.gradient,
    this.color,
    this.isOutlined = false,
    this.isLoading = false,
    this.width,
    this.useGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradients = AppTheme.gradients(context);
    final glass = AppTheme.glassStyle(context);

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing24,
            vertical: AppTheme.spacing16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          ),
          side: BorderSide(
            color: color ?? colorScheme.primary,
            width: 1.3,
          ),
          foregroundColor: color ?? colorScheme.primary,
        ),
        child: _buildChild(color ?? colorScheme.primary, context),
      );
    }

    if (useGlass) {
      return GlassContainer(
        onTap: isLoading ? null : onPressed,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing24,
          vertical: AppTheme.spacing16,
        ),
        gradient: glass.gradient,
        overlayColor: glass.overlay,
        child: Center(
          child: _buildChild(colorScheme.onSurface, context),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: width,
      decoration: BoxDecoration(
        gradient: gradient ?? gradients.primary,
        color: gradient == null ? (color ?? colorScheme.primary) : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: (color ?? colorScheme.primary).withValues(alpha: 0.32),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing24,
              vertical: AppTheme.spacing16,
            ),
            child: Center(
              child: _buildChild(colorScheme.onPrimary, context),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChild(Color textColor, BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: AppTheme.spacing8),
        ],
        Flexible(
          child: Text(
            text,
            style: AppTheme.button.copyWith(
              color: textColor,
              letterSpacing: 0.8,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

