import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';
import '../../../data/database/database.dart';
import '../../../data/firebase/firebase.dart';
import '../../../services/reports/business_report_pdf_service.dart';
import '../../../objects/customer.dart';
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
      // Đợi database khởi tạo xong
      await db.initialize();

      // Step 1: Load username first
      await db.getUser();
      if (!isClosed) {
        emit(state.copyWith(
          username: db.username ?? '',
          isLoadingUsername: false,
        ));
      }

      // Step 2: Load overview data (revenue, orders, products, customers, etc.)
      final salesInvoices = await Firebase().getSalesInvoices();

      // Tính tổng doanh thu từ các hóa đơn đã thanh toán
      double totalRevenue = 0.0;
      int totalPaidOrders = 0;
      for (var invoice in salesInvoices) {
        if (invoice.paymentStatus == PaymentStatus.paid) {
          totalRevenue += invoice.totalPrice;
          totalPaidOrders++;
        }
      }

      // Thay đổi Map để lưu doanh thu theo category
      final salesByCategory = <String, double>{};

      for (var invoice in salesInvoices) {
        if (invoice.paymentStatus == PaymentStatus.paid) {
          // Lấy chi tiết của từng hóa đơn
          final invoiceWithDetails = await Firebase()
              .getSalesInvoiceWithDetails(invoice.salesInvoiceID);
          for (var detail in invoiceWithDetails.details) {
            final category = detail.category.toString();
            // Tính doanh thu = số lượng * giá bán
            final revenue = detail.quantity * detail.sellingPrice;
            salesByCategory[category] =
                (salesByCategory[category] ?? 0) + revenue;
          }
        }
      }

      // Get unread chats count
      final unreadChats = await Firebase().getUnreadChatsCount();

      // Get recent orders (last 5 orders, sorted by date descending)
      final recentOrders = salesInvoices
          .where((invoice) => invoice.paymentStatus == PaymentStatus.paid)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      final recentOrdersList = recentOrders.take(5).toList();

      // Calculate top products from sales data
      final Map<String, TopProductData> productSalesMap = {};

      for (var invoice in salesInvoices) {
        if (invoice.paymentStatus == PaymentStatus.paid) {
          // Get invoice details to access product information
          final invoiceWithDetails = await Firebase()
              .getSalesInvoiceWithDetails(invoice.salesInvoiceID);

          for (var detail in invoiceWithDetails.details) {
            final productID = detail.productID;
            final productName = detail.productName ?? 'Unknown Product';
            final quantity = detail.quantity;
            final revenue = detail.subtotal;

            if (productSalesMap.containsKey(productID)) {
              productSalesMap[productID]!.totalSales += quantity;
              productSalesMap[productID]!.totalRevenue += revenue;
            } else {
              productSalesMap[productID] = TopProductData(
                productID: productID,
                productName: productName,
                totalSales: quantity,
                totalRevenue: revenue,
              );
            }
          }
        }
      }

      // Convert to TopProduct list and sort by total sales
      final topProductsList = productSalesMap.values
          .map((data) => TopProduct(
                productID: data.productID,
                productName: data.productName,
                totalSales: data.totalSales,
                totalRevenue: data.totalRevenue,
              ))
          .toList()
        ..sort((a, b) => b.totalSales.compareTo(a.totalSales));

      // Take top 3 products
      final topProducts = topProductsList.take(3).toList();

      // Emit overview data
      if (!isClosed) {
        emit(state.copyWith(
          totalProducts: db.productList.length,
          totalCustomers: db.customerList.length,
          totalRevenue: totalRevenue,
          totalOrders: totalPaidOrders,
          salesByCategory: salesByCategory,
          unreadChats: unreadChats,
          recentOrders: recentOrdersList,
          topProducts: topProducts,
          isLoadingOverview: false,
        ));
      }

      // Step 3: Load chart data (monthly sales)
      // Tính doanh thu theo ngày (lưu tất cả các ngày có dữ liệu để có thể hiển thị theo ngày hoặc tổng hợp theo tháng)
      final List<SalesData> monthlySales = [];
      final Map<String, double> dailySalesMap = <String, double>{};

      // Lưu tất cả các ngày có doanh thu
      for (var invoice in salesInvoices) {
        if (invoice.paymentStatus == PaymentStatus.paid) {
          final dayKey =
              '${invoice.date.year}-${invoice.date.month.toString().padLeft(2, '0')}-${invoice.date.day.toString().padLeft(2, '0')}';
          dailySalesMap[dayKey] =
              (dailySalesMap[dayKey] ?? 0) + invoice.totalPrice;
        }
      }

      // Chuyển đổi map thành list SalesData với đầy đủ thông tin ngày
      // Nhân với 1000 để phù hợp với format VND (theo Helper.toCurrencyFormat)
      // Làm tròn để tránh lỗi floating point precision
      for (var entry in dailySalesMap.entries) {
        final parts = entry.key.split('-');
        final year = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final day = int.parse(parts[2]);
        final roundedAmount = (entry.value * 1000).roundToDouble();
        monthlySales.add(SalesData(DateTime(year, month, day), roundedAmount));
      }

      // Sắp xếp theo ngày
      monthlySales.sort((a, b) => a.date.compareTo(b.date));

      // Emit chart data
      if (!isClosed) {
        emit(state.copyWith(
          monthlySales: monthlySales,
          isLoadingChart: false,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing dashboard: $e');
      } // Lỗi khởi tạo dashboard
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
        monthlyCostsMap[monthKey] = (monthlyCostsMap[monthKey] ?? 0) + costContribution;

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
      monthlySalesMap[monthKey2]!.profit = monthlySalesMap[monthKey2]!.revenue - monthCost;
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
      topProductsByQuantity: topProductsByQuantity
          .map((data) {
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
          })
          .toList(),
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
