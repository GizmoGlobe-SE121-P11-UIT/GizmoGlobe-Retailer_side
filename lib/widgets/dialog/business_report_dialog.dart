import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/screens/home/home_screen/home_screen_cubit.dart';
import 'package:gizmoglobe_client/services/reports/business_report_pdf_service.dart';
import 'package:printing/printing.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

enum ReportPeriod {
  today,
  thisWeek,
  thisMonth,
  thisYear,
  custom,
}

class BusinessReportDialog extends StatefulWidget {
  final HomeScreenCubit cubit;

  const BusinessReportDialog({super.key, required this.cubit});

  static Future<void> show(BuildContext context, HomeScreenCubit cubit) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (dialogContext) => BusinessReportDialog(cubit: cubit),
    );
  }

  @override
  State<BusinessReportDialog> createState() => _BusinessReportDialogState();
}

class _BusinessReportDialogState extends State<BusinessReportDialog> {
  ReportPeriod _selectedPeriod = ReportPeriod.thisMonth;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _updateDatesForPeriod(_selectedPeriod);
  }

  void _updateDatesForPeriod(ReportPeriod period) {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (period) {
      case ReportPeriod.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case ReportPeriod.thisWeek:
        final weekday = now.weekday;
        start = now.subtract(Duration(days: weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case ReportPeriod.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case ReportPeriod.thisYear:
        start = DateTime(now.year, 1, 1);
        break;
      case ReportPeriod.custom:
        // Keep existing dates or set to current month if null
        if (_startDate == null || _endDate == null) {
          start = DateTime(now.year, now.month, 1);
          end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        } else {
          return; // Don't update if custom and dates are already set
        }
        break;
    }

    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = DateTime(picked.year, picked.month, picked.day);
        if (_endDate != null && _startDate!.isAfter(_endDate!)) {
          _endDate =
              DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  void _handlePeriodChange(ReportPeriod? period) {
    if (period == null) return;
    setState(() {
      _selectedPeriod = period;
    });
    _updateDatesForPeriod(period);
  }

  Future<void> _handleCreateReport() async {
    final localizations = S.of(context);

    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.pleaseSelectValidDateRange),
        ),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      // Generate report data
      final reportData = await widget.cubit.generateBusinessReportData(
        startDate: _startDate!,
        endDate: _endDate!,
      );

      // Prepare localizations map for PDF
      final localizationsMap = {
        'businessReport': localizations.businessReport,
        'reportPeriod': localizations.reportPeriod,
        'executiveSummary': localizations.executiveSummary,
        'totalRevenue': localizations.totalRevenue,
        'totalCosts': localizations.totalCosts,
        'grossProfit': localizations.grossProfit,
        'profitMargin': localizations.profitMargin,
        'totalOrders': localizations.totalOrders,
        'averageOrderValue': localizations.averageOrderValue,
        'financialOverview': localizations.financialOverview,
        'revenueMetrics': localizations.revenueMetrics,
        'costMetrics': localizations.costMetrics,
        'salesAnalysis': localizations.salesAnalysis,
        'totalProducts': localizations.totalProducts,
        'totalCustomers': localizations.totalCustomers,
        'totalSalesInvoices': localizations.totalSalesInvoices,
        'totalIncomingInvoices': localizations.totalIncomingInvoices,
        'topProducts': localizations.topProducts,
        'productName': localizations.productName,
        'productId': localizations.productId,
        'quantitySold': localizations.quantitySold,
        'revenue': localizations.revenue,
        'salesByCategory': localizations.salesByCategory,
        'category': localizations.category,
        'revenueBreakdown': localizations.revenueBreakdown,
        'revenueByCategory': localizations.revenueByCategory,
        'monthlyRevenue': localizations.monthlyRevenue,
        'costBreakdown': localizations.costBreakdown,
        'costOfGoodsSold': localizations.costOfGoodsSold,
        'operatingExpenses': localizations.operatingExpenses,
        'customerInsights': localizations.customerInsights,
        'newCustomers': localizations.newCustomers,
        'returningCustomers': localizations.returningCustomers,
        'customerRetentionRate': localizations.customerRetentionRate,
        'topCustomersBySpending': localizations.topCustomersBySpending,
        'orders': localizations.orders,
        'totalSpending': localizations.totalSpending,
        'bestSellingProducts': localizations.bestSellingProducts,
        'topProductsByQuantity': localizations.topProductsByQuantity,
        'inventoryInsights': localizations.inventoryInsights,
        'totalStockValue': localizations.totalStockValue,
        'lowStockItems': localizations.lowStockItems,
        'currentStock': localizations.currentStock,
        'inventoryTurnoverRate': localizations.inventoryTurnoverRate,
        'salesTrends': localizations.salesTrends,
        'monthlySalesTrend': localizations.monthlySalesTrend,
        'month': localizations.month,
        'costs': localizations.costs,
        'profit': localizations.profit,
        'businessKPIs': localizations.businessKPIs,
        'averageItemsPerOrder': localizations.averageItemsPerOrder,
        'totalItemsSold': localizations.totalItemsSold,
        'conclusionInsights': localizations.conclusionInsights,
        'noSpecificInsights': localizations.noSpecificInsights,
        'strongProfitMargin': localizations.strongProfitMargin,
        'lowProfitMargin': localizations.lowProfitMargin,
        'goodCustomerRetention': localizations.goodCustomerRetention,
        'improveCustomerRetention': localizations.improveCustomerRetention,
        'lowStockAlert':
            localizations.lowStockAlert(reportData.lowStockItemsCount),
        'consistentRevenue':
            localizations.consistentRevenueWithOrders(reportData.totalOrders),
        'reportGeneratedBy': localizations.reportGeneratedBy,
        'generatedOn': localizations.generatedOn,
        'customer': localizations.customer,
        'quantity': localizations.quantity,
      };

      // Generate PDF
      final pdfDoc = await BusinessReportPdfService.generatePdf(
        reportData: reportData,
        localizations: localizationsMap,
      );

      // Download PDF
      final dateFormat = DateFormat('yyyyMMdd');
      final fileName =
          'Business_Report_${dateFormat.format(_startDate!)}_${dateFormat.format(_endDate!)}.pdf';
      await Printing.sharePdf(
        bytes: await pdfDoc.save(),
        filename: fileName,
      );

      // Close dialog on success
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.reportGeneratedSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
        showDialog(
          context: context,
          builder: (context) => InformationDialog(
            title: localizations.errorOccurred,
            content: '${localizations.errorGeneratingReport}: $e',
            buttonText: localizations.confirm,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Dialog(
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assessment,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  S.of(context).businessReport,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed:
                      _isGenerating ? null : () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              S.of(context).selectReportPeriod,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<ReportPeriod>(
              value: _selectedPeriod,
              decoration: InputDecoration(
                labelText: S.of(context).period,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: [
                DropdownMenuItem(
                  value: ReportPeriod.today,
                  child: Text(S.of(context).today),
                ),
                DropdownMenuItem(
                  value: ReportPeriod.thisWeek,
                  child: Text(S.of(context).thisWeek),
                ),
                DropdownMenuItem(
                  value: ReportPeriod.thisMonth,
                  child: Text(S.of(context).thisMonth),
                ),
                DropdownMenuItem(
                  value: ReportPeriod.thisYear,
                  child: Text(S.of(context).thisYear),
                ),
                DropdownMenuItem(
                  value: ReportPeriod.custom,
                  child: Text(S.of(context).custom),
                ),
              ],
              onChanged: _isGenerating ? null : _handlePeriodChange,
            ),
            const SizedBox(height: 24),
            if (_selectedPeriod == ReportPeriod.custom) ...[
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).startDate,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _isGenerating ? null : _selectStartDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _startDate != null
                                      ? dateFormat.format(_startDate!)
                                      : S.of(context).selectStartDate,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context).endDate,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: _isGenerating ? null : _selectEndDate,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _endDate != null
                                      ? dateFormat.format(_endDate!)
                                      : S.of(context).selectEndDate,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                Icon(
                                  Icons.calendar_today,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).selectedPeriod,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _startDate != null && _endDate != null
                                ? '${dateFormat.format(_startDate!)} - ${dateFormat.format(_endDate!)}'
                                : 'N/A',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            if (_isGenerating) ...[
              Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      S.of(context).generatingReport,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      S.of(context).thisMayTakeFewMoments,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(S.of(context).cancel),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _handleCreateReport,
                    child: Text(S.of(context).createReport),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
