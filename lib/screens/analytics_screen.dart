import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/action_log.dart';
import '../services/action_log_service.dart';
import '../providers/sales_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/modern_card.dart';
import '../widgets/glass_background.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen>
    with SingleTickerProviderStateMixin {
  final ActionLogService _actionLogService = ActionLogService();
  final List<ActionLog> _actionLogs = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  String? _error;
  
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final startDate = DateTime(_selectedDate.year, _selectedDate.month, 1);
      final endDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 0, 23, 59, 59);

      final logs = await _actionLogService.getActionLogs(
        startDate: startDate,
        endDate: endDate,
      );
      final stats = await _actionLogService.getActionStats(
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        _actionLogs.clear();
        _actionLogs.addAll(logs);
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _rollbackAction(String actionLogId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rollback Action'),
        content: const Text(
          'Are you sure you want to rollback this action? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Rollback'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _actionLogService.rollbackAction(actionLogId);
      
      // Refresh sales and products data after rollback
      final salesProvider = Provider.of<SalesProvider>(context, listen: false);
      await salesProvider.loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Action rolled back successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Reload action logs
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to rollback: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : scheme.onSurface;
    final mutedText = textColor.withValues(alpha: 0.7);

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Analytics',
            style: AppTheme.heading2(context).copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            labelColor: scheme.primary,
            unselectedLabelColor: mutedText,
            indicatorColor: scheme.primary,
            tabs: const [
              Tab(text: 'Actions', icon: Icon(Icons.list_rounded)),
              Tab(text: 'Charts', icon: Icon(Icons.bar_chart_rounded)),
              Tab(text: 'Calendar', icon: Icon(Icons.calendar_today_rounded)),
            ],
          ),
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: scheme.primary),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: mutedText),
                        const SizedBox(height: 16),
                        Text(
                          'Error: $_error',
                          style: AppTheme.bodyMedium(context)
                              .copyWith(color: mutedText),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildActionsTab(textColor, mutedText, scheme),
                      _buildChartsTab(textColor, mutedText, scheme),
                      _buildCalendarTab(textColor, mutedText, scheme),
                    ],
                  ),
      ),
    );
  }

  Widget _buildActionsTab(Color textColor, Color mutedText, ColorScheme scheme) {
    if (_actionLogs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: mutedText),
            const SizedBox(height: 16),
            Text(
              'No actions recorded',
              style: AppTheme.heading3(context).copyWith(color: textColor),
            ),
            const SizedBox(height: 8),
            Text(
              'Actions will appear here as users interact with the system',
              style: AppTheme.bodyMedium(context).copyWith(color: mutedText),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        itemCount: _actionLogs.length,
        itemBuilder: (context, index) {
          final log = _actionLogs[index];
          return _buildActionLogItem(log, textColor, mutedText, scheme);
        },
      ),
    );
  }

  Widget _buildActionLogItem(
    ActionLog log,
    Color textColor,
    Color mutedText,
    ColorScheme scheme,
  ) {
    IconData icon;
    Color iconColor;

    switch (log.actionType) {
      case 'create_product':
        icon = Icons.add_circle_outline;
        iconColor = Colors.green;
        break;
      case 'update_product':
        icon = Icons.edit_outlined;
        iconColor = Colors.blue;
        break;
      case 'delete_product':
        icon = Icons.delete_outline;
        iconColor = Colors.red;
        break;
      case 'create_sale':
        icon = Icons.shopping_cart_outlined;
        iconColor = Colors.orange;
        break;
      case 'delete_sale':
        icon = Icons.remove_shopping_cart_outlined;
        iconColor = Colors.red;
        break;
      case 'rollback_action':
        icon = Icons.undo_outlined;
        iconColor = Colors.purple;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = scheme.primary;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      child: ModernCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.description,
                        style: AppTheme.heading3(context).copyWith(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 14,
                            color: mutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            log.username ?? 'Unknown',
                            style: AppTheme.bodySmall(context).copyWith(
                              color: mutedText,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: mutedText,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, HH:mm').format(log.timestamp),
                            style: AppTheme.bodySmall(context).copyWith(
                              color: mutedText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (log.isRolledBack)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Rolled Back',
                      style: AppTheme.bodySmall(context).copyWith(
                        color: mutedText,
                        fontSize: 10,
                      ),
                    ),
                  )
                else if (log.oldData != null || log.actionType == 'create_product' || log.actionType == 'create_sale')
                  IconButton(
                    icon: const Icon(Icons.undo_rounded),
                    color: scheme.error,
                    onPressed: () => _rollbackAction(log.id),
                    tooltip: 'Rollback',
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsTab(Color textColor, Color mutedText, ColorScheme scheme) {
    final actionTypeCounts = _stats['action_type_counts'] as Map<String, int>? ?? {};
    final userActionCounts = _stats['user_action_counts'] as Map<String, int>? ?? {};
    final dailyCounts = _stats['daily_counts'] as Map<String, int>? ?? {};

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacing16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales by Type',
              style: AppTheme.heading2(context).copyWith(color: textColor),
            ),
            const SizedBox(height: AppTheme.spacing16),
            Consumer<SalesProvider>(
              builder: (context, salesProvider, child) {
                final coffeeSales = salesProvider.getCoffeeSales();
                final donationSales = salesProvider.getDonationSales();
                final productSales = salesProvider.getProductSales();
                final totalSales = coffeeSales + donationSales + productSales;

                if (totalSales == 0) {
                  return ModernCard(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacing32),
                        child: Text(
                          'No sales data available',
                          style: AppTheme.bodyMedium(context).copyWith(color: mutedText),
                        ),
                      ),
                    ),
                  );
                }

                final salesData = {
                  'Donation': donationSales,
                  'Coffee': coffeeSales,
                  'Product Sales': productSales,
                };

                return ModernCard(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: PieChart(
                          PieChartData(
                            sections: _buildSalesPieChartSections(salesData, scheme),
                            centerSpaceRadius: 60,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      _buildLegend(salesData, totalSales, textColor, mutedText, scheme),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppTheme.spacing32),
            Text(
              'User Activity',
              style: AppTheme.heading2(context).copyWith(color: textColor),
            ),
            const SizedBox(height: AppTheme.spacing16),
            if (userActionCounts.isEmpty)
              ModernCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing32),
                    child: Text(
                      'No data available',
                      style: AppTheme.bodyMedium(context).copyWith(color: mutedText),
                    ),
                  ),
                ),
              )
            else
              ModernCard(
                child: SizedBox(
                  height: 300,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: userActionCounts.values.reduce((a, b) => a > b ? a : b).toDouble() * 1.2,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final users = userActionCounts.keys.toList();
                              if (value.toInt() >= 0 && value.toInt() < users.length) {
                                final username = users[value.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    username.length > 8 ? '${username.substring(0, 8)}...' : username,
                                    style: AppTheme.bodySmall(context).copyWith(color: mutedText),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: AppTheme.bodySmall(context).copyWith(color: mutedText),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: _buildBarGroups(userActionCounts, scheme),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppTheme.spacing32),
            Text(
              'Daily Activity',
              style: AppTheme.heading2(context).copyWith(color: textColor),
            ),
            const SizedBox(height: AppTheme.spacing16),
            if (dailyCounts.isEmpty)
              ModernCard(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing32),
                    child: Text(
                      'No data available',
                      style: AppTheme.bodyMedium(context).copyWith(color: mutedText),
                    ),
                  ),
                ),
              )
            else
              ModernCard(
                child: SizedBox(
                  height: 300,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final dates = dailyCounts.keys.toList()..sort();
                              if (value.toInt() >= 0 && value.toInt() < dates.length) {
                                final date = dates[value.toInt()];
                                final parts = date.split('-');
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${parts[2]}/${parts[1]}',
                                    style: AppTheme.bodySmall(context).copyWith(color: mutedText),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                value.toInt().toString(),
                                style: AppTheme.bodySmall(context).copyWith(color: mutedText),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _buildLineChartSpots(dailyCounts),
                          isCurved: true,
                          color: scheme.primary,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: scheme.primary.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(
    Map<String, int> counts,
    ColorScheme scheme,
  ) {
    final colors = [
      scheme.primary,
      scheme.secondary,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
    ];
    final total = counts.values.fold(0, (sum, count) => sum + count);
    
    return counts.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final count = entry.value.value;
      final percentage = (count / total * 100);
      
      return PieChartSectionData(
        value: count.toDouble(),
        title: '${percentage.toStringAsFixed(1)}%',
        color: colors[index % colors.length],
        radius: 100,
        titleStyle: AppTheme.bodySmall(context).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      );
    }).toList();
  }

  List<PieChartSectionData> _buildSalesPieChartSections(
    Map<String, double> salesData,
    ColorScheme scheme,
  ) {
    final colors = {
      'Donation': AppTheme.accentPink,
      'Coffee': AppTheme.accentOrange,
      'Product Sales': scheme.primary,
    };
    
    final total = salesData.values.fold(0.0, (sum, amount) => sum + amount);
    
    return salesData.entries.where((entry) => entry.value > 0).map((entry) {
      final type = entry.key;
      final amount = entry.value;
      final percentage = (amount / total * 100);
      final color = colors[type] ?? scheme.secondary;
      
      return PieChartSectionData(
        value: amount,
        title: '${percentage.toStringAsFixed(1)}%',
        color: color,
        radius: 100,
        titleStyle: AppTheme.bodySmall(context).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(
    Map<String, double> salesData,
    double totalSales,
    Color textColor,
    Color mutedText,
    ColorScheme scheme,
  ) {
    final colors = {
      'Donation': AppTheme.accentPink,
      'Coffee': AppTheme.accentOrange,
      'Product Sales': scheme.primary,
    };

    return Column(
      children: salesData.entries.where((entry) => entry.value > 0).map((entry) {
        final type = entry.key;
        final amount = entry.value;
        final percentage = (amount / totalSales * 100);
        final color = colors[type] ?? scheme.secondary;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing8),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Expanded(
                child: Text(
                  type,
                  style: AppTheme.bodyMedium(context).copyWith(color: textColor),
                ),
              ),
              Text(
                '${amount.toStringAsFixed(2)} лв.',
                style: AppTheme.bodyMedium(context).copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                '(${percentage.toStringAsFixed(1)}%)',
                style: AppTheme.bodySmall(context).copyWith(color: mutedText),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<BarChartGroupData> _buildBarGroups(
    Map<String, int> counts,
    ColorScheme scheme,
  ) {
    return counts.entries.toList().asMap().entries.map((entry) {
      final index = entry.key;
      final count = entry.value.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: scheme.primary,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  List<FlSpot> _buildLineChartSpots(Map<String, int> counts) {
    final dates = counts.keys.toList()..sort();
    return dates.asMap().entries.map((entry) {
      final index = entry.key;
      final date = entry.value;
      final count = counts[date] ?? 0;
      return FlSpot(index.toDouble(), count.toDouble());
    }).toList();
  }

  Widget _buildCalendarTab(Color textColor, Color mutedText, ColorScheme scheme) {
    final dailyCounts = _stats['daily_counts'] as Map<String, int>? ?? {};
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate available height and constrain calendar to max 60% of screen
        final maxCalendarHeight = constraints.maxHeight * 0.6;
        
        return Column(
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: maxCalendarHeight,
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    child: ModernCard(
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                        calendarFormat: _calendarFormat,
                        eventLoader: (day) {
                          final dateKey = '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
                          final count = dailyCounts[dateKey] ?? 0;
                          return count > 0 ? [count] : [];
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDate = selectedDay;
                            _focusedDay = focusedDay;
                          });
                          _loadData();
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                            _selectedDate = focusedDay; // Update selected date when navigating months
                          });
                          _loadData(); // Reload data when month changes
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: scheme.primary.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: scheme.primary,
                            shape: BoxShape.circle,
                          ),
                          markerDecoration: BoxDecoration(
                            color: scheme.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: HeaderStyle(
                          formatButtonVisible: true,
                          titleCentered: true,
                          formatButtonShowsNext: false,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildDayDetails(dailyCounts, textColor, mutedText, scheme),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDayDetails(
    Map<String, int> dailyCounts,
    Color textColor,
    Color mutedText,
    ColorScheme scheme,
  ) {
    final dateKey = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final count = dailyCounts[dateKey] ?? 0;
    final dayLogs = _actionLogs.where((log) {
      final logDate = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );
      return isSameDay(logDate, _selectedDate);
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      child: ModernCard(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                      style: AppTheme.heading2(context).copyWith(color: textColor),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      '$count actions',
                      style: AppTheme.bodyMedium(context).copyWith(color: mutedText),
                    ),
                  ],
                ),
              ),
            ),
            if (dayLogs.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spacing32),
                    child: Text(
                      'No actions on this day',
                      style: AppTheme.bodyMedium(context).copyWith(color: mutedText),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final log = dayLogs[index];
                    return ListTile(
                      leading: Icon(
                        Icons.circle,
                        size: 8,
                        color: scheme.primary,
                      ),
                      title: Text(
                        log.description,
                        style: AppTheme.bodyMedium(context).copyWith(color: textColor),
                      ),
                      subtitle: Text(
                        '${log.username ?? 'Unknown'} • ${DateFormat('HH:mm').format(log.timestamp)}',
                        style: AppTheme.bodySmall(context).copyWith(color: mutedText),
                      ),
                    );
                  },
                  childCount: dayLogs.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

