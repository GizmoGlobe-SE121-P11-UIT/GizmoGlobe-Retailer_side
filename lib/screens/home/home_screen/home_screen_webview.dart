import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/home/home_screen/home_screen_state.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/functions/helper.dart';

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

  String _selectedChartInterval = '';
  int? _selectedYear;
  int? _selectedMonth;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_selectedChartInterval.isEmpty) {
      _selectedChartInterval = S.of(context).yearMonthly;
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        final allSales = state.monthlySales;
        final now = DateTime.now();
        _selectedYear ??= now.year;
        _selectedMonth ??= now.month;
        List<SalesData> displaySales;
        String chartTitle;
        if (_selectedChartInterval == S.of(context).monthDaily) {
          // Build 30/31/28/29 days blank list for full x-axis then fill in with sales data if present
          final daysInMonth =
              DateUtils.getDaysInMonth(_selectedYear!, _selectedMonth!);
          List<double> dayAmounts = List.filled(daysInMonth, 0.0);
          for (final s in allSales.where((s) =>
              s.date.year == _selectedYear && s.date.month == _selectedMonth)) {
            final day = s.date.day;
            dayAmounts[day - 1] = s.amount;
          }
          displaySales = List.generate(
              daysInMonth,
              (i) => SalesData(DateTime(_selectedYear!, _selectedMonth!, i + 1),
                  dayAmounts[i]));
          chartTitle =
              '${S.of(context).monthlySales} ($_selectedYear-${_selectedMonth.toString().padLeft(2, '0')})';
        } else {
          // Aggregate sales for each month in the year
          Map<int, double> monthSums = {};
          for (var m = 1; m <= 12; ++m) {
            monthSums[m] = 0;
          }
          for (final s in allSales.where((s) => s.date.year == _selectedYear)) {
            monthSums[s.date.month] = (monthSums[s.date.month] ?? 0) + s.amount;
          }
          displaySales = List.generate(
              12,
              (i) => SalesData(
                  DateTime(_selectedYear!, i + 1), monthSums[i + 1]!));
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GradientText(text: S.of(context).welcomeBack),
                        const SizedBox(height: 8),
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

                  const SizedBox(height: 32),
                  // Stats Overview
                  Text(
                    S.of(context).overview,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 1.2,
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
                        icon: Icons.payments_rounded,
                        title: S.of(context).revenue,
                        value: Helper.toCurrencyFormat(state.totalRevenue),
                        color: Colors.orange,
                      ),
                      _buildStatsCard(
                        context,
                        icon: Icons.trending_up_rounded,
                        title: S.of(context).avgIncome,
                        value: Helper.toCurrencyFormat(state.totalOrders > 0
                            ? state.totalRevenue / state.totalOrders
                            : 0),
                        color: Colors.purple,
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
                                value: _selectedChartInterval,
                                items: [
                                  DropdownMenuItem(
                                      value: S.of(context).yearMonthly,
                                      child: Text(S.of(context).yearMonthly)),
                                  DropdownMenuItem(
                                      value: S.of(context).monthDaily,
                                      child: Text(S.of(context).monthDaily)),
                                ],
                                onChanged: (val) {
                                  setState(() {
                                    _selectedChartInterval =
                                        val ?? S.of(context).yearMonthly;
                                  });
                                },
                              ),
                              if (_selectedChartInterval ==
                                  S.of(context).yearMonthly) ...[
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
                            height: 300,
                            child: _OptimizedSalesChartWidget(
                                sales: displaySales,
                                isMonthly: _selectedChartInterval ==
                                    S.of(context).yearMonthly),
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
}

class _OptimizedSalesChartWidget extends StatelessWidget {
  final List<SalesData> sales;
  final bool isMonthly;
  const _OptimizedSalesChartWidget(
      {required this.sales, this.isMonthly = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: LineChart(
        LineChartData(
          gridData:
              const FlGridData(show: false), // Hide all grid for performance
          titlesData: FlTitlesData(
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 && value.toInt() < sales.length) {
                    final SalesData s = sales[value.toInt()];
                    if (isMonthly) {
                      final label = DateFormat('MMM').format(s.date);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          label,
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      );
                    } else {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${s.date.day}',
                          style:
                              const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      );
                    }
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: sales.asMap().entries.map((entry) {
                return FlSpot(entry.key.toDouble(), entry.value.amount);
              }).toList(),
              isCurved: true,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                ],
              ),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.2),
                    Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
