import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/home/home_screen/home_screen_state.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/functions/helper.dart';
import 'package:gizmoglobe_client/widgets/dialog/business_report_dialog.dart';
import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';

import 'home_screen_cubit.dart';

class HomeScreenWebView extends StatefulWidget {
  const HomeScreenWebView({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => HomeScreenCubit(),
        child: const HomeScreenWebView(),
      );

  @override
  State<HomeScreenWebView> createState() => _HomeScreenWebViewState();
}

class _HomeScreenWebViewState extends State<HomeScreenWebView> {
  HomeScreenCubit get cubit => context.read<HomeScreenCubit>();

  String _selectedChartInterval =
      'yearMonthly'; // Use constant key instead of localized string
  int? _selectedYear;
  int? _selectedMonth;
  int _touchedPieIndex = -1; // For pie chart interaction

  @override
  void initState() {
    super.initState();
  }

  Future<void> _showYearPicker(BuildContext context) async {
    final now = DateTime.now();
    const int firstYear = 2000;
    final picked = await showDialog<int>(
      context: context,
      builder: (context) {
        return Dialog(
          child: SizedBox(
            width: 300,
            height: 400,
            child: YearPicker(
              firstDate: DateTime(firstYear),
              lastDate: DateTime(now.year),
              selectedDate: DateTime(_selectedYear ?? now.year),
              onChanged: (date) {
                Navigator.of(context).pop(date.year);
              },
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedYear = picked;
      });
    }
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final picked = await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(S.of(context).selectMonth),
          children: List<Widget>.generate(12, (index) {
            return SimpleDialogOption(
              child: Text(DateFormat.MMMM().format(DateTime(0, index + 1))),
              onPressed: () {
                Navigator.of(context).pop(index + 1);
              },
            );
          }),
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  Future<void> _handleGenerateReport() async {
    await BusinessReportDialog.show(context, cubit);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        final monthlyCategorySalesData = state.monthlyCategorySales;
        final dailyCategorySalesData = state.dailyCategorySales;
        final now = DateTime.now();
        _selectedYear ??= now.year;
        _selectedMonth ??= now.month;
        List<CategorySalesData> displayCategorySales;
        String chartTitle;
        bool isDaily = false;

        if (_selectedChartInterval == 'monthDaily') {
          // Daily mode: filter dailyCategorySales for selected year and month
          isDaily = true;
          final daysInMonth =
              DateUtils.getDaysInMonth(_selectedYear!, _selectedMonth!);
          displayCategorySales = [];

          // Create a map for all days in the month
          final Map<int, Map<String, double>> dayCategoryMap = {};
          for (int day = 1; day <= daysInMonth; day++) {
            dayCategoryMap[day] = {};
          }

          // Fill in actual data
          for (final s in dailyCategorySalesData.where((s) =>
              s.date.year == _selectedYear && s.date.month == _selectedMonth)) {
            final day = s.date.day;
            if (day >= 1 && day <= daysInMonth) {
              dayCategoryMap[day] = Map<String, double>.from(s.categoryAmounts);
            }
          }

          // Convert to CategorySalesData list
          displayCategorySales = List.generate(
              daysInMonth,
              (i) => CategorySalesData(
                  DateTime(_selectedYear!, _selectedMonth!, i + 1),
                  dayCategoryMap[i + 1] ?? {}));
          chartTitle =
              '${S.of(context).monthlySales} ($_selectedYear-${_selectedMonth.toString().padLeft(2, '0')})';
        } else {
          // Monthly mode: filter monthlyCategorySales for selected year
          isDaily = false;
          final Map<int, Map<String, double>> monthCategoryMap = {};
          for (var m = 1; m <= 12; ++m) {
            monthCategoryMap[m] = {};
          }

          for (final s in monthlyCategorySalesData
              .where((s) => s.date.year == _selectedYear)) {
            monthCategoryMap[s.date.month] =
                Map<String, double>.from(s.categoryAmounts);
          }

          displayCategorySales = List.generate(
              12,
              (i) => CategorySalesData(DateTime(_selectedYear!, i + 1),
                  monthCategoryMap[i + 1] ?? {}));
          chartTitle = '${S.of(context).monthlySales} ($_selectedYear)';
        }
        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GradientText(text: S.of(context).welcomeBack),
                              const SizedBox(height: 8),
                              state.isLoadingUsername
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      state.username,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                    ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.assessment),
                          tooltip: S.of(context).generateBusinessReport,
                          onPressed: _handleGenerateReport,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  // Stats Overview
                  Text(
                    S.of(context).overview,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  state.isLoadingOverview
                      ? Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        )
                      : Column(
                          children: [
                            // Row 1: Products, Customers, Orders, Manufacturers, Employees (5 tiles)
                            GridView.count(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisCount: 5,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 1.3,
                              children: [
                                _buildStatsCard(
                                  context,
                                  icon: Icons.inventory_2_rounded,
                                  title: S.of(context).products,
                                  value: state.totalProducts.toString(),
                                  color: Colors.blue,
                                ),
                                _buildStatsCard(
                                  context,
                                  icon: Icons.people_alt_rounded,
                                  title: S.of(context).customers,
                                  value: state.totalCustomers.toString(),
                                  color: Colors.green,
                                ),
                                _buildStatsCard(
                                  context,
                                  icon: Icons.receipt_long_rounded,
                                  title: S.of(context).orders,
                                  value: state.totalOrders.toString(),
                                  color: Colors.amber,
                                ),
                                _buildStatsCard(
                                  context,
                                  icon: Icons.factory_rounded,
                                  title: S.of(context).manufacturer,
                                  value: state.totalManufacturers.toString(),
                                  color: Colors.teal,
                                ),
                                _buildStatsCard(
                                  context,
                                  icon: Icons.badge_rounded,
                                  title: S.of(context).employees,
                                  value: state.totalEmployees.toString(),
                                  color: Colors.indigo,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Row 2: Revenue and Avg Income (2 tiles, span equally)
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatsCard(
                                    context,
                                    icon: Icons.payments_rounded,
                                    title: S.of(context).revenue,
                                    value: Helper.toCurrencyFormat(
                                        state.totalRevenue),
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
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

                  const SizedBox(height: 32),
                  // Sales Chart
                  Card(
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
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                chartTitle,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 32),
                              DropdownButton<String>(
                                value: _selectedChartInterval.isNotEmpty &&
                                        (_selectedChartInterval ==
                                                'yearMonthly' ||
                                            _selectedChartInterval ==
                                                'monthDaily')
                                    ? _selectedChartInterval
                                    : 'yearMonthly',
                                items: [
                                  DropdownMenuItem(
                                      value: 'yearMonthly',
                                      child: Text(S.of(context).yearMonthly)),
                                  DropdownMenuItem(
                                      value: 'monthDaily',
                                      child: Text(S.of(context).monthDaily)),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedChartInterval = val;
                                    });
                                  }
                                },
                              ),
                              if (_selectedChartInterval == 'yearMonthly') ...[
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () => _showYearPicker(context),
                                  child: Text(S.of(context).chooseYear),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text('${_selectedYear ?? now.year}'),
                                ),
                              ] else ...[
                                const SizedBox(width: 12),
                                ElevatedButton(
                                  onPressed: () async {
                                    await _showYearPicker(context);
                                    await _showMonthPicker(context);
                                  },
                                  child: Text(S.of(context).chooseMonth),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(_selectedYear != null &&
                                          _selectedMonth != null
                                      ? '${_selectedYear!}-${_selectedMonth!.toString().padLeft(2, '0')}'
                                      : ''),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            height: 400,
                            child: state.isLoadingChart
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Line chart - 60% width
                                      Expanded(
                                        flex: 6,
                                        child: _buildCategoryLineChart(context,
                                            displayCategorySales, isDaily),
                                      ),
                                      const SizedBox(width: 24),
                                      // Pie chart - 40% width
                                      Expanded(
                                        flex: 4,
                                        child: state.isLoadingProductCounts
                                            ? const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              )
                                            : _buildCategoryPieChart(
                                                context, state),
                                      ),
                                    ],
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
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

  // Get consistent color for a category across all charts
  Color _getCategoryColor(String category) {
    try {
      final categoryEnum =
          CategoryEnumExtension.fromName(category.toLowerCase());
      switch (categoryEnum) {
        case CategoryEnum.ram:
          return Colors.blue;
        case CategoryEnum.cpu:
          return Colors.green;
        case CategoryEnum.psu:
          return Colors.orange;
        case CategoryEnum.gpu:
          return Colors.purple;
        case CategoryEnum.drive:
          return Colors.teal;
        case CategoryEnum.mainboard:
          return Colors.indigo;
        default:
          return Colors.grey;
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  // Category distribution pie chart
  Widget _buildCategoryPieChart(BuildContext context, HomeScreenState state) {
    final categoryCounts = state.productCountsByCategory;
    if (categoryCounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 48,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).noData,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    // Calculate total for percentage
    final total =
        categoryCounts.values.fold<int>(0, (sum, count) => sum + count);
    if (total == 0) {
      return const SizedBox.shrink();
    }

    // Sort categories by count (descending)
    final sortedCategories = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // No longer needed - colors are now determined by category

    return Column(
      children: [
        // Title
        Text(
          'Product Category Distribution',
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Pie Chart
        Expanded(
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
              centerSpaceRadius: 30,
              sections: List.generate(sortedCategories.length, (i) {
                final entry = sortedCategories[i];
                final category = entry.key;
                final count = entry.value;
                final percentage = (count / total * 100);
                final isTouched = i == _touchedPieIndex;
                final fontSize = isTouched ? 14.0 : 12.0;
                final radius = isTouched ? 70.0 : 60.0;
                final widgetSize = isTouched ? 40.0 : 30.0;
                const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
                final color = _getCategoryColor(category);

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
        const SizedBox(height: 16),
        // Legend - 2-column grid layout
        Expanded(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 6,
              childAspectRatio: 5,
            ),
            itemCount: sortedCategories.length,
            itemBuilder: (context, i) {
              final entry = sortedCategories[i];
              final category = entry.key;
              final count = entry.value;
              final color = _getCategoryColor(category);
              final isTouched = i == _touchedPieIndex;
              final displayName = _getCategoryDisplayName(category);

              return InkWell(
                onTap: () {
                  setState(() {
                    _touchedPieIndex = _touchedPieIndex == i ? -1 : i;
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isTouched
                        ? color.withValues(alpha: 0.15)
                        : Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest
                            .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
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
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Category name
                      Expanded(
                        child: Text(
                          displayName,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: isTouched
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 11,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Count
                      Text(
                        '$count',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Multi-line chart for category sales
  Widget _buildCategoryLineChart(
    BuildContext context,
    List<CategorySalesData> categorySales,
    bool isDaily,
  ) {
    if (categorySales.isEmpty) {
      return Center(
        child: Text(
          S.of(context).noData,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    // Collect all unique categories
    final Set<String> allCategories = {};
    for (var data in categorySales) {
      allCategories.addAll(data.categoryAmounts.keys);
    }

    if (allCategories.isEmpty) {
      return Center(
        child: Text(
          S.of(context).noData,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    // No longer needed - colors are now determined by category

    final categoryList = allCategories.toList();
    final maxX = (categorySales.length - 1).toDouble();

    // Find max value for scaling
    double maxY = 0;
    for (var data in categorySales) {
      for (var amount in data.categoryAmounts.values) {
        if (amount > maxY) maxY = amount;
      }
    }
    maxY = maxY * 1.1; // Add 10% padding

    // Build line chart bars data for each category
    final lineBarsData = <LineChartBarData>[];
    for (int i = 0; i < categoryList.length; i++) {
      final category = categoryList[i];
      final color = _getCategoryColor(category);

      final spots = <FlSpot>[];
      for (int j = 0; j < categorySales.length; j++) {
        final amount = categorySales[j].categoryAmounts[category] ?? 0.0;
        spots.add(FlSpot(j.toDouble(), amount));
      }

      lineBarsData.add(
        LineChartBarData(
          isCurved: true,
          color: color,
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
          spots: spots,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(right: 16, left: 6),
      child: LineChart(
        LineChartData(
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                if (touchedSpots.isEmpty) return [];

                // Get date from first spot (all spots have same date)
                final date = categorySales[touchedSpots.first.x.toInt()].date;
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

                // Build tooltip content with date header and all unique categories
                // Use TextSpan children to create rich text with different colors
                final children = <TextSpan>[];

                // Date header (only once)
                children.add(
                  TextSpan(
                    text: '$dateLabel\n',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                );

                // Collect unique categories with their data (avoid duplicates)
                final categoryDataMap = <String, Map<String, dynamic>>{};
                for (final spot in touchedSpots) {
                  // Add bounds check to prevent index out of range error
                  if (spot.barIndex >= 0 &&
                      spot.barIndex < categoryList.length) {
                    final category = categoryList[spot.barIndex];
                    if (!categoryDataMap.containsKey(category)) {
                      categoryDataMap[category] = {
                        'displayName': _getCategoryDisplayName(category),
                        'price': spot.y,
                        'color': _getCategoryColor(category),
                      };
                    }
                  }
                }

                // Sort categories by price (descending) for better display
                final sortedCategories = categoryDataMap.entries.toList()
                  ..sort(
                      (a, b) => b.value['price'].compareTo(a.value['price']));

                // Add category items (each category only once)
                for (int i = 0; i < sortedCategories.length; i++) {
                  final entry = sortedCategories[i];
                  final displayName = entry.value['displayName'] as String;
                  // Divide by 1000 because toCurrencyFormat multiplies by 1000,
                  // and the data is already in full VND (multiplied by 1000 in cubit)
                  final price = Helper.toCurrencyFormat(
                      (entry.value['price'] as double) / 1000);
                  final color = entry.value['color'] as Color;

                  if (i > 0) {
                    children.add(const TextSpan(text: '\n'));
                  }

                  children.add(
                    TextSpan(
                      text: '$displayName $price',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  );
                }

                // Return one tooltip item per touched spot
                // First item shows full content, others show empty to avoid duplication
                return touchedSpots.asMap().entries.map((entry) {
                  final index = entry.key;

                  // Only the first item shows the full content
                  if (index == 0) {
                    return LineTooltipItem(
                      '',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      children: children,
                    );
                  } else {
                    // Other items are empty (they won't be displayed separately)
                    return const LineTooltipItem(
                      '',
                      TextStyle(
                        color: Colors.transparent,
                        fontSize: 0,
                      ),
                    );
                  }
                }).toList();
              },
            ),
          ),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: isDaily ? 5 : 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < categorySales.length) {
                    final date = categorySales[value.toInt()].date;
                    final locale = Localizations.localeOf(context).languageCode;
                    String text;
                    if (isDaily) {
                      text = locale == 'vi'
                          ? '${date.day}/${date.month}'
                          : DateFormat('d/M').format(date);
                    } else {
                      text = locale == 'vi'
                          ? 'T${date.month}'
                          : DateFormat('MMM').format(date);
                    }
                    return Text(
                      text,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                interval: maxY / 5,
                getTitlesWidget: (double value, TitleMeta meta) {
                  final displayValue = (value / 1000).roundToDouble();
                  final formatted = Helper.toMoneyFormat(displayValue);
                  return Text(
                    formatted,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.2),
                width: 2,
              ),
              left: const BorderSide(color: Colors.transparent),
              right: const BorderSide(color: Colors.transparent),
              top: const BorderSide(color: Colors.transparent),
            ),
          ),
          minX: 0,
          maxX: maxX,
          minY: 0,
          maxY: maxY,
          lineBarsData: lineBarsData,
        ),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }
}

// Category badge widget for pie chart
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
