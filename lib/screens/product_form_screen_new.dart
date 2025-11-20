import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/sales_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_button.dart';
import '../widgets/glass_container.dart';

class ProductFormScreenNew extends StatefulWidget {
  final Product? product;

  const ProductFormScreenNew({super.key, this.product});

  @override
  State<ProductFormScreenNew> createState() => _ProductFormScreenNewState();
}

class _ProductFormScreenNewState extends State<ProductFormScreenNew>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
        text: widget.product?.price.toString() ?? '');
    _stockController = TextEditingController(
        text: widget.product?.stockQuantity.toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.product?.description ?? '');

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<SalesProvider>(context, listen: false);
    final product = Product(
      id: widget.product?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      price: double.parse(_priceController.text),
      stockQuantity: int.parse(_stockController.text),
      description: _descriptionController.text,
    );

    try {
      if (widget.product == null) {
        await provider.addProduct(product);
      } else {
        await provider.updateProduct(product);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.product == null
                  ? '✓ Product added successfully'
                  : '✓ Product updated successfully',
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error ?? Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          widget.product == null ? 'Add Product' : 'Edit Product',
          style: AppTheme.heading2(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: theme.colorScheme.onSurface,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          AppTheme.spacing20,
          MediaQuery.of(context).padding.top + 80,
          AppTheme.spacing20,
          AppTheme.spacing20,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Product Icon
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: isDark
                                    ? [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary,
                                      ]
                                    : [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.primaryContainer,
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusXLarge),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.inventory_2_rounded,
                              size: 56,
                              color: theme.colorScheme.onPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing48),

                  // Product Details Card
                  GlassContainer(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary
                                        .withValues(alpha: 0.2),
                                    theme.colorScheme.secondary
                                        .withValues(alpha: 0.2),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.shopping_bag_rounded,
                                color: theme.colorScheme.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing12),
                            Text(
                              'Product Details',
                              style: AppTheme.heading3(context).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing24),

                        // Product Name
                        _buildModernTextField(
                          context: context,
                          controller: _nameController,
                          label: 'Product Name',
                          hint: 'e.g., Premium Coffee Beans',
                          icon: Icons.label_rounded,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter product name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing20),

                        // Price and Stock Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildModernTextField(
                                context: context,
                                controller: _priceController,
                                label: 'Price',
                                hint: '0.00',
                                icon: Icons.attach_money_rounded,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter price';
                                  }
                                  if (double.tryParse(value) == null ||
                                      double.parse(value) <= 0) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing16),
                            Expanded(
                              child: _buildModernTextField(
                                context: context,
                                controller: _stockController,
                                label: 'Stock',
                                hint: '0',
                                icon: Icons.inventory_rounded,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Enter stock';
                                  }
                                  if (int.tryParse(value) == null ||
                                      int.parse(value) < 0) {
                                    return 'Invalid';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing20),

                        // Description
                        _buildModernTextField(
                          context: context,
                          controller: _descriptionController,
                          label: 'Description (Optional)',
                          hint: 'Add product details...',
                          icon: Icons.description_rounded,
                          maxLines: 4,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppTheme.spacing32),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacing16,
                            ),
                            side: BorderSide(
                              color: theme.colorScheme.outline,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusLarge),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: AppTheme.bodyLarge(context).copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        flex: 2,
                        child: ModernButton(
                          text: widget.product == null ? 'Add Product' : 'Save Changes',
                          icon: widget.product == null
                              ? Icons.add_rounded
                              : Icons.save_rounded,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.secondary,
                            ],
                          ),
                          onPressed: _saveProduct,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppTheme.bodyLarge(context).copyWith(
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.colorScheme.secondary.withValues(alpha: 0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
        ),
        filled: true,
        fillColor: isDark
            ? theme.colorScheme.surface.withValues(alpha: 0.4)
            : theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        labelStyle: AppTheme.bodyMedium(context).copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        hintStyle: AppTheme.bodyMedium(context).copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing20,
          vertical: AppTheme.spacing16,
        ),
      ),
      validator: validator,
    );
  }
}
