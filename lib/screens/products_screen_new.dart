import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/modern_button.dart';
import '../widgets/glass_container.dart';
import 'product_form_screen_new.dart';

class ProductsScreenNew extends StatelessWidget {
  const ProductsScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        final textColor = isDark ? Colors.white : scheme.onBackground;
        final mutedText = textColor.withValues(alpha: 0.7);
        final iconBackgroundColor = textColor.withValues(alpha: isDark ? 0.15 : 0.12);
        final iconBorderColor = textColor.withValues(alpha: isDark ? 0.3 : 0.18);

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Products',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
                expandedTitleScale: 1.5,
              ),
              actions: [
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, child) {
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: iconBorderColor,
                          width: 1,
                        ),
                      ),
                      child: IconButton(
                        icon: Icon(
                          themeProvider.isDark 
                              ? Icons.light_mode_rounded 
                              : Icons.dark_mode_rounded,
                          color: textColor,
                        ),
                        onPressed: () {
                          themeProvider.toggle();
                        },
                        tooltip: themeProvider.isDark ? 'Light Mode' : 'Dark Mode',
                      ),
                    );
                  },
                ),
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  child: ModernButton(
                    text: 'Add',
                    icon: Icons.add,
                    useGlass: true,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProductFormScreenNew(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (provider.products.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GlassContainer(
                          padding: const EdgeInsets.all(AppTheme.spacing32),
                          child: Icon(
                            Icons.inventory_2_rounded,
                            size: 80,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                        Text(
                          'No products yet',
                          style: AppTheme.heading2(context).copyWith(color: textColor),
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        Text(
                          'Add your first product to get started\nwith managing your inventory',
                          style: AppTheme.bodyMedium(context).copyWith(
                            color: mutedText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.spacing32),
                        ModernButton(
                          text: 'Add First Product',
                          icon: Icons.add,
                          gradient: AppTheme.primaryGradient,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ProductFormScreenNew(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(AppTheme.spacing20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == provider.products.length) {
                        return const SizedBox(height: 100);
                      }
                      final product = provider.products[index];
                      return ProductCard(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductFormScreenNew(product: product),
                            ),
                          );
                        },
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductFormScreenNew(product: product),
                            ),
                          );
                        },
                        onDelete: () {
                          _showDeleteConfirmation(context, provider, product);
                        },
                      );
                    },
                    childCount: provider.products.length + 1,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    SalesProvider provider,
    product,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        ),
        title: Text('Delete Product', style: AppTheme.heading2(context)),
        content: Text(
          'Are you sure you want to delete ${product.name}?',
          style: AppTheme.bodyLarge(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.error,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: TextButton(
              onPressed: () {
                provider.deleteProduct(product.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${product.name} deleted'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

