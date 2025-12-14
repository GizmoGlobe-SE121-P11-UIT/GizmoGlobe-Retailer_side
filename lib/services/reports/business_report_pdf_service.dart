import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice.dart';
import 'package:gizmoglobe_client/functions/helper.dart';
import 'package:flutter/services.dart' show rootBundle;

class BusinessReportData {
  final DateTime startDate;
  final DateTime endDate;
  final double totalRevenue;
  final double totalCosts;
  final int totalOrders;
  final int totalProducts;
  final int totalCustomers;
  final Map<String, double> salesByCategory;
  final List<BusinessReportTopProductData> topProducts;
  final List<SalesInvoice> salesInvoices;
  final List<IncomingInvoice> incomingInvoices;
  final String username;
  final String selectedCategoryLabel;

  // Revenue breakdown
  final Map<String, double> revenueByDay;
  final Map<String, double> revenueByWeek;
  final Map<String, double> revenueByMonth;

  // Cost breakdown
  final double costOfGoodsSold; // COGS from incoming invoices
  final double
      operatingExpenses; // Can be calculated or set to 0 if not tracked

  // Customer insights
  final int newCustomers;
  final int returningCustomers;
  final double customerRetentionRate;
  final List<CustomerSpendingData> topCustomers;

  // Product insights
  final List<BusinessReportTopProductData> topProductsByQuantity;
  final List<BusinessReportTopProductData> topProductsByProfitMargin;

  // Inventory insights
  final int totalStockValue;
  final int lowStockItemsCount;
  final List<InventoryItemData> lowStockItems;
  final double inventoryTurnoverRate;

  // Business KPIs
  final double averageItemsPerOrder;
  final int totalItemsSold;

  // Sales trends
  final List<DailySalesData> dailySalesTrend;
  final List<MonthlySalesData> monthlySalesTrend;

  BusinessReportData({
    required this.startDate,
    required this.endDate,
    required this.totalRevenue,
    required this.totalCosts,
    required this.totalOrders,
    required this.totalProducts,
    required this.totalCustomers,
    required this.salesByCategory,
    required this.topProducts,
    required this.salesInvoices,
    required this.incomingInvoices,
    required this.username,
    this.selectedCategoryLabel = 'All',
    this.revenueByDay = const {},
    this.revenueByWeek = const {},
    this.revenueByMonth = const {},
    this.costOfGoodsSold = 0.0,
    this.operatingExpenses = 0.0,
    this.newCustomers = 0,
    this.returningCustomers = 0,
    this.customerRetentionRate = 0.0,
    this.topCustomers = const [],
    this.topProductsByQuantity = const [],
    this.topProductsByProfitMargin = const [],
    this.totalStockValue = 0,
    this.lowStockItemsCount = 0,
    this.lowStockItems = const [],
    this.inventoryTurnoverRate = 0.0,
    this.averageItemsPerOrder = 0.0,
    this.totalItemsSold = 0,
    this.dailySalesTrend = const [],
    this.monthlySalesTrend = const [],
  });

  double get grossProfit => totalRevenue - totalCosts;
  double get profitMargin =>
      totalRevenue > 0 ? (grossProfit / totalRevenue) * 100 : 0;
  double get averageOrderValue =>
      totalOrders > 0 ? totalRevenue / totalOrders : 0;
}

class CustomerSpendingData {
  final String customerID;
  final String customerName;
  final double totalSpending;
  final int orderCount;

  CustomerSpendingData({
    required this.customerID,
    required this.customerName,
    required this.totalSpending,
    required this.orderCount,
  });
}

class InventoryItemData {
  final String productID;
  final String productName;
  final int currentStock;
  final int minStockThreshold;

  InventoryItemData({
    required this.productID,
    required this.productName,
    required this.currentStock,
    this.minStockThreshold = 10,
  });
}

class DailySalesData {
  final DateTime date;
  double revenue;
  double costs;
  double profit;

  DailySalesData({
    required this.date,
    required this.revenue,
    required this.costs,
    required this.profit,
  });
}

class MonthlySalesData {
  final DateTime month;
  double revenue;
  double costs;
  double profit;

  MonthlySalesData({
    required this.month,
    required this.revenue,
    required this.costs,
    required this.profit,
  });
}

