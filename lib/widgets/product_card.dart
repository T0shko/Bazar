import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock = product.stockQuantity < 10;
    final gradients = AppTheme.gradients(context);
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: GlassContainer(
        onTap: onTap,
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: gradients.primary,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    boxShadow: [
                      BoxShadow(
                        color: gradients.primary.colors.last
                            .withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      product.name[0].toUpperCase(),
                      style: AppTheme.heading3(context)
                          .copyWith(color: Colors.white, fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              product.name,
                              style: AppTheme.heading3(context)
                                  .copyWith(color: scheme.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onEdit != null) ...[
                            const SizedBox(width: AppTheme.spacing8),
                            _ActionChip(
                              icon: Icons.edit_rounded,
                              tooltip: 'Edit product',
                              onTap: onEdit!,
                              color: scheme.primary,
                            ),
                          ],
                          if (onDelete != null) ...[
                            const SizedBox(width: AppTheme.spacing8),
                            _ActionChip(
                              icon: Icons.delete_outline_rounded,
                              tooltip: 'Delete product',
                              onTap: onDelete!,
                              color: scheme.error,
                            ),
                          ],
                        ],
                      ),
                      if (product.description.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          product.description,
                          style: AppTheme.bodyMedium(context).copyWith(
                            color:
                                scheme.onSurface.withValues(alpha: 0.65),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing20),
            Wrap(
              spacing: AppTheme.spacing12,
              runSpacing: AppTheme.spacing12,
              children: [
                _GradientChip(
                  label: '${product.price.toStringAsFixed(2)} лв.',
                  icon: Icons.monetization_on_rounded,
                  gradient: gradients.secondary,
                ),
                _GradientChip(
                  label: '${product.stockQuantity} in stock',
                  icon: isLowStock
                      ? Icons.warning_amber_rounded
                      : Icons.inventory_2_rounded,
                  gradient: isLowStock ? gradients.warm : gradients.success,
                  foregroundColor:
                      isLowStock ? Colors.white : scheme.onSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GradientChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color? foregroundColor;

  const _GradientChip({
    required this.label,
    required this.icon,
    required this.gradient,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = AppTheme.bodySmall(context).copyWith(
      fontWeight: FontWeight.w600,
      color: foregroundColor ?? Colors.white,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.last.withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing16,
          vertical: AppTheme.spacing8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foregroundColor ?? Colors.white),
            const SizedBox(width: AppTheme.spacing8),
            Flexible(
              child: Text(
                label,
                style: textStyle,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final Color color;

  const _ActionChip({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacing8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

