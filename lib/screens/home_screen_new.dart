import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/sales_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/modern_card.dart';
import '../widgets/glass_container.dart';
import '../widgets/glass_background.dart';
import 'products_screen_new.dart';
import 'sales_screen_new.dart';
import 'coffee_screen_new.dart';
import 'donation_screen_new.dart';
import 'product_selection_screen.dart';
import 'login_screen.dart';
import 'analytics_screen.dart';

class HomeScreenNew extends StatefulWidget {
  const HomeScreenNew({super.key});

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _fabController;

  List<Widget> _buildScreens(bool isAdmin) {
    final List<Widget> screens = [
      const HomeTab(),
      const ProductsScreenNew(),
      const SalesScreenNew(),
    ];
    
    // Add Analytics screen for admins
    if (isAdmin) {
      screens.add(const AnalyticsScreen());
    }
    
    return screens;
  }
  
  List<NavigationDestination> _buildDestinations(bool isAdmin) {
    const destinations = [
      NavigationDestination(
        icon: Icon(Icons.grid_view_outlined),
        selectedIcon: Icon(Icons.grid_view_rounded),
        label: 'Home',
      ),
      NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined),
        selectedIcon: Icon(Icons.inventory_2_rounded),
        label: 'Products',
      ),
      NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long_rounded),
        label: 'Sales',
      ),
    ];
    
    // Add Analytics destination for admins
    if (isAdmin) {
      return [
        ...destinations,
        const NavigationDestination(
          icon: Icon(Icons.analytics_outlined),
          selectedIcon: Icon(Icons.analytics_rounded),
          label: 'Analytics',
        ),
      ];
    }
    
    return destinations;
  }

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index, bool isAdmin) {
    setState(() {
      _selectedIndex = index;
      // Show FAB only on Sales tab (index 2)
      if (index == 2) {
        _fabController.forward();
      } else {
        _fabController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final navPadding = MediaQuery.of(context).padding.bottom;

    return GlassBackground(
      useSafeArea: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final screens = _buildScreens(authProvider.isAdmin);
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: screens[_selectedIndex],
            );
          },
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.fromLTRB(
            AppTheme.spacing16,
            0,
            AppTheme.spacing16,
            16 + navPadding / 2,
          ),
          child: GlassContainer(
            padding: EdgeInsets.zero,
            borderRadius: BorderRadius.circular(28),
            blur: 16,
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return NavigationBar(
                  backgroundColor: Colors.transparent,
                  selectedIndex: _selectedIndex,
                  labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                  onDestinationSelected: (index) => _onItemTapped(index, authProvider.isAdmin),
                  destinations: _buildDestinations(authProvider.isAdmin),
                );
              },
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Padding(
          padding: EdgeInsets.only(bottom: 68 + navPadding + 16),
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: _fabController,
              curve: Curves.easeOutBack,
              reverseCurve: Curves.easeIn,
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(32),
                  onTap: _showSaleTypeDialog,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'New Sale',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showSaleTypeDialog() async {
    final gradients = AppTheme.gradients(context);
    final scheme = Theme.of(context).colorScheme;

    final result = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: AppTheme.spacing16,
          right: AppTheme.spacing16,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppTheme.spacing24,
        ),
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing24,
            vertical: AppTheme.spacing24,
          ),
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusXLarge),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing24),
              Text(
                'Create a sale',
                textAlign: TextAlign.center,
                style: AppTheme.heading2(context),
              ),
              const SizedBox(height: AppTheme.spacing12),
              Text(
                'Choose the channel you want to record a sale for',
                textAlign: TextAlign.center,
                style: AppTheme.bodyMedium(context)
                    .copyWith(color: scheme.onSurface.withValues(alpha: 0.65)),
              ),
              const SizedBox(height: AppTheme.spacing24),
              _buildSaleTypeOption(
                context,
                icon: Icons.shopping_cart_rounded,
                title: 'Product sale',
                subtitle: 'Sell products from your inventory',
                gradient: gradients.primary,
                onTap: () => Navigator.pop(context, 'product'),
              ),
              const SizedBox(height: AppTheme.spacing12),
              _buildSaleTypeOption(
                context,
                icon: Icons.local_cafe_rounded,
                title: 'Coffee bar',
                subtitle: 'Record a quick coffee transaction',
                gradient: gradients.warm,
                onTap: () => Navigator.pop(context, 'coffee'),
              ),
              const SizedBox(height: AppTheme.spacing12),
              _buildSaleTypeOption(
                context,
                icon: Icons.favorite_rounded,
                title: 'Donation',
                subtitle: 'Log a donation or sponsorship',
                gradient: gradients.secondary,
                onTap: () => Navigator.pop(context, 'donation'),
              ),
            ],
          ),
        ),
      ),
    );

    if (!mounted) return;

    if (result == 'product') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProductSelectionScreen()),
      );
    } else if (result == 'coffee') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CoffeeScreenNew()),
      );
    } else if (result == 'donation') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DonationScreenNew()),
      );
    }
  }

  Widget _buildSaleTypeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.08)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
                const SizedBox(width: AppTheme.spacing16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.titleMedium!
                            .copyWith(color: scheme.onSurface),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: textTheme.bodyMedium!
                            .copyWith(color: scheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: scheme.onSurface.withValues(alpha: 0.45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuraCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.05),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SalesProvider>(
      builder: (context, provider, child) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final isDark = theme.brightness == Brightness.dark;
        final textColor = isDark ? Colors.white : scheme.onBackground;
        final mutedText = textColor.withValues(alpha: 0.7);
        final subtleText = textColor.withValues(alpha: 0.6);
        final iconBackgroundColor = textColor.withValues(alpha: isDark ? 0.15 : 0.12);
        final iconBorderColor = textColor.withValues(alpha: isDark ? 0.3 : 0.18);

        final totalSales = provider.getTotalSales();
        final coffeeSales = provider.getCoffeeSales();
        final donationSales = provider.getDonationSales();
        final productSales = provider.getProductSales();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Dashboard',
                  style: AppTheme.heading2(context).copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
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
                Consumer<AuthProvider>(
                  builder: (context, authProvider, child) {
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
                          Icons.logout_rounded,
                          color: textColor,
                        ),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Sign Out'),
                              content: const Text('Are you sure you want to sign out?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.error ?? Colors.red,
                                  ),
                                  child: const Text('Sign Out'),
                                ),
                              ],
                            ),
                          );
                          
                          if (confirm == true && context.mounted) {
                            try {
                              await authProvider.signOut();
                              if (context.mounted) {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to sign out: ${e.toString()}'),
                                    backgroundColor: AppTheme.error ?? Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        tooltip: 'Sign Out',
                      ),
                    );
                  },
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.spacing20),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Total Sales Card
                  StatCard(
                    title: 'Total Sales',
                    value: '${totalSales.toStringAsFixed(2)} лв.',
                    icon: Icons.attach_money_rounded,
                    accentGradient: AppTheme.primaryGradient,
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  // Grid of stats
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: 'Products',
                          value: '${productSales.toStringAsFixed(2)} лв.',
                          icon: Icons.shopping_cart_rounded,
                          accentGradient: AppTheme.secondaryGradient,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing16),
                      Expanded(
                        child: StatCard(
                          title: 'Coffee',
                          value: '${coffeeSales.toStringAsFixed(2)} лв.',
                          icon: Icons.local_cafe_rounded,
                          accentGradient: AppTheme.warmGradient,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  StatCard(
                    title: 'Donations',
                    value: '${donationSales.toStringAsFixed(2)} лв.',
                    icon: Icons.favorite_rounded,
                    accentGradient: const LinearGradient(
                      colors: [Color(0xFFEC4899), Color(0xFFF43F5E)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing32),
                  // Recent Sales Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Sales',
                        style: AppTheme.heading2(context).copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (provider.sales.isNotEmpty)
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'See All',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: mutedText),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                  // Recent Sales List
                  if (provider.sales.isEmpty)
                    ModernCard(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppTheme.spacing32),
                          child: Column(
                            children: [
                              Icon(
                                Icons.receipt_long_rounded,
                                size: 64,
                                color: textColor.withValues(alpha: 0.25),
                              ),
                              const SizedBox(height: AppTheme.spacing16),
                              Text(
                                'No sales yet',
                                style: AppTheme.heading3(context).copyWith(
                                  color: textColor,
                                ),
                              ),
                              const SizedBox(height: AppTheme.spacing8),
                              Text(
                                'Start by adding products or making a sale',
                                style: AppTheme.bodyMedium(context).copyWith(
                                  color: mutedText,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    ...provider.sales.take(10).map((sale) {
                      IconData icon;
                      Color color;
                      switch (sale.type) {
                        case 'Coffee':
                          icon = Icons.local_cafe_rounded;
                          color = AppTheme.accentOrange;
                          break;
                        case 'Donation':
                          icon = Icons.favorite_rounded;
                          color = AppTheme.accentPink;
                          break;
                        default:
                          icon = Icons.shopping_cart_rounded;
                          color = AppTheme.secondaryColor;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
                        child: ModernCard(
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppTheme.spacing12),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                                ),
                                child: Icon(icon, color: color, size: 24),
                              ),
                              const SizedBox(width: AppTheme.spacing16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      sale.type,
                                      style: AppTheme.heading3(context).copyWith(
                                        fontSize: 16,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      DateFormat('MMM dd, yyyy • HH:mm').format(sale.date),
                                      style: AppTheme.bodySmall(context).copyWith(
                                        color: subtleText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${sale.total.toStringAsFixed(2)} лв.',
                                style: AppTheme.heading3(context).copyWith(
                                  color: color,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 100), // Bottom padding for FAB
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