class BusinessReportTopProductData {
  final String productID;
  final String productName;
  final int totalSales;
  final double totalRevenue;
  final double totalCost;
  final double profit;

  BusinessReportTopProductData({
    required this.productID,
    required this.productName,
    required this.totalSales,
    required this.totalRevenue,
    required this.totalCost,
  }) : profit = totalRevenue - totalCost;
}

class BusinessReportPdfService {
  static Future<pw.Document> generatePdf({
    required BusinessReportData reportData,
    required Map<String, String> localizations,
  }) async {
    final notoSansRegular = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Regular.ttf'),
    );
    final notoSansBold = pw.Font.ttf(
      await rootBundle.load('assets/fonts/NotoSans-Bold.ttf'),
    );

    final pdf = pw.Document();
    final dateFormat = DateFormat('dd/MM/yyyy');

    // Build pages - split content across multiple pages if needed
    _buildFirstPage(pdf, reportData, notoSansRegular, notoSansBold, dateFormat,
        localizations);

    // Add second page with detailed sections
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Theme(
            data: pw.ThemeData.withFont(
              base: notoSansRegular,
              bold: notoSansBold,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(notoSansRegular, notoSansBold, localizations),
                pw.SizedBox(height: 20),
                _buildRevenueBreakdown(
                    reportData, notoSansBold, notoSansRegular, localizations),
                pw.SizedBox(height: 20),
                _buildCostBreakdown(
                    reportData, notoSansBold, notoSansRegular, localizations),
                pw.SizedBox(height: 20),
                _buildCustomerInsights(
                    reportData, notoSansBold, notoSansRegular, localizations),
                pw.SizedBox(height: 20),
                _buildBestSellingProducts(
                    reportData, notoSansBold, notoSansRegular, localizations),
              ],
            ),
          );
        },
      ),
    );

    // Add third page with inventory and KPIs
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Theme(
            data: pw.ThemeData.withFont(
              base: notoSansRegular,
              bold: notoSansBold,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(notoSansRegular, notoSansBold, localizations),
                pw.SizedBox(height: 20),
                _buildInventoryInsights(
                    reportData, notoSansBold, notoSansRegular, localizations),
                pw.SizedBox(height: 20),
                _buildSalesTrends(
                    reportData, notoSansBold, notoSansRegular, localizations),
                pw.SizedBox(height: 20),
                _buildBusinessKPIs(
                    reportData, notoSansBold, notoSansRegular, localizations),
                pw.SizedBox(height: 20),
                _buildFooter(
                    reportData.username, notoSansRegular, localizations),
              ],
            ),
          );
        },
      ),
    );

    // Page 4: Top Products by Revenue (Top 5)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Theme(
            data: pw.ThemeData.withFont(
              base: notoSansRegular,
              bold: notoSansBold,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(notoSansRegular, notoSansBold, localizations),
                pw.SizedBox(height: 20),
                _buildSectionTitle(
                    '${localizations['topProducts'] ?? 'Top Products'} - ${localizations['revenue'] ?? 'Revenue'} (Top 5)',
                    notoSansBold),
                pw.SizedBox(height: 12),
                _buildTopProductsTable(
                  reportData.topProducts.take(5).toList(),
                  notoSansBold,
                  notoSansRegular,
                  localizations,
                  includeRank: true,
                ),
                pw.SizedBox(height: 20),
                _buildFooter(
                    reportData.username, notoSansRegular, localizations),
              ],
            ),
          );
        },
      ),
    );

    // Page 5: Best-Selling Products by Quantity (Top 5)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Theme(
            data: pw.ThemeData.withFont(
              base: notoSansRegular,
              bold: notoSansBold,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(notoSansRegular, notoSansBold, localizations),
                pw.SizedBox(height: 20),
                _buildSectionTitle(
                    '${localizations['bestSellingProducts'] ?? 'Best-Selling Products'} (Top 5)',
                    notoSansBold),
                pw.SizedBox(height: 12),
                _buildTopProductsTable(
                  reportData.topProductsByQuantity.take(5).toList(),
                  notoSansBold,
                  notoSansRegular,
                  localizations,
                  includeRank: true,
                  showQuantityFirst: true,
                ),
                pw.SizedBox(height: 20),
                _buildFooter(
                    reportData.username, notoSansRegular, localizations),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static void _buildFirstPage(
      pw.Document pdf,
      BusinessReportData reportData,
      pw.Font notoSansRegular,
      pw.Font notoSansBold,
      DateFormat dateFormat,
      Map<String, String> localizations) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return pw.Theme(
            data: pw.ThemeData.withFont(
              base: notoSansRegular,
              bold: notoSansBold,
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(notoSansRegular, notoSansBold, localizations),
                pw.SizedBox(height: 30),
                _buildReportPeriod(reportData.startDate, reportData.endDate,
                    dateFormat, notoSansBold, notoSansRegular, localizations,
                    categoryLabel: reportData.selectedCategoryLabel),
                pw.SizedBox(height: 30),
                _buildExecutiveSummary(
                    reportData, notoSansBold, notoSansRegular, localizations),
                pw.SizedBox(height: 30),
                _buildFinancialOverview(
                    reportData, notoSansBold, notoSansRegular, localizations),
                pw.SizedBox(height: 30),
                _buildSalesAnalysis(
                    reportData, notoSansBold, notoSansRegular, localizations),
                pw.SizedBox(height: 30),
                _buildTopProducts(reportData.topProducts, notoSansBold,
                    notoSansRegular, localizations),
                pw.SizedBox(height: 30),
                _buildCategoryBreakdown(reportData.salesByCategory,
                    notoSansBold, notoSansRegular, localizations),
              ],
            ),
          );
        },
      ),
    );
  }

  static pw.Widget _buildHeader(pw.Font notoSansRegular, pw.Font notoSansBold,
      Map<String, String> localizations) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(20),
      decoration: const pw.BoxDecoration(
        color: PdfColors.green700,
        borderRadius: pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'GIZMOGLOBE',
                style: pw.TextStyle(
                  font: notoSansBold,
                  color: PdfColors.white,
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Retailer Management System',
                style: pw.TextStyle(
                  font: notoSansRegular,
                  color: PdfColors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          pw.Text(
            localizations['businessReport']?.toUpperCase() ?? 'BUSINESS REPORT',
            style: pw.TextStyle(
              font: notoSansBold,
              color: PdfColors.white,
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildReportPeriod(
      DateTime startDate,
      DateTime endDate,
      DateFormat dateFormat,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations,
      {String categoryLabel = 'All'}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.green50,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.green400, width: 1),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            '${localizations['reportPeriod'] ?? 'Report Period'}: ',
            style: pw.TextStyle(
              font: notoSansBold,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
            style: pw.TextStyle(
              font: notoSansRegular,
              fontSize: 14,
            ),
          ),
          if (categoryLabel.isNotEmpty) ...[
            pw.SizedBox(width: 12),
            pw.Text(
              '${localizations['category'] ?? 'Category'}: ',
              style: pw.TextStyle(
                font: notoSansBold,
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              categoryLabel,
              style: pw.TextStyle(
                font: notoSansRegular,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildExecutiveSummary(
      BusinessReportData data,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          localizations['executiveSummary'] ?? 'Executive Summary',
          style: pw.TextStyle(
            font: notoSansBold,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.grey400, width: 1),
          ),
          child: pw.Column(
            children: [
              _buildSummaryRow(
                  localizations['totalRevenue'] ?? 'Total Revenue',
                  Helper.toCurrencyFormat(data.totalRevenue),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildSummaryRow(
                  localizations['totalCosts'] ?? 'Total Costs',
                  Helper.toCurrencyFormat(data.totalCosts),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildSummaryRow(
                  localizations['grossProfit'] ?? 'Gross Profit',
                  Helper.toCurrencyFormat(data.grossProfit),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildSummaryRow(
                  localizations['profitMargin'] ?? 'Profit Margin',
                  '${data.profitMargin.toStringAsFixed(2)}%',
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildSummaryRow(localizations['totalOrders'] ?? 'Total Orders',
                  data.totalOrders.toString(), notoSansBold, notoSansRegular),
              pw.SizedBox(height: 8),
              _buildSummaryRow(
                  localizations['averageOrderValue'] ?? 'Average Order Value',
                  Helper.toCurrencyFormat(data.averageOrderValue),
                  notoSansBold,
                  notoSansRegular),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value,
      pw.Font notoSansBold, pw.Font notoSansRegular) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: notoSansBold,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            font: notoSansRegular,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildFinancialOverview(
      BusinessReportData data,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          localizations['financialOverview'] ?? 'Financial Overview',
          style: pw.TextStyle(
            font: notoSansBold,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.blue300, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      localizations['revenueMetrics'] ?? 'Revenue Metrics',
                      style: pw.TextStyle(
                        font: notoSansBold,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildInfoRow(
                        localizations['totalRevenue'] ?? 'Total Revenue',
                        Helper.toCurrencyFormat(data.totalRevenue),
                        notoSansBold,
                        notoSansRegular),
                    pw.SizedBox(height: 5),
                    _buildInfoRow(
                        localizations['totalOrders'] ?? 'Total Orders',
                        data.totalOrders.toString(),
                        notoSansBold,
                        notoSansRegular),
                    pw.SizedBox(height: 5),
                    _buildInfoRow(
                        localizations['averageOrderValue'] ?? 'Avg Order Value',
                        Helper.toCurrencyFormat(data.averageOrderValue),
                        notoSansBold,
                        notoSansRegular),
                  ],
                ),
              ),
            ),
            pw.SizedBox(width: 15),
            pw.Expanded(
              child: pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.orange50,
                  borderRadius:
                      const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColors.orange300, width: 1),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      localizations['costMetrics'] ?? 'Cost Metrics',
                      style: pw.TextStyle(
                        font: notoSansBold,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 10),
                    _buildInfoRow(
                        localizations['totalCosts'] ?? 'Total Costs',
                        Helper.toCurrencyFormat(data.totalCosts),
                        notoSansBold,
                        notoSansRegular),
                    pw.SizedBox(height: 5),
                    _buildInfoRow(
                        localizations['grossProfit'] ?? 'Gross Profit',
                        Helper.toCurrencyFormat(data.grossProfit),
                        notoSansBold,
                        notoSansRegular),
                    pw.SizedBox(height: 5),
                    _buildInfoRow(
                        localizations['profitMargin'] ?? 'Profit Margin',
                        '${data.profitMargin.toStringAsFixed(2)}%',
                        notoSansBold,
                        notoSansRegular),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildSalesAnalysis(
      BusinessReportData data,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          localizations['salesAnalysis'] ?? 'Sales Analysis',
          style: pw.TextStyle(
            font: notoSansBold,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.grey400, width: 1),
          ),
          child: pw.Column(
            children: [
              _buildInfoRow(localizations['totalProducts'] ?? 'Total Products',
                  data.totalProducts.toString(), notoSansBold, notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['totalCustomers'] ?? 'Total Customers',
                  data.totalCustomers.toString(),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['totalSalesInvoices'] ?? 'Total Sales Invoices',
                  data.salesInvoices.length.toString(),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['totalIncomingInvoices'] ??
                      'Total Incoming Invoices',
                  data.incomingInvoices.length.toString(),
                  notoSansBold,
                  notoSansRegular),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildTopProducts(
      List<BusinessReportTopProductData> topProducts,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    if (topProducts.isEmpty) {
      return pw.SizedBox.shrink();
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          localizations['topProducts'] ?? 'Top Products',
          style: pw.TextStyle(
            font: notoSansBold,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),
        pw.SizedBox(height: 15),
        _buildTopProductsTable(
          topProducts.take(10).toList(),
          notoSansBold,
          notoSansRegular,
          localizations,
        ),
      ],
    );
  }

  static pw.Widget _buildTopProductsTable(
    List<BusinessReportTopProductData> products,
    pw.Font notoSansBold,
    pw.Font notoSansRegular,
    Map<String, String> localizations, {
    bool includeRank = false,
    bool showQuantityFirst = false,
  }) {
    if (products.isEmpty) {
      return pw.Text(
        localizations['noData'] ?? 'No data available for this section.',
        style: pw.TextStyle(font: notoSansRegular, fontSize: 12),
      );
    }

    final headers = <String>[
      if (includeRank) '#',
      localizations['productName'] ?? 'Product Name',
      localizations['revenue'] ?? 'Revenue',
      localizations['costs'] ?? 'Cost',
      localizations['profit'] ?? 'Profit',
      localizations['quantitySold'] ?? 'Quantity Sold',
    ];

    final columnWidths = <int, pw.TableColumnWidth>{};
    int colIndex = 0;
    if (includeRank) {
      columnWidths[colIndex++] = const pw.FlexColumnWidth(1);
    }
    columnWidths[colIndex++] = const pw.FlexColumnWidth(3); // name
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2); // revenue
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2); // cost
    columnWidths[colIndex++] = const pw.FlexColumnWidth(2); // profit
    columnWidths[colIndex] = const pw.FlexColumnWidth(2); // quantity

    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.green400, width: 1),
      columnWidths: columnWidths,
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.green700),
          children: headers.map((header) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                header,
                style: pw.TextStyle(
                  font: notoSansBold,
                  color: PdfColors.white,
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
          }).toList(),
        ),
        ...products.asMap().entries.map((entry) {
          final index = entry.key;
          final product = entry.value;
          final cells = <pw.Widget>[
            if (includeRank)
              pw.Padding(
                padding: const pw.EdgeInsets.all(8),
                child: pw.Text(
                  (index + 1).toString(),
                  style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
                ),
              ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                product.productName,
                style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                Helper.toCurrencyFormat(product.totalRevenue),
                style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                Helper.toCurrencyFormat(product.totalCost),
                style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                Helper.toCurrencyFormat(product.profit),
                style: pw.TextStyle(
                    font: notoSansRegular,
                    fontSize: 10,
                    color: product.profit >= 0
                        ? PdfColors.green800
                        : PdfColors.red800),
              ),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text(
                product.totalSales.toString(),
                style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
              ),
            ),
          ];

          return pw.TableRow(children: cells);
        }),
      ],
    );
  }

  static pw.Widget _buildCategoryBreakdown(
      Map<String, double> salesByCategory,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    if (salesByCategory.isEmpty) {
      return pw.SizedBox.shrink();
    }

    final sortedCategories = salesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          localizations['salesByCategory'] ?? 'Sales by Category',
          style: pw.TextStyle(
            font: notoSansBold,
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.green900,
          ),
        ),
        pw.SizedBox(height: 15),
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.green400, width: 1),
          columnWidths: {
            0: const pw.FlexColumnWidth(3),
            1: const pw.FlexColumnWidth(2),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.green700),
              children: [
                localizations['category'] ?? 'Category',
                localizations['revenue'] ?? 'Revenue',
              ].map((header) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.all(8),
                  child: pw.Text(
                    header,
                    style: pw.TextStyle(
                      font: notoSansBold,
                      color: PdfColors.white,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            ...sortedCategories.map((entry) {
              return pw.TableRow(
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      entry.key,
                      style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(8),
                    child: pw.Text(
                      Helper.toCurrencyFormat(entry.value),
                      style: pw.TextStyle(font: notoSansRegular, fontSize: 10),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInfoRow(
      String label, String value, pw.Font boldFont, pw.Font regularFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(font: regularFont, fontSize: 12),
        ),
      ],
    );
  }

  static pw.Widget _buildRevenueBreakdown(
      BusinessReportData data,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            localizations['revenueBreakdown'] ?? 'Revenue Breakdown',
            notoSansBold),
        pw.SizedBox(height: 15),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.grey400, width: 1),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildInfoRow(
                  localizations['totalRevenue'] ?? 'Total Revenue',
                  Helper.toCurrencyFormat(data.totalRevenue),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['revenueByCategory'] ?? 'Revenue by Category',
                  '${data.salesByCategory.length} ${localizations['category']?.toLowerCase() ?? 'categories'}',
                  notoSansBold,
                  notoSansRegular),
              if (data.revenueByMonth.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                _buildInfoRow(
                    localizations['monthlyRevenue'] ??
                        'Average Monthly Revenue',
                    Helper.toCurrencyFormat(data.revenueByMonth.values
                            .fold(0.0, (sum, val) => sum + val) /
                        data.revenueByMonth.length),
                    notoSansBold,
                    notoSansRegular),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCostBreakdown(
      BusinessReportData data,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            localizations['costBreakdown'] ?? 'Cost Breakdown', notoSansBold),
        pw.SizedBox(height: 15),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.orange50,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.orange300, width: 1),
          ),
          child: pw.Column(
            children: [
              _buildInfoRow(
                  localizations['costOfGoodsSold'] ??
                      'Cost of Goods Sold (COGS)',
                  Helper.toCurrencyFormat(data.costOfGoodsSold),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['operatingExpenses'] ?? 'Operating Expenses',
                  Helper.toCurrencyFormat(data.operatingExpenses),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['totalCosts'] ?? 'Total Costs',
                  Helper.toCurrencyFormat(data.totalCosts),
                  notoSansBold,
                  notoSansRegular),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerInsights(
      BusinessReportData data,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            localizations['customerInsights'] ?? 'Customer Insights',
            notoSansBold),
        pw.SizedBox(height: 15),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.purple50,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.purple300, width: 1),
          ),
          child: pw.Column(
            children: [
              _buildInfoRow(
                  localizations['totalCustomers'] ?? 'Total Customers',
                  data.totalCustomers.toString(),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(localizations['newCustomers'] ?? 'New Customers',
                  data.newCustomers.toString(), notoSansBold, notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['returningCustomers'] ?? 'Returning Customers',
                  data.returningCustomers.toString(),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['customerRetentionRate'] ??
                      'Customer Retention Rate',
                  '${data.customerRetentionRate.toStringAsFixed(1)}%',
                  notoSansBold,
                  notoSansRegular),
            ],
          ),
        ),
        if (data.topCustomers.isNotEmpty) ...[
          pw.SizedBox(height: 15),
          pw.Text(
            localizations['topCustomersBySpending'] ??
                'Top Customers by Spending',
            style: pw.TextStyle(
              font: notoSansBold,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.purple400, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.purple700),
                children: [
                  localizations['customer'] ?? 'Customer Name',
                  localizations['orders'] ?? 'Orders',
                  localizations['totalSpending'] ?? 'Total Spending'
                ]
                    .map((header) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(
                              font: notoSansBold,
                              color: PdfColors.white,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              ...data.topCustomers.take(5).map((customer) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        customer.customerName,
                        style:
                            pw.TextStyle(font: notoSansRegular, fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        customer.orderCount.toString(),
                        style:
                            pw.TextStyle(font: notoSansRegular, fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        Helper.toCurrencyFormat(customer.totalSpending),
                        style:
                            pw.TextStyle(font: notoSansRegular, fontSize: 10),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildBestSellingProducts(
      BusinessReportData data,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            localizations['bestSellingProducts'] ?? 'Best-Selling Products',
            notoSansBold),
        pw.SizedBox(height: 15),
        if (data.topProductsByQuantity.isEmpty)
          pw.Text(
            localizations['noData'] ?? 'No data available for this section.',
            style: pw.TextStyle(font: notoSansRegular, fontSize: 12),
          )
        else ...[
          pw.Text(
            localizations['topProductsByQuantity'] ??
                'Top Products by Quantity Sold',
            style: pw.TextStyle(
              font: notoSansBold,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.green400, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green700),
                children: [
                  localizations['productName'] ?? 'Product Name',
                  localizations['quantity'] ?? 'Quantity',
                  localizations['revenue'] ?? 'Revenue'
                ]
                    .map((header) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(
                              font: notoSansBold,
                              color: PdfColors.white,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              ...data.topProductsByQuantity.take(5).map((product) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        product.productName,
                        style:
                            pw.TextStyle(font: notoSansRegular, fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        product.totalSales.toString(),
                        style:
                            pw.TextStyle(font: notoSansRegular, fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        Helper.toCurrencyFormat(product.totalRevenue),
                        style:
                            pw.TextStyle(font: notoSansRegular, fontSize: 10),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildInventoryInsights(
      BusinessReportData data,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            localizations['inventoryInsights'] ?? 'Inventory Insights',
            notoSansBold),
        pw.SizedBox(height: 15),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue50,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.blue300, width: 1),
          ),
          child: pw.Column(
            children: [
              _buildInfoRow(
                  localizations['totalStockValue'] ?? 'Total Stock Value',
                  Helper.toCurrencyFormat(data.totalStockValue.toDouble()),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['lowStockItems'] ?? 'Low Stock Items',
                  data.lowStockItemsCount.toString(),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['inventoryTurnoverRate'] ??
                      'Inventory Turnover Rate',
                  data.inventoryTurnoverRate.toStringAsFixed(2),
                  notoSansBold,
                  notoSansRegular),
            ],
          ),
        ),
        if (data.lowStockItems.isNotEmpty) ...[
          pw.SizedBox(height: 15),
          pw.Text(
            localizations['lowStockItems'] ?? 'Low Stock Items',
            style: pw.TextStyle(
              font: notoSansBold,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.blue400, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.blue700),
                children: [
                  localizations['productName'] ?? 'Product Name',
                  localizations['currentStock'] ?? 'Current Stock'
                ]
                    .map((header) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(
                              font: notoSansBold,
                              color: PdfColors.white,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              ...data.lowStockItems.take(10).map((item) {
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        item.productName,
                        style:
                            pw.TextStyle(font: notoSansRegular, fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        item.currentStock.toString(),
                        style: pw.TextStyle(
                          font: notoSansRegular,
                          fontSize: 10,
                          color: item.currentStock < item.minStockThreshold
                              ? PdfColors.red700
                              : PdfColors.black,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildSalesTrends(
      BusinessReportData data,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            localizations['salesTrends'] ?? 'Sales Trends', notoSansBold),
        pw.SizedBox(height: 15),
        if (data.monthlySalesTrend.isNotEmpty) ...[
          pw.Text(
            localizations['monthlySalesTrend'] ?? 'Monthly Sales Trend',
            style: pw.TextStyle(
              font: notoSansBold,
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.green400, width: 1),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(2),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.green700),
                children: [
                  localizations['month'] ?? 'Month',
                  localizations['revenue'] ?? 'Revenue',
                  localizations['costs'] ?? 'Costs',
                  localizations['profit'] ?? 'Profit'
                ]
                    .map((header) => pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(
                              font: notoSansBold,
                              color: PdfColors.white,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ))
                    .toList(),
              ),
              ...data.monthlySalesTrend.take(6).map((trend) {
                final dateFormat = DateFormat('MMM yyyy');
                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        dateFormat.format(trend.month),
                        style:
                            pw.TextStyle(font: notoSansRegular, fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        Helper.toCurrencyFormat(trend.revenue),
                        style:
                            pw.TextStyle(font: notoSansRegular, fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        Helper.toCurrencyFormat(trend.costs),
                        style:
                            pw.TextStyle(font: notoSansRegular, fontSize: 10),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(8),
                      child: pw.Text(
                        Helper.toCurrencyFormat(trend.profit),
                        style: pw.TextStyle(
                          font: notoSansRegular,
                          fontSize: 10,
                          color: trend.profit >= 0
                              ? PdfColors.green700
                              : PdfColors.red700,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildBusinessKPIs(
      BusinessReportData data,
      pw.Font notoSansBold,
      pw.Font notoSansRegular,
      Map<String, String> localizations) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            localizations['businessKPIs'] ?? 'Business KPIs', notoSansBold),
        pw.SizedBox(height: 15),
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.teal50,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
            border: pw.Border.all(color: PdfColors.teal300, width: 1),
          ),
          child: pw.Column(
            children: [
              _buildInfoRow(
                  localizations['averageOrderValue'] ?? 'Average Order Value',
                  Helper.toCurrencyFormat(data.averageOrderValue),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['averageItemsPerOrder'] ??
                      'Average Items per Order',
                  data.averageItemsPerOrder.toStringAsFixed(2),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['totalItemsSold'] ?? 'Total Items Sold',
                  data.totalItemsSold.toString(),
                  notoSansBold,
                  notoSansRegular),
              pw.SizedBox(height: 8),
              _buildInfoRow(
                  localizations['profitMargin'] ?? 'Profit Margin',
                  '${data.profitMargin.toStringAsFixed(2)}%',
                  notoSansBold,
                  notoSansRegular),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title, pw.Font notoSansBold) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        font: notoSansBold,
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.green900,
      ),
    );
  }

  static pw.Widget _buildFooter(String username, pw.Font notoSansRegular,
      Map<String, String> localizations) {
    // Footer removed as per user request
    return pw.SizedBox.shrink();
  }
}
