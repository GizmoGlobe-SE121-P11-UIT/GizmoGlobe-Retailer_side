import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/functions/helper.dart';
import 'package:gizmoglobe_client/screens/home/home_screen/home_screen_state.dart';
import 'package:gizmoglobe_client/widgets/general/app_logo.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/screens/chat/list/chat_list_screen_view.dart';
import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';

import 'home_screen_cubit.dart';
import 'home_screen_webview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => HomeScreenCubit(),
        child: const HomeScreen(),
      );

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  HomeScreenCubit get cubit => context.read<HomeScreenCubit>();

  bool _isMonthlyMode = true; // Toggle between monthly and daily view
  DateTime _selectedMonth = DateTime.now(); // Selected month for daily view
  int _touchedPieIndex = -1; // For pie chart interaction

  @override
  Widget build(BuildContext context) {
    // Web: use web view; Mobile: use regular view
    if (kIsWeb) {
      return HomeScreenWebView.newInstance();
    }

    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: Stack(
              children: [
                const Center(child: AppLogo(height: 60)),
                Row(
                  children: [
                    const Expanded(child: SizedBox()),
                    Stack(
                      children: [
                        IconButton(
                          color: Theme.of(context).colorScheme.primary,
                          icon: const Icon(Icons.chat_rounded),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ChatListScreen.newInstance(),
                              ),
                            );
                          },
                        ),
                        if (state.unreadChats > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                state.unreadChats.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section - always show, uses loading state
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(32)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GradientText(text: S.of(context).welcomeBack),
                      if (state.isLoadingUsername)
                        Container(
                          height: 32,
                          width: 150,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        )
                      else
                        Text(
                          state.username,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                        ),
                    ],
                  ),
                ),

                // Stats Cards - show after username loads
                if (!state.isLoadingUsername)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).overview,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        if (state.isLoadingOverview)
                          // Loading skeleton for stats
                          Column(
                            children: [
                              // Row 1: Products and Customers
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSkeletonCard(context),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildSkeletonCard(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Row 2: Manufacturer and Employees
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildSkeletonCard(context),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildSkeletonCard(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Row 3: Revenue (full width)
                              SizedBox(
                                width: double.infinity,
                                child: _buildSkeletonCard(context),
                              ),
                              const SizedBox(height: 16),
                              // Row 4: Avg. Income (full width)
                              SizedBox(
                                width: double.infinity,
                                child: _buildSkeletonCard(context),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              // Row 1: Products and Customers
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatsCard(
                                      context,
                                      icon: Icons.inventory_2_rounded,
                                      title: S.of(context).products,
                                      value: state.totalProducts.toString(),
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatsCard(
                                      context,
                                      icon: Icons.people_alt_rounded,
                                      title: S.of(context).customers,
                                      value: state.totalCustomers.toString(),
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Row 2: Manufacturer and Employees
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildStatsCard(
                                      context,
                                      icon: Icons.factory_rounded,
                                      title: S.of(context).manufacturer,
                                      value:
                                          state.totalManufacturers.toString(),
                                      color: Colors.teal,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildStatsCard(
                                      context,
                                      icon: Icons.badge_rounded,
                                      title: S.of(context).employees,
                                      value: state.totalEmployees.toString(),
                                      color: Colors.indigo,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Row 3: Revenue (full width)
                              SizedBox(
                                width: double.infinity,
                                child: _buildStatsCard(
                                  context,
                                  icon: Icons.payments_rounded,
                                  title: S.of(context).revenue,
                                  value: Helper.toCurrencyFormat(
                                      state.totalRevenue),
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Row 4: Avg. Income (full width)
                              SizedBox(
                                width: double.infinity,
                                child: _buildStatsCard(
                                  context,
                                  icon: Icons.trending_up_rounded,
                                  title: S.of(context).avgIncome,
                                  value: Helper.toCurrencyFormat(
                                      state.totalOrders > 0
                                          ? state.totalRevenue /
                                              state.totalOrders
                                          : 0),
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                // Optimized Sales Chart - show skeleton when loading, chart when ready
                if (!state.isLoadingUsername)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (state.isLoadingChart)
                              // Chart skeleton
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 24,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ],
                              )
                            else if (state.monthlySales.isNotEmpty ||
                                state.dailySales.isNotEmpty)
                              // Chart content
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Header with toggle buttons
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _isMonthlyMode
                                            ? S.of(context).monthlySales
                                            : S.of(context).dailySales,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      // Toggle buttons
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _buildModeButton(
                                              label: S.of(context).monthly,
                                              isActive: _isMonthlyMode,
                                              onTap: () => setState(
                                                  () => _isMonthlyMode = true),
                                            ),
                                            _buildModeButton(
                                              label: S.of(context).daily,
                                              isActive: !_isMonthlyMode,
                                              onTap: () => setState(
                                                  () => _isMonthlyMode = false),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Month picker for daily mode
                                  if (!_isMonthlyMode) ...[
                                    const SizedBox(height: 16),
                                    _buildMonthPicker(context),
                                  ],
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 200,
                                    child: _buildOptimizedMobileChart(
                                      _isMonthlyMode
                                          ? _filterNonZeroSales(
                                              state.monthlySales, 12)
                                          : _filterDailySalesByMonth(
                                              state.dailySales, _selectedMonth),
                                      isDaily: !_isMonthlyMode,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Category Distribution Pie Chart
                if (!state.isLoadingUsername)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              S.of(context).category,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            if (state.isLoadingProductCounts)
                              Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              )
                            else if (state.productCountsByCategory.isNotEmpty)
                              _buildCategoryPieChart(context, state)
                            else
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Text(
                                    S.of(context).noData,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
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
      },
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Skeleton card for loading state
  Widget _buildSkeletonCard(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 24,
              width: 80,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 16,
              width: 60,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Toggle button for monthly/daily mode
  Widget _buildModeButton({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Filter out zero values and limit to specified count
  List<SalesData> _filterNonZeroSales(List<SalesData> sales, int limit) {
    // Filter out zero values
    final nonZero = sales.where((s) => s.amount > 0).toList();
    // Take last N items (most recent)
    if (nonZero.length > limit) {
      return nonZero.sublist(nonZero.length - limit);
    }
    return nonZero;
  }

  // Filter daily sales by selected month and remove zero values
  List<SalesData> _filterDailySalesByMonth(
      List<SalesData> dailySales, DateTime selectedMonth) {
    final filtered = dailySales.where((s) {
      return s.date.year == selectedMonth.year &&
          s.date.month == selectedMonth.month &&
          s.amount > 0;
    }).toList();
    // Sort by date to ensure chronological order
    filtered.sort((a, b) => a.date.compareTo(b.date));
    return filtered;
  }

  // Month picker widget for daily mode
  Widget _buildMonthPicker(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    String monthLabel;
    if (locale == 'vi') {
      monthLabel =
          '${S.of(context).month} ${_selectedMonth.month}/${_selectedMonth.year}';
    } else {
      monthLabel = DateFormat('MMMM yyyy').format(_selectedMonth);
    }

    return GestureDetector(
      onTap: () async {
        await _showMonthYearPicker(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              monthLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_drop_down_rounded,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }

  // Show month/year picker dialog
  Future<void> _showMonthYearPicker(BuildContext context) async {
    final locale = Localizations.localeOf(context).languageCode;
    int selectedYear = _selectedMonth.year;
    int selectedMonth = _selectedMonth.month;

    final now = DateTime.now();
    final years = List.generate(now.year - 2019, (i) => now.year - i);
    final months = List.generate(12, (i) => i + 1);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(S.of(context).selectMonth),
              content: SizedBox(
                width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Month dropdown
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).month,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            value: selectedMonth,
                            isExpanded: true,
                            items: months.map((month) {
                              String monthName;
                              if (locale == 'vi') {
                                monthName = '${S.of(context).month} $month';
                              } else {
                                monthName = DateFormat('MMMM')
                                    .format(DateTime(2024, month));
                              }
                              return DropdownMenuItem<int>(
                                value: month,
                                child: Text(monthName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedMonth = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Year dropdown
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).year,
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const SizedBox(height: 8),
                          DropdownButton<int>(
                            value: selectedYear,
                            isExpanded: true,
                            items: years.map((year) {
                              return DropdownMenuItem<int>(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  selectedYear = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(S.of(context).cancel),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedMonth = DateTime(selectedYear, selectedMonth, 1);
                    });
                    Navigator.of(context).pop();
                  },
                  child: Text(S.of(context).select),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Optimized bar chart for mobile - uses less memory than LineChart with gradients
  Widget _buildOptimizedMobileChart(List<SalesData> sales,
      {bool isDaily = false}) {
    if (sales.isEmpty) return const SizedBox.shrink();

    // Find max value for scaling
    final maxAmount =
        sales.map((s) => s.amount).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxAmount * 1.1, // Add 10% padding at top
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = sales[group.x.toInt()].date;
              final locale = Localizations.localeOf(context).languageCode;
              String dateLabel;
              if (isDaily) {
                dateLabel = locale == 'vi'
                    ? '${date.day}/${date.month}'
                    : DateFormat('d/M').format(date);
              } else {
                dateLabel = locale == 'vi'
                    ? 'T${date.month}'
                    : DateFormat('MMM').format(date);
              }
              return BarTooltipItem(
                '$dateLabel\n${Helper.toCurrencyFormat(rod.toY / 1000)}',
                TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 && value.toInt() < sales.length) {
                  final date = sales[value.toInt()].date;
                  final locale = Localizations.localeOf(context).languageCode;
                  String dateLabel;
                  if (isDaily) {
                    dateLabel = locale == 'vi'
                        ? '${date.day}/${date.month}'
                        : DateFormat('d/M').format(date);
                  } else {
                    dateLabel = locale == 'vi'
                        ? 'T${date.month}'
                        : DateFormat('MMM').format(date);
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      dateLabel,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: isDaily ? 9 : 11,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
              reservedSize: 30,
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: sales.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.amount,
                color: Theme.of(context).colorScheme.primary,
                width: 20,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
      // Disable animations for better performance
      swapAnimationDuration: Duration.zero,
    );
  }

  // Get category icon
  IconData _getCategoryIcon(String category) {
    try {
      final categoryEnum = CategoryEnumExtension.fromName(category);
      switch (categoryEnum) {
        case CategoryEnum.ram:
          return Icons.memory;
        case CategoryEnum.cpu:
          return Icons.computer;
        case CategoryEnum.psu:
          return Icons.power;
        case CategoryEnum.gpu:
          return Icons.videogame_asset;
        case CategoryEnum.drive:
          return Icons.storage;
        case CategoryEnum.mainboard:
          return Icons.developer_board;
        default:
          return Icons.device_unknown;
      }
    } catch (e) {
      return Icons.device_unknown;
    }
  }

  // Get category display name from CategoryEnum
  String _getCategoryDisplayName(String category) {
    try {
      final categoryEnum =
          CategoryEnumExtension.fromName(category.toLowerCase());
      if (categoryEnum != CategoryEnum.empty) {
        return categoryEnum.description;
      }
      // Fallback: capitalize first letter
      return category.isNotEmpty
          ? category[0].toUpperCase() + category.substring(1).toLowerCase()
          : category;
    } catch (e) {
      // Fallback: capitalize first letter
      return category.isNotEmpty
          ? category[0].toUpperCase() + category.substring(1).toLowerCase()
          : category;
    }
  }

  // Category distribution pie chart
  Widget _buildCategoryPieChart(BuildContext context, HomeScreenState state) {
    final categoryCounts = state.productCountsByCategory;
    if (categoryCounts.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate total for percentage
    final total =
        categoryCounts.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) {
      return const SizedBox.shrink();
    }

    // Sort categories by count (descending) and take top categories
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Generate colors for categories
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.red,
      Colors.amber,
      Colors.cyan,
      Colors.pink,
    ];

    return Column(
      children: [
        // Pie Chart
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      _touchedPieIndex = -1;
                      return;
                    }
                    _touchedPieIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: List.generate(sortedCategories.length, (i) {
                final entry = sortedCategories[i];
                final category = entry.key;
                final count = entry.value;
                final percentage = (count / total * 100);
                final isTouched = i == _touchedPieIndex;
                final fontSize = isTouched ? 18.0 : 14.0;
                final radius = isTouched ? 95.0 : 85.0;
                final widgetSize = isTouched ? 50.0 : 36.0;
                const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
                final color = colors[i % colors.length];

                return PieChartSectionData(
                  color: color,
                  value: count.toDouble(),
                  title: percentage >= 5
                      ? '${percentage.toStringAsFixed(1)}%'
                      : '',
                  radius: radius,
                  titleStyle: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xffffffff),
                    shadows: shadows,
                  ),
                  badgeWidget: _CategoryBadge(
                    icon: _getCategoryIcon(category),
                    size: widgetSize,
                    borderColor: Theme.of(context).colorScheme.outline,
                  ),
                  badgePositionPercentageOffset: .98,
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 32),
        // Legend - Grid layout for better organization
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 2,
          ),
          itemCount: sortedCategories.length,
          itemBuilder: (context, i) {
            final entry = sortedCategories[i];
            final category = entry.key;
            final count = entry.value;
            final percentage = (count / total * 100);
            final color = colors[i % colors.length];
            final isTouched = i == _touchedPieIndex;
            final displayName = _getCategoryDisplayName(category);

            return InkWell(
              onTap: () {
                setState(() {
                  _touchedPieIndex = _touchedPieIndex == i ? -1 : i;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                decoration: BoxDecoration(
                  color: isTouched
                      ? color.withValues(alpha: 0.15)
                      : Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isTouched
                        ? color
                        : Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                    width: isTouched ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Color indicator
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Category icon
                    Icon(
                      _getCategoryIcon(category),
                      size: 18,
                      color: isTouched
                          ? color
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                    const SizedBox(width: 6),
                    // Category name and stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 16, // Fixed height to prevent overflow
                            child: Text(
                              displayName,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: isTouched
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    fontSize: 12,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 3),
                          SizedBox(
                            height: 14, // Fixed height to prevent overflow
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    '$count',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          fontSize: 9,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 3, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: color.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      '${percentage.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Badge widget for category icon
class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({
    required this.icon,
    required this.size,
    required this.borderColor,
  });

  final IconData icon;
  final double size;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: .5),
            offset: const Offset(3, 3),
            blurRadius: 3,
          ),
        ],
      ),
      padding: EdgeInsets.all(size * .15),
      child: Center(
        child: Icon(
          icon,
          size: size * 0.5,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
