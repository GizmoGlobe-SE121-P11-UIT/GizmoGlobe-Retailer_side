import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';
import '../../../data/database/database.dart';
import '../../../data/firebase/firebase.dart';
import '../../../services/reports/business_report_pdf_service.dart';
import '../../../objects/customer.dart';
import '../../../objects/invoice_related/sales_invoice.dart';
import 'home_screen_state.dart';

class TopProductData {
  final String productID;
  final String productName;
  int totalSales;
  double totalRevenue;

  TopProductData({
    required this.productID,
    required this.productName,
    required this.totalSales,
    required this.totalRevenue,
  });
}

class HomeScreenCubit extends Cubit<HomeScreenState> {
  final Database db = Database();

  HomeScreenCubit() : super(const HomeScreenState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Database is already initialized in main.dart, just get user data
      // Step 1: Load username first
      await db.getUser();
      if (!isClosed) {
        emit(state.copyWith(
          username: db.username ?? '',
          isLoadingUsername: false,
        ));
      }

      // On mobile, use precomputed stats from Cloud Functions to prevent OOM crash
      if (!kIsWeb) {
        // Try to get precomputed dashboard stats first (lightweight, single doc read)
        try {
          final dashboardStats = await Firebase().getDashboardStats();

          if (dashboardStats != null) {
            // Use precomputed stats
            final totalRevenue =
                (dashboardStats['totalRevenue'] as num?)?.toDouble() ?? 0.0;
            final totalOrders =
                (dashboardStats['totalOrders'] as num?)?.toInt() ?? 0;
            final monthlySalesData =
                dashboardStats['monthlySales'] as List<dynamic>? ?? [];
            final dailySalesData =
                dashboardStats['dailySales'] as List<dynamic>? ?? [];
            final monthlySalesByCategoryData =
                dashboardStats['monthlySalesByCategory'] as List<dynamic>? ??
                    [];
            final dailySalesByCategoryData =
                dashboardStats['dailySalesByCategory'] as List<dynamic>? ?? [];

            // Convert monthlySales from Cloud Function format to SalesData
            final List<SalesData> monthlySales = [];
            for (var item in monthlySalesData) {
              final month = item['month'] as String; // "2024-01"
              final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
              final parts = month.split('-');
              if (parts.length == 2) {
                final year = int.tryParse(parts[0]) ?? 2024;
                final monthNum = int.tryParse(parts[1]) ?? 1;
                // Multiply by 1000 to match existing chart format
                monthlySales
                    .add(SalesData(DateTime(year, monthNum, 1), amount * 1000));
              }
            }

            // Convert dailySales from Cloud Function format to SalesData
            final List<SalesData> dailySales = [];
            for (var item in dailySalesData) {
              final date = item['date'] as String; // "2024-01-15"
              final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
              final parts = date.split('-');
              if (parts.length == 3) {
                final year = int.tryParse(parts[0]) ?? 2024;
                final monthNum = int.tryParse(parts[1]) ?? 1;
                final day = int.tryParse(parts[2]) ?? 1;
                // Multiply by 1000 to match existing chart format
                dailySales.add(
                    SalesData(DateTime(year, monthNum, day), amount * 1000));
              }
            }

            // Convert monthlySalesByCategory from Cloud Function format
            final List<CategorySalesData> monthlyCategorySales = [];
            for (var item in monthlySalesByCategoryData) {
              final month = item['month'] as String; // "2024-01"
              final categories = item['categories'] as List<dynamic>? ?? [];
              final parts = month.split('-');
              if (parts.length == 2) {
                final year = int.tryParse(parts[0]) ?? 2024;
                final monthNum = int.tryParse(parts[1]) ?? 1;
                final categoryMap = <String, double>{};
                for (var cat in categories) {
                  final category = cat['category'] as String? ?? 'Unknown';
                  final amount = (cat['amount'] as num?)?.toDouble() ?? 0.0;
                  categoryMap[category] = amount * 1000; // Multiply by 1000
                }
                monthlyCategorySales.add(CategorySalesData(
                    DateTime(year, monthNum, 1), categoryMap));
              }
            }

            // Convert dailySalesByCategory from Cloud Function format
            final List<CategorySalesData> dailyCategorySales = [];
            for (var item in dailySalesByCategoryData) {
              final date = item['date'] as String; // "2024-01-15"
              final categories = item['categories'] as List<dynamic>? ?? [];
              final parts = date.split('-');
              if (parts.length == 3) {
                final year = int.tryParse(parts[0]) ?? 2024;
                final monthNum = int.tryParse(parts[1]) ?? 1;
                final day = int.tryParse(parts[2]) ?? 1;
                final categoryMap = <String, double>{};
                for (var cat in categories) {
                  final category = cat['category'] as String? ?? 'Unknown';
                  final amount = (cat['amount'] as num?)?.toDouble() ?? 0.0;
                  categoryMap[category] = amount * 1000; // Multiply by 1000
                }
                dailyCategorySales.add(CategorySalesData(
                    DateTime(year, monthNum, day), categoryMap));
              }
            }

            // Limit to last 12 months
            final limitedSales = monthlySales.length > 12
                ? monthlySales.sublist(monthlySales.length - 12)
                : monthlySales;

            // Limit category sales to last 12 months
            final limitedCategorySales = monthlyCategorySales.length > 12
                ? monthlyCategorySales.sublist(monthlyCategorySales.length - 12)
                : monthlyCategorySales;

            // Load product counts
            await _loadProductCounts();

            if (!isClosed) {
              emit(state.copyWith(
                totalProducts: db.productList.length,
                totalCustomers: db.customerList.length,
                totalManufacturers: db.manufacturerList.length,
                totalEmployees: db.employeeList.length,
                totalRevenue: totalRevenue,
                totalOrders: totalOrders,
                monthlySales: limitedSales,
                dailySales: dailySales,
                monthlyCategorySales: limitedCategorySales,
                dailyCategorySales: dailyCategorySales,
                isLoadingOverview: false,
                isLoadingChart: false,
              ));
            }
          } else {
            // Fallback: Cloud Function not deployed yet, show basic counts only
            // Still try to load product counts
            await _loadProductCounts();

            if (!isClosed) {
              emit(state.copyWith(
                totalProducts: db.productList.length,
                totalCustomers: db.customerList.length,
                totalManufacturers: db.manufacturerList.length,
                totalEmployees: db.employeeList.length,
                totalRevenue: 0,
                totalOrders: 0,
                isLoadingOverview: false,
                isLoadingChart: false,
              ));
            }
          }
        } catch (e) {
          // Fallback on error
          if (!isClosed) {
            emit(state.copyWith(
              totalProducts: db.productList.length,
              totalCustomers: db.customerList.length,
              totalManufacturers: db.manufacturerList.length,
              totalEmployees: db.employeeList.length,
              isLoadingOverview: false,
              isLoadingChart: false,
            ));
          }
        }
        return;
      }

      // Web: Use Cloud Functions aggregated data (same as mobile)
      // Declare outside try block so it's accessible for category processing
      List<SalesInvoice> paidInvoices = [];
      List<SalesInvoice> recentOrdersList = [];

      try {
        final dashboardStats = await Firebase().getDashboardStats();
        final unreadChats = await Firebase().getUnreadChatsCount();

        // Get recent orders for web (still need invoice list for this)
        final salesInvoices = await Firebase().getSalesInvoices();
        paidInvoices = salesInvoices
            .where((invoice) => invoice.paymentStatus == PaymentStatus.paid)
            .toList();
        final sortedInvoices = List<SalesInvoice>.from(paidInvoices);
        sortedInvoices.sort((a, b) => b.date.compareTo(a.date));
        recentOrdersList = sortedInvoices.take(5).toList();

        if (dashboardStats != null) {
          // Use precomputed stats from Cloud Functions
          final totalRevenue =
              (dashboardStats['totalRevenue'] as num?)?.toDouble() ?? 0.0;
          final totalOrders =
              (dashboardStats['totalOrders'] as num?)?.toInt() ?? 0;
          final monthlySalesData =
              dashboardStats['monthlySales'] as List<dynamic>? ?? [];
          final dailySalesData =
              dashboardStats['dailySales'] as List<dynamic>? ?? [];
          final monthlySalesByCategoryData =
              dashboardStats['monthlySalesByCategory'] as List<dynamic>? ?? [];
          final dailySalesByCategoryData =
              dashboardStats['dailySalesByCategory'] as List<dynamic>? ?? [];

          // Convert monthlySales from Cloud Function format to SalesData
          final List<SalesData> monthlySales = [];
          for (var item in monthlySalesData) {
            final month = item['month'] as String; // "2024-01"
            final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
            final parts = month.split('-');
            if (parts.length == 2) {
              final year = int.tryParse(parts[0]) ?? 2024;
              final monthNum = int.tryParse(parts[1]) ?? 1;
              // Multiply by 1000 to match existing chart format
              monthlySales
                  .add(SalesData(DateTime(year, monthNum, 1), amount * 1000));
            }
          }

          // Convert dailySales from Cloud Function format to SalesData
          final List<SalesData> dailySales = [];
          for (var item in dailySalesData) {
            final date = item['date'] as String; // "2024-01-15"
            final amount = (item['amount'] as num?)?.toDouble() ?? 0.0;
            final parts = date.split('-');
            if (parts.length == 3) {
              final year = int.tryParse(parts[0]) ?? 2024;
              final monthNum = int.tryParse(parts[1]) ?? 1;
              final day = int.tryParse(parts[2]) ?? 1;
              // Multiply by 1000 to match existing chart format
              dailySales
                  .add(SalesData(DateTime(year, monthNum, day), amount * 1000));
            }
          }

          // Convert monthlySalesByCategory from Cloud Function format
          final List<CategorySalesData> monthlyCategorySales = [];
          for (var item in monthlySalesByCategoryData) {
            final month = item['month'] as String; // "2024-01"
            final categories = item['categories'] as List<dynamic>? ?? [];
            final parts = month.split('-');
            if (parts.length == 2) {
              final year = int.tryParse(parts[0]) ?? 2024;
              final monthNum = int.tryParse(parts[1]) ?? 1;
              final categoryMap = <String, double>{};
              for (var cat in categories) {
                final category = cat['category'] as String? ?? 'Unknown';
                final amount = (cat['amount'] as num?)?.toDouble() ?? 0.0;
                categoryMap[category] = amount * 1000; // Multiply by 1000
              }
              monthlyCategorySales.add(
                  CategorySalesData(DateTime(year, monthNum, 1), categoryMap));
            }
          }

          // Convert dailySalesByCategory from Cloud Function format
          final List<CategorySalesData> dailyCategorySales = [];
          for (var item in dailySalesByCategoryData) {
            final date = item['date'] as String; // "2024-01-15"
            final categories = item['categories'] as List<dynamic>? ?? [];
            final parts = date.split('-');
            if (parts.length == 3) {
              final year = int.tryParse(parts[0]) ?? 2024;
              final monthNum = int.tryParse(parts[1]) ?? 1;
              final day = int.tryParse(parts[2]) ?? 1;
              final categoryMap = <String, double>{};
              for (var cat in categories) {
                final category = cat['category'] as String? ?? 'Unknown';
                final amount = (cat['amount'] as num?)?.toDouble() ?? 0.0;
                categoryMap[category] = amount * 1000; // Multiply by 1000
              }
              dailyCategorySales.add(CategorySalesData(
                  DateTime(year, monthNum, day), categoryMap));
            }
          }

          // Load product counts
          await _loadProductCounts();

          if (!isClosed) {
            emit(state.copyWith(
              totalProducts: db.productList.length,
              totalCustomers: db.customerList.length,
              totalManufacturers: db.manufacturerList.length,
              totalEmployees: db.employeeList.length,
              totalRevenue: totalRevenue,
              totalOrders: totalOrders,
              unreadChats: unreadChats,
              recentOrders: recentOrdersList,
              monthlySales: monthlySales,
              dailySales: dailySales,
              monthlyCategorySales: monthlyCategorySales,
              dailyCategorySales: dailyCategorySales,
              isLoadingOverview: false,
              isLoadingChart: false,
            ));
          }
        } else {
          // Fallback: Cloud Function not deployed, calculate locally
          double totalRevenue = 0.0;
          int totalPaidOrders = 0;

          for (var invoice in paidInvoices) {
            totalRevenue += invoice.totalPrice;
            totalPaidOrders++;
          }

          // Calculate chart data locally
          final List<SalesData> monthlySales = [];
          final Map<String, double> monthlyMap = {};

          for (var invoice in paidInvoices) {
            final monthKey =
                '${invoice.date.year}-${invoice.date.month.toString().padLeft(2, '0')}';
            monthlyMap[monthKey] =
                (monthlyMap[monthKey] ?? 0) + invoice.totalPrice;
          }

          for (var entry in monthlyMap.entries) {
            final parts = entry.key.split('-');
            final year = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final roundedAmount = (entry.value * 1000).roundToDouble();
            monthlySales
                .add(SalesData(DateTime(year, month, 1), roundedAmount));
          }

          monthlySales.sort((a, b) => a.date.compareTo(b.date));

          if (!isClosed) {
            emit(state.copyWith(
              totalProducts: db.productList.length,
              totalCustomers: db.customerList.length,
              totalManufacturers: db.manufacturerList.length,
              totalEmployees: db.employeeList.length,
              totalRevenue: totalRevenue,
              totalOrders: totalPaidOrders,
              unreadChats: unreadChats,
              recentOrders: recentOrdersList,
              monthlySales: monthlySales,
              isLoadingOverview: false,
              isLoadingChart: false,
            ));
          }
        }
      } catch (e) {
        if (!isClosed) {
          emit(state.copyWith(
            totalProducts: db.productList.length,
            totalCustomers: db.customerList.length,
            totalManufacturers: db.manufacturerList.length,
            totalEmployees: db.employeeList.length,
            isLoadingOverview: false,
            isLoadingChart: false,
          ));
        }
      }

      // Step 4: Category and top product data DISABLED on mobile due to memory constraints
      // These require getSalesInvoiceWithDetails for each invoice which causes OOM crash
      if (kIsWeb) {
        // Only process on web where memory is not as constrained
        final invoicesToProcess = paidInvoices.take(20).toList();
        final salesByCategory = <String, double>{};
        final Map<String, TopProductData> productSalesMap = {};

        for (var invoice in invoicesToProcess) {
          if (isClosed) break;
          try {
            final invoiceWithDetails = await Firebase()
                .getSalesInvoiceWithDetails(invoice.salesInvoiceID);

            for (var detail in invoiceWithDetails.details) {
              final category = detail.category.toString();
              final revenue = detail.quantity * detail.sellingPrice;
              salesByCategory[category] =
                  (salesByCategory[category] ?? 0) + revenue;

              final productID = detail.productID;
              final productName = detail.productName ?? 'Unknown Product';
              final quantity = detail.quantity;
              final productRevenue = detail.subtotal;

              if (productSalesMap.containsKey(productID)) {
                productSalesMap[productID]!.totalSales += quantity;
                productSalesMap[productID]!.totalRevenue += productRevenue;
              } else {
                productSalesMap[productID] = TopProductData(
                  productID: productID,
                  productName: productName,
                  totalSales: quantity,
                  totalRevenue: productRevenue,
                );
              }
            }
          } catch (e) {
            // Error processing invoice
          }
        }

        final topProductsList = productSalesMap.values
            .map((data) => TopProduct(
                  productID: data.productID,
                  productName: data.productName,
                  totalSales: data.totalSales,
                  totalRevenue: data.totalRevenue,
                ))
            .toList()
          ..sort((a, b) => b.totalSales.compareTo(a.totalSales));

        final topProducts = topProductsList.take(3).toList();

        if (!isClosed) {
          emit(state.copyWith(
            salesByCategory: salesByCategory,
            topProducts: topProducts,
          ));
        }
      }
    } catch (e) {
      // Error initializing dashboard
      // Optionally emit error state
      if (!isClosed) {
        emit(state.copyWith(
          isLoadingUsername: false,
          isLoadingOverview: false,
          isLoadingChart: false,
        ));
      }
    }
  }

  Future<void> _loadProductCounts() async {
    try {
      final productCountsData = await Firebase().getProductCounts();
      if (productCountsData != null && !isClosed) {
        final categoryCountsArray =
            productCountsData['categoryCounts'] as List<dynamic>? ?? [];
        final productCountsMap = <String, int>{};
        for (var item in categoryCountsArray) {
          final category = item['category'] as String? ?? 'Unknown';
          final count = (item['count'] as num?)?.toInt() ?? 0;
          productCountsMap[category] = count;
        }
        emit(state.copyWith(
          productCountsByCategory: productCountsMap,
          isLoadingProductCounts: false,
        ));
      } else if (!isClosed) {
        emit(state.copyWith(isLoadingProductCounts: false));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(isLoadingProductCounts: false));
      }
    }
  }

  void navigateToChatList() {
    // Navigation will be handled by the view
  }

  Future<BusinessReportData> generateBusinessReportData({
    required DateTime startDate,
    required DateTime endDate,
    CategoryEnum? categoryFilter,
  }) async {
    final firebase = Firebase();

    // Get all sales invoices
    final allSalesInvoices = await firebase.getSalesInvoices();

    // Filter by date range
    final salesInvoices = allSalesInvoices.where((invoice) {
      final invoiceDate = DateTime(
        invoice.date.year,
        invoice.date.month,
        invoice.date.day,
      );
      return invoiceDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          invoiceDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Get all incoming invoices
    final allIncomingInvoices = await firebase.getIncomingInvoices();

    // Filter by date range
    final incomingInvoices = allIncomingInvoices.where((invoice) {
      final invoiceDate = DateTime(
        invoice.date.year,
        invoice.date.month,
        invoice.date.day,
      );
      return invoiceDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
          invoiceDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();

    // Calculate revenue, costs and product stats (supports category filter)
    double totalRevenue = 0.0;
    double totalCosts = 0.0;
    double costOfGoodsSold = 0.0;
    int totalPaidOrders = 0;
    int totalItemsSold = 0;
    final revenueByDay = <String, double>{};
    final revenueByWeek = <String, double>{};
    final revenueByMonth = <String, double>{};
    final dailySalesTrend = <DailySalesData>[];
    final monthlySalesMap = <String, MonthlySalesData>{};
    final dailyCostsMap = <String, double>{};
    final monthlyCostsMap = <String, double>{};

    final salesByCategory = <String, double>{};
    final Map<String, TopProductData> productSalesMap = {};
    final Map<String, int> productCostMap =
        {}; // Total cost from incoming invoices
    final Map<String, int> productQuantityMap =
        {}; // Total quantity from incoming invoices
    final Set<String> includedProducts = {};
    final Map<String, double> productCostFromSales =
        {}; // Cost for sold products

    bool matchesCategory(String? detailCategoryName) {
      if (categoryFilter == null) return true;
      final parsed =
          CategoryEnumExtension.fromName(detailCategoryName ?? 'unknown');
      return parsed == categoryFilter;
    }

    // First, process ALL incoming invoices to build cost data (without category filter)
    // This ensures we have cost data available when processing sales
    for (var invoice in incomingInvoices) {
      if (invoice.status != PaymentStatus.paid) continue;

      final invoiceWithDetails = await firebase
          .getIncomingInvoiceWithDetails(invoice.incomingInvoiceID ?? '');

      for (var detail in invoiceWithDetails.details) {
        final cost = detail.importPrice * detail.quantity;
        productCostMap[detail.productID] =
            (productCostMap[detail.productID] ?? 0) + cost.toInt();
        productQuantityMap[detail.productID] =
            (productQuantityMap[detail.productID] ?? 0) + detail.quantity;
      }
    }

    // Now process sales invoices (cost data is now available)

    // Now process sales invoices (cost data is now available)
    for (var invoice in salesInvoices) {
      if (invoice.paymentStatus != PaymentStatus.paid) continue;

      final invoiceWithDetails =
          await firebase.getSalesInvoiceWithDetails(invoice.salesInvoiceID);

      double invoiceRevenue = 0.0;
      bool hasMatching = false;

      for (var detail in invoiceWithDetails.details) {
        if (!matchesCategory(detail.category)) continue;
        hasMatching = true;

        final catEnum = CategoryEnumExtension.fromName(detail.category ?? '');
        final categoryName =
            catEnum == CategoryEnum.empty ? 'Unknown' : catEnum.description;
        final revenue = detail.quantity * detail.sellingPrice;
        invoiceRevenue += revenue;
        totalItemsSold += detail.quantity;

        salesByCategory[categoryName] =
            (salesByCategory[categoryName] ?? 0) + revenue;

        final productID = detail.productID;
        final productName = detail.productName ?? 'Unknown Product';
        final quantity = detail.quantity;
        final revenue2 = detail.subtotal;

        includedProducts.add(productID);

        // Calculate cost using average cost per unit from incoming invoices
        // Average cost = total cost from incoming invoices / total quantity purchased
        final totalCostForProduct =
            productCostMap[productID]?.toDouble() ?? 0.0;
        final totalQuantityPurchased = productQuantityMap[productID] ?? 0;
        final averageCostPerUnit = totalQuantityPurchased > 0
            ? totalCostForProduct / totalQuantityPurchased
            : 0.0;

        // If no incoming invoice data, fetch product from database
        double costPerUnit = averageCostPerUnit;
        if (costPerUnit == 0) {
          // First try to find in product list
          var product =
              db.productList.where((p) => p.productID == productID).isNotEmpty
                  ? db.productList.firstWhere((p) => p.productID == productID)
                  : null;

          // If not found, fetch from database
          product ??= await firebase.getProduct(productID);

          // Use importPrice from product if available
          if (product != null && product.importPrice > 0) {
            costPerUnit = product.importPrice.toDouble();
          }
          // If still no cost data, use 0 (product might not have cost info)
        }

        final costContribution = costPerUnit * quantity;
        productCostFromSales[productID] =
            (productCostFromSales[productID] ?? 0) + costContribution;

        // Track costs per day and month for sales trends
        final dayKey =
            '${invoice.date.year}-${invoice.date.month.toString().padLeft(2, '0')}-${invoice.date.day.toString().padLeft(2, '0')}';
        dailyCostsMap[dayKey] = (dailyCostsMap[dayKey] ?? 0) + costContribution;

        final monthKey =
            '${invoice.date.year}-${invoice.date.month.toString().padLeft(2, '0')}';
        monthlyCostsMap[monthKey] =
            (monthlyCostsMap[monthKey] ?? 0) + costContribution;

        if (productSalesMap.containsKey(productID)) {
          productSalesMap[productID]!.totalSales += quantity;
          productSalesMap[productID]!.totalRevenue += revenue2;
        } else {
          productSalesMap[productID] = TopProductData(
            productID: productID,
            productName: productName,
            totalSales: quantity,
            totalRevenue: revenue2,
          );
        }
      }

      if (!hasMatching) continue;

      totalRevenue += invoiceRevenue;
      totalPaidOrders++;

      // Revenue by time period (using matched revenue)
      final dayKey =
          '${invoice.date.year}-${invoice.date.month.toString().padLeft(2, '0')}-${invoice.date.day.toString().padLeft(2, '0')}';
      revenueByDay[dayKey] = (revenueByDay[dayKey] ?? 0) + invoiceRevenue;

      final weekKey = '${invoice.date.year}-W${_getWeekNumber(invoice.date)}';
      revenueByWeek[weekKey] = (revenueByWeek[weekKey] ?? 0) + invoiceRevenue;

      final monthKey =
          '${invoice.date.year}-${invoice.date.month.toString().padLeft(2, '0')}';
      revenueByMonth[monthKey] =
          (revenueByMonth[monthKey] ?? 0) + invoiceRevenue;

      // Daily sales trend
      final dayStart =
          DateTime(invoice.date.year, invoice.date.month, invoice.date.day);
      final existingDay = dailySalesTrend.firstWhere(
        (d) =>
            d.date.year == dayStart.year &&
            d.date.month == dayStart.month &&
            d.date.day == dayStart.day,
        orElse: () =>
            DailySalesData(date: dayStart, revenue: 0, costs: 0, profit: 0),
      );
      if (existingDay.revenue == 0) {
        final dayCost = dailyCostsMap[dayKey] ?? 0.0;
        dailySalesTrend.add(DailySalesData(
            date: dayStart,
            revenue: invoiceRevenue,
            costs: dayCost,
            profit: invoiceRevenue - dayCost));
      } else {
        existingDay.revenue += invoiceRevenue;
        final dayCost = dailyCostsMap[dayKey] ?? 0.0;
        existingDay.costs = dayCost;
        existingDay.profit = existingDay.revenue - dayCost;
      }

      // Monthly sales trend
      final monthStart = DateTime(invoice.date.year, invoice.date.month, 1);
      final monthKey2 = '${monthStart.year}-${monthStart.month}';
      if (!monthlySalesMap.containsKey(monthKey2)) {
        monthlySalesMap[monthKey2] = MonthlySalesData(
            month: monthStart, revenue: 0, costs: 0, profit: 0);
      }
      monthlySalesMap[monthKey2]!.revenue += invoiceRevenue;
      final monthCost = monthlyCostsMap[monthKey] ?? 0.0;
      monthlySalesMap[monthKey2]!.costs = monthCost;
      monthlySalesMap[monthKey2]!.profit =
          monthlySalesMap[monthKey2]!.revenue - monthCost;
    }

    // Calculate total costs from sold products
    totalCosts =
        productCostFromSales.values.fold(0.0, (sum, cost) => sum + cost);
    costOfGoodsSold = totalCosts;

    final topProducts = productSalesMap.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final topProductsByQuantity = productSalesMap.values.toList()
      ..sort((a, b) => b.totalSales.compareTo(a.totalSales));

    // Calculate top products by profit margin
    final topProductsByProfitMargin = productSalesMap.entries.map((entry) {
      final cost = productCostFromSales[entry.key] ??
          productCostMap[entry.key]?.toDouble() ??
          0.0;
      return BusinessReportTopProductData(
        productID: entry.value.productID,
        productName: entry.value.productName,
        totalSales: entry.value.totalSales,
        totalRevenue: entry.value.totalRevenue,
        totalCost: cost,
      );
    }).toList()
      ..sort((a, b) {
        final aMargin =
            a.totalRevenue > 0 ? ((a.profit) / a.totalRevenue * 100) : 0.0;
        final bMargin =
            b.totalRevenue > 0 ? ((b.profit) / b.totalRevenue * 100) : 0.0;
        return bMargin.compareTo(aMargin);
      });

    // Customer insights
    final customerOrderMap = <String, CustomerOrderData>{};
    final allCustomers = await firebase.getCustomers();
    final customerFirstOrderMap = <String, DateTime>{};

    // Get all historical invoices to determine new vs returning customers
    final allHistoricalInvoices = await firebase.getSalesInvoices();
    for (var invoice in allHistoricalInvoices) {
      if (invoice.paymentStatus == PaymentStatus.paid) {
        if (!customerFirstOrderMap.containsKey(invoice.customerID)) {
          customerFirstOrderMap[invoice.customerID] = invoice.date;
        } else if (invoice.date
            .isBefore(customerFirstOrderMap[invoice.customerID]!)) {
          customerFirstOrderMap[invoice.customerID] = invoice.date;
        }
      }
    }

    // Track unique customers using Sets
    final Set<String> newCustomerIDs = {};
    final Set<String> returningCustomerIDs = {};

    for (var invoice in salesInvoices) {
      if (invoice.paymentStatus == PaymentStatus.paid) {
        final firstOrderDate = customerFirstOrderMap[invoice.customerID];
        if (firstOrderDate != null &&
            firstOrderDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            firstOrderDate.isBefore(endDate.add(const Duration(days: 1)))) {
          newCustomerIDs.add(invoice.customerID);
        } else {
          returningCustomerIDs.add(invoice.customerID);
        }

        if (!customerOrderMap.containsKey(invoice.customerID)) {
          final customer = allCustomers.firstWhere(
            (c) => c.customerID == invoice.customerID,
            orElse: () {
              // Return a default customer if not found
              return Customer(
                customerID: invoice.customerID,
                customerName: 'Unknown',
                email: '',
                phoneNumber: '',
              );
            },
          );
          customerOrderMap[invoice.customerID] = CustomerOrderData(
            customerID: invoice.customerID,
            customerName: customer.customerName,
            totalSpending: invoice.totalPrice,
            orderCount: 1,
          );
        } else {
          customerOrderMap[invoice.customerID]!.totalSpending +=
              invoice.totalPrice;
          customerOrderMap[invoice.customerID]!.orderCount++;
        }
      }
    }

    final topCustomers = customerOrderMap.values.toList()
      ..sort((a, b) => b.totalSpending.compareTo(a.totalSpending));

    // Use the unique customer counts from Sets
    final int newCustomers = newCustomerIDs.length;
    final int returningCustomers = returningCustomerIDs.length;
    final totalCustomersInPeriod = customerOrderMap.length;
    final customerRetentionRate = totalCustomersInPeriod > 0
        ? (returningCustomers / totalCustomersInPeriod * 100)
        : 0.0;

    // Inventory insights
    int totalStockValue = 0;
    int lowStockItemsCount = 0;
    final lowStockItems = <InventoryItemData>[];
    const minStockThreshold = 10;

    for (var product in db.productList) {
      final stockValue = product.stock * product.importPrice;
      totalStockValue += stockValue;
      if (product.stock < minStockThreshold) {
        lowStockItemsCount++;
        lowStockItems.add(InventoryItemData(
          productID: product.productID ?? '',
          productName: product.productName,
          currentStock: product.stock,
          minStockThreshold: minStockThreshold,
        ));
      }
    }

    // Calculate inventory turnover rate: COGS / Average Inventory
    // Average Inventory = (Beginning Inventory + Ending Inventory) / 2
    // Since we only have current inventory (ending), we use current value as average
    final averageInventory = totalStockValue.toDouble();
    final inventoryTurnoverRate =
        averageInventory > 0 ? (costOfGoodsSold / averageInventory) : 0.0;

    // Calculate average items per order
    final averageItemsPerOrder =
        totalPaidOrders > 0 ? (totalItemsSold / totalPaidOrders) : 0.0;

    // Sort daily and monthly trends
    dailySalesTrend.sort((a, b) => a.date.compareTo(b.date));
    final monthlySalesTrend = monthlySalesMap.values.toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    return BusinessReportData(
      startDate: startDate,
      endDate: endDate,
      totalRevenue: totalRevenue,
      totalCosts: totalCosts,
      totalOrders: totalPaidOrders,
      totalProducts: db.productList.length,
      totalCustomers: db.customerList.length,
      salesByCategory: salesByCategory,
      selectedCategoryLabel: categoryFilter?.description ?? 'All',
      topProducts: topProducts
          .map((data) => BusinessReportTopProductData(
                productID: data.productID,
                productName: data.productName,
                totalSales: data.totalSales,
                totalRevenue: data.totalRevenue,
                totalCost: productCostFromSales[data.productID] ?? 0.0,
              ))
          .toList(),
      salesInvoices: salesInvoices,
      incomingInvoices: incomingInvoices,
      username: db.username ?? 'Unknown',
      revenueByDay: revenueByDay,
      revenueByWeek: revenueByWeek,
      revenueByMonth: revenueByMonth,
      costOfGoodsSold: costOfGoodsSold,
      operatingExpenses: 0.0, // Not tracked separately in current system
      newCustomers: newCustomers,
      returningCustomers: returningCustomers,
      customerRetentionRate: customerRetentionRate,
      topCustomers: topCustomers
          .map((c) => CustomerSpendingData(
                customerID: c.customerID,
                customerName: c.customerName,
                totalSpending: c.totalSpending,
                orderCount: c.orderCount,
              ))
          .toList(),
      topProductsByQuantity: topProductsByQuantity.map((data) {
        // Try productCostFromSales first (for filtered products), then fall back to productCostMap
        final cost = productCostFromSales[data.productID] ??
            (productCostMap[data.productID]?.toDouble() ?? 0.0);
        return BusinessReportTopProductData(
          productID: data.productID,
          productName: data.productName,
          totalSales: data.totalSales,
          totalRevenue: data.totalRevenue,
          totalCost: cost,
        );
      }).toList(),
      topProductsByProfitMargin: topProductsByProfitMargin,
      totalStockValue: totalStockValue,
      lowStockItemsCount: lowStockItemsCount,
      lowStockItems: lowStockItems,
      inventoryTurnoverRate: inventoryTurnoverRate,
      averageItemsPerOrder: averageItemsPerOrder,
      totalItemsSold: totalItemsSold,
      dailySalesTrend: dailySalesTrend,
      monthlySalesTrend: monthlySalesTrend,
    );
  }

  int _getWeekNumber(DateTime date) {
    final firstJan = DateTime(date.year, 1, 1);
    final daysSinceFirstJan = date.difference(firstJan).inDays;
    return ((daysSinceFirstJan + firstJan.weekday) / 7).ceil();
  }
}

class CustomerOrderData {
  final String customerID;
  final String customerName;
  double totalSpending;
  int orderCount;

  CustomerOrderData({
    required this.customerID,
    required this.customerName,
    required this.totalSpending,
    required this.orderCount,
  });
}
