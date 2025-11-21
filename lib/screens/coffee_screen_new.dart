import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sales_provider.dart';
import '../models/sale_record.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_button.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_background.dart';

class CoffeeScreenNew extends StatefulWidget {
  const CoffeeScreenNew({super.key});

  @override
  State<CoffeeScreenNew> createState() => _CoffeeScreenNewState();
}

class _CoffeeScreenNewState extends State<CoffeeScreenNew> {
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : theme.colorScheme.onBackground;
    
    return GlassBackground(
      useSafeArea: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(
            'Coffee Sales',
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: textColor.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(Icons.arrow_back_rounded, color: textColor),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacing24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                const SizedBox(height: AppTheme.spacing32),
                GlassContainer(
                  padding: const EdgeInsets.all(AppTheme.spacing32),
                  borderRadius: BorderRadius.circular(80),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacing24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.warmGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentOrange.withValues(alpha: 0.35),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.local_cafe_rounded,
                      size: 76,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing32),
                Text(
                  'Add Coffee Sale',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                Text(
                  'Enter the total amount for coffee sales',
                  style: AppTheme.bodyMedium(context).copyWith(
                    color: textColor.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacing48),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Sale Amount',
                    hintText: '0.00',
                    prefixIcon: Icon(Icons.attach_money_rounded),
                  ),
                  style: AppTheme.heading3(context).copyWith(color: textColor),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppTheme.spacing32),
                // Total Coffee Sales Card
                Consumer<SalesProvider>(
                  builder: (context, provider, child) {
                    final coffeeSales = provider.getCoffeeSales();
                    return GlassContainer(
                      child: Column(
                        children: [
                          Text(
                            'Total Coffee Sales',
                            style: AppTheme.bodyMedium(context).copyWith(
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (rect) => AppTheme.warmGradient
                                .createShader(rect),
                            child: Text(
                              '${coffeeSales.toStringAsFixed(2)} лв.',
                              style: AppTheme.heading1(context).copyWith(
                                color: textColor,
                                fontSize: 42,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppTheme.spacing48),
                // Record Button
                ModernButton(
                  text: 'Record Coffee Sale',
                  icon: Icons.check_circle_rounded,
                  gradient: AppTheme.warmGradient,
                  width: double.infinity,
                  onPressed: _saveCoffeeSale,
                ),
              ],
            ),
          ),
        );
      },
        ),
      ),
      ),
    );
  }

  Future<void> _saveCoffeeSale() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final provider = Provider.of<SalesProvider>(context, listen: false);

    final sale = SaleRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      coffeeAmount: _amountController.text,
      quantity: 1,
      total: amount,
      date: DateTime.now(),
    );

    try {
      await provider.addSale(sale);

      if (mounted) {
        _amountController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Coffee sale recorded: ${amount.toStringAsFixed(2)} лв.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.error ?? Colors.red,
          ),
        );
      }
    }
  }
}

