import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import '../models/product.dart';
import '../models/sale_record.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_background.dart';

class ProductSelectionScreen extends StatefulWidget {
  const ProductSelectionScreen({super.key});

  @override
  State<ProductSelectionScreen> createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> _getFilteredProducts(List<Product> products) {
    if (_searchQuery.isEmpty) {
      return products;
    }
    return products.where((product) =>
      product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      product.description.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : scheme.onBackground;
    final mutedText = textColor.withValues(alpha: 0.7);

    return GlassBackground(
      useSafeArea: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<SalesProvider>(
          builder: (context, provider, child) {
            final filteredProducts = _getFilteredProducts(provider.products);

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 140,
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      'Select Product',
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
                    expandedTitleScale: 1.3,
                  ),
                  leading: IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: textColor,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(AppTheme.spacing20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == 0) {
                          // Search field
                          return Column(
                            children: [
                              GlassContainer(
                                padding: const EdgeInsets.all(AppTheme.spacing16),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search products...',
                                    hintStyle: AppTheme.bodyMedium(context).copyWith(
                                      color: mutedText,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: textColor.withValues(alpha: 0.7),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                  ),
                                  style: AppTheme.bodyLarge(context).copyWith(color: textColor),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing20),
                              if (filteredProducts.isEmpty && _searchQuery.isNotEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppTheme.spacing32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.search_off_rounded,
                                          size: 64,
                                          color: mutedText,
                                        ),
                                        const SizedBox(height: AppTheme.spacing16),
                                        Text(
                                          'No products found',
                                          style: AppTheme.heading3(context).copyWith(color: textColor),
                                        ),
                                        const SizedBox(height: AppTheme.spacing8),
                                        Text(
                                          'Try a different search term',
                                          style: AppTheme.bodyMedium(context).copyWith(color: mutedText),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else if (filteredProducts.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppTheme.spacing32),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.inventory_2_rounded,
                                          size: 64,
                                          color: mutedText,
                                        ),
                                        const SizedBox(height: AppTheme.spacing16),
                                        Text(
                                          'No products available',
                                          style: AppTheme.heading3(context).copyWith(color: textColor),
                                        ),
                                        const SizedBox(height: AppTheme.spacing8),
                                        Text(
                                          'Add products first to make sales',
                                          style: AppTheme.bodyMedium(context).copyWith(color: mutedText),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                Text(
                                  '${filteredProducts.length} product${filteredProducts.length == 1 ? '' : 's'} found',
                                  style: AppTheme.bodyMedium(context).copyWith(color: mutedText),
                                ),
                              const SizedBox(height: AppTheme.spacing16),
                            ],
                          );
                        }

                        final productIndex = index - 1;
                        if (productIndex >= filteredProducts.length) {
                          return const SizedBox(height: 100);
                        }

                        final product = filteredProducts[productIndex];
                        return _ProductSelectionCard(
                          product: product,
                          onSelect: () => _showSaleDialog(context, product, provider),
                        );
                      },
                      childCount: filteredProducts.isEmpty ? 2 : filteredProducts.length + 2,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      ),
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
                    Flexible(
                      child: Text(
                        'Total',
                        style: AppTheme.heading3(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing8),
                    Flexible(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: quantityController,
                        builder: (context, value, child) {
                          final quantity = int.tryParse(value.text) ?? 0;
                          final total = product.price * quantity;
                          return Text(
                            '${total.toStringAsFixed(2)} лв.',
                            style: AppTheme.heading2(context).copyWith(
                              color: AppTheme.secondaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          );
                        },
                      ),
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
                onPressed: () {
                  if (!formKey.currentState!.validate()) return;

                  final quantity = int.parse(quantityController.text);
                  final total = product.price * quantity;

                  final sale = SaleRecord(
                    id: DateTime.now().toString(),
                    product: product,
                    quantity: quantity,
                    total: total,
                    date: DateTime.now(),
                  );

                  provider.addSale(sale);
                  provider.updateProduct(
                    product.copyWith(stockQuantity: product.stockQuantity - quantity),
                    shouldLogAction: false, // Don't log automatic stock updates from sales
                  );

                  Navigator.pop(context); // Close sale dialog
                  Navigator.pop(context); // Close product selection screen

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Sale completed: ${total.toStringAsFixed(2)} лв.'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: AppTheme.success,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductSelectionCard extends StatelessWidget {
  final Product product;
  final VoidCallback onSelect;

  const _ProductSelectionCard({
    required this.product,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : theme.colorScheme.onBackground;

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: GlassContainer(
        padding: const EdgeInsets.all(AppTheme.spacing16),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
              child: Center(
                child: Text(
                  product.name[0].toUpperCase(),
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${product.price.toStringAsFixed(2)} лв. • Stock: ${product.stockQuantity}',
                    style: AppTheme.bodySmall(context).copyWith(
                      color: textColor.withValues(alpha: 0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.description.isNotEmpty)
                    Text(
                      product.description,
                      style: AppTheme.bodySmall(context).copyWith(
                        color: textColor.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: textColor.withValues(alpha: 0.5),
              size: 16,
            ),
          ],
        ),
      ),
      ),
    );
  }
}
