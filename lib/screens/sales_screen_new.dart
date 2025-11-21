import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/sales_provider.dart';
import '../models/product.dart';
import '../models/sale_record.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/modern_button.dart';
import '../widgets/product_card.dart';
import '../widgets/glass_container.dart';

class SalesScreenNew extends StatelessWidget {
  const SalesScreenNew({super.key});

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
                  'Make a Sale',
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
                      margin: const EdgeInsets.only(right: 16),
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
                            Icons.shopping_cart_rounded,
                            size: 80,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing24),
                        Text(
                          'No products available',
                          style: AppTheme.heading2(context).copyWith(color: textColor),
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        Text(
                          'Add products first to make sales',
                          style: AppTheme.bodyMedium(context).copyWith(color: mutedText),
                          textAlign: TextAlign.center,
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
                        onTap: () => _showSaleDialog(context, product, provider),
                        onEdit: null,
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

  void _showSaleDialog(BuildContext context, Product product, SalesProvider provider) {
    final quantityController = TextEditingController(text: '1');
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => GlassContainer(
        padding: EdgeInsets.only(
          left: AppTheme.spacing24,
          right: AppTheme.spacing24,
          top: AppTheme.spacing24,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacing24,
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              // Product Info
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: product.imageUrl == null
                            ? Colors.white.withValues(alpha: 0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: product.imageUrl != null
                            ? Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        child: product.imageUrl != null
                            ? CachedNetworkImage(
                                imageUrl: product.imageUrl!,
                                fit: BoxFit.cover,
                                width: 56,
                                height: 56,
                                placeholder: (context, url) => Container(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  child: Center(
                                    child: Text(
                                      product.name[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Center(
                                child: Text(
                                  product.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: AppTheme.heading3(context).copyWith(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${product.price.toStringAsFixed(2)} лв. per unit',
                            style: AppTheme.bodyMedium(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Stock: ${product.stockQuantity}',
                            style: AppTheme.bodySmall(context).copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              // Quantity Field
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity to sell',
                  prefixIcon: Icon(Icons.shopping_bag_rounded),
                ),
                style: AppTheme.bodyLarge(context),
                keyboardType: TextInputType.number,
                autofocus: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  final quantity = int.tryParse(value);
                  if (quantity == null || quantity <= 0) {
                    return 'Please enter a valid quantity';
                  }
                  if (quantity > product.stockQuantity) {
                    return 'Only ${product.stockQuantity} units available';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppTheme.spacing24),
              // Total Display
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: AppTheme.secondaryLight.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: AppTheme.heading3(context),
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: quantityController,
                      builder: (context, value, child) {
                        final quantity = int.tryParse(value.text) ?? 0;
                        final total = product.price * quantity;
                        return Text(
                          '${total.toStringAsFixed(2)} лв.',
                          style: AppTheme.heading2(context).copyWith(
                            color: AppTheme.secondaryColor,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              // Complete Sale Button
              ModernButton(
                text: 'Complete Sale',
                icon: Icons.check_circle_rounded,
                gradient: AppTheme.secondaryGradient,
                onPressed: () async {
                  if (!formKey.currentState!.validate()) return;

                  final quantity = int.parse(quantityController.text);
                  final total = product.price * quantity;

                  final sale = SaleRecord(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    product: product,
                    quantity: quantity,
                    total: total,
                    date: DateTime.now(),
                  );

                  try {
                    await provider.addSale(sale);
                    await provider.updateProduct(
                      product.copyWith(stockQuantity: product.stockQuantity - quantity),
                      shouldLogAction: false, // Don't log automatic stock updates from sales
                    );

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sale completed: ${total.toStringAsFixed(2)} лв.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppTheme.error ?? Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

