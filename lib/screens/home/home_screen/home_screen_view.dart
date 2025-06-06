import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/home/home_screen/home_screen_state.dart';
import 'package:gizmoglobe_client/widgets/general/app_logo.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

import 'home_screen_cubit.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeScreenCubit, HomeScreenState>(
      builder: (context, state) {
        final currencyFormat =
            NumberFormat.currency(locale: 'en_US', symbol: '\$');
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            title: const AppLogo(height: 60),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Section
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
                      Text(
                        state.username,
                        // 'Test User', // Placeholder for username
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
                // Stats Cards
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        S.of(context).overview,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 1,
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
                            value: currencyFormat.format(state.totalRevenue),
                            color: Colors.orange,
                          ),
                          _buildStatsCard(
                            context,
                            icon: Icons.trending_up_rounded,
                            title: S.of(context).avgIncome,
                            value: currencyFormat.format(state.totalOrders > 0
                                ? state.totalRevenue / state.totalOrders
                                : 0),
                            color: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Sales Chart
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).monthlySales,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              // PopupMenuButton<String>(
                              //   icon: const Icon(Icons.more_vert),
                              //   itemBuilder: (context) => [
                              //     PopupMenuItem(
                              //       value: 'year',
                              //       child: Text(S.of(context).last12Months),
                              //     ),
                              //     PopupMenuItem(
                              //       value: 'quarter',
                              //       child: Text(S.of(context).last3Months),
                              //     ),
                              //   ],
                              // ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 300,
                            child: _buildSalesChart(state.monthlySales),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Category Distribution
                // Padding(
                //   padding: const EdgeInsets.all(16),
                //   child: Column(
                //     children: [
                //       const SizedBox(height: 24),
                //       SizedBox(
                //         height: 300,
                //         child: _buildCategoryDistribution(state.salesByCategory),
                //       ),
                //     ],
                //   ),
                // ),
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

  Widget _buildSalesChart(List<SalesData> sales) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Theme.of(context).colorScheme.surface,
                strokeWidth: 1,
              );
            },
          ),
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
                    String monthLabel;
                    final locale = Localizations.localeOf(context).languageCode;
                    final month = sales[value.toInt()].date.month;
                    if (locale == 'vi') {
                      monthLabel = 'T$month';
                    } else {
                      monthLabel =
                          DateFormat('MMM').format(sales[value.toInt()].date);
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        monthLabel,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    );
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

  // Widget _buildCategoryDistribution(Map<String, double> salesByCategory) {
  //   return SizedBox(
  //     height: 300,
  //     child: Column(
  //       children: [
  //         Expanded(
  //           child: PieChart(
  //             PieChartData(
  //               sectionsSpace: 2,
  //               centerSpaceRadius: 40,
  //               sections: _generatePieChartSections(salesByCategory),
  //             ),
  //           ),
  //         ),
  //         Container(
  //           margin: const EdgeInsets.only(top: 32),
  //           child: Wrap(
  //             spacing: 16,
  //             runSpacing: 8,
  //             alignment: WrapAlignment.center,
  //             children: salesByCategory.entries.map((entry) {
  //               final index = salesByCategory.keys.toList().indexOf(entry.key);
  //               final colors = [
  //                 Colors.blue,
  //                 Colors.green,
  //                 Colors.orange,
  //                 Colors.purple,
  //                 Colors.red,
  //                 Colors.teal,
  //               ];
  //
  //               return Row(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   Container(
  //                     width: 12,
  //                     height: 12,
  //                     decoration: BoxDecoration(
  //                       color: colors[index % colors.length],
  //                       shape: BoxShape.circle,
  //                     ),
  //                   ),
  //                   const SizedBox(width: 8),
  //                   Text(
  //                     entry.key,
  //                     style: Theme.of(context).textTheme.bodyMedium,
  //                   ),
  //                   const SizedBox(width: 4),
  //                   Text(
  //                     NumberFormat.currency(locale: 'en_US', symbol: '\$')
  //                         .format(entry.value),
  //                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                 ],
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // List<PieChartSectionData> _generatePieChartSections(Map<String, double> data) {
  //   final colors = [
  //     Colors.blue,
  //     Colors.green,
  //     Colors.orange,
  //     Colors.purple,
  //     Colors.red,
  //     Colors.teal,
  //   ];
  //
  //   final total = data.values.fold(0.0, (sum, value) => sum + value);
  //
  //   return data.entries.map((entry) {
  //     final index = data.keys.toList().indexOf(entry.key);
  //     final percentage = total > 0 ? (entry.value / total * 100) : 0;
  //
  //     return PieChartSectionData(
  //       color: colors[index % colors.length],
  //       value: entry.value,
  //       title: '${percentage.toStringAsFixed(1)}%',
  //       radius: 100,
  //       titleStyle: const TextStyle(
  //         fontSize: 12,
  //         fontWeight: FontWeight.bold,
  //         color: Colors.white,
  //       ),
  //     );
  //   }).toList();
  // }
  //
  // Widget _buildTopProducts(HomeScreenState state) {
  //   //Implement top products table
  //   return const SizedBox.shrink();
  // }
}
