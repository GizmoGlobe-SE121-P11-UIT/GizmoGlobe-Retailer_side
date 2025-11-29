import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
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

      // Lấy danh sách sales invoices từ Firestore
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

      // Tính doanh thu theo tháng
      final List<SalesData> monthlySales = [];
      final now = DateTime.now();
      for (var i = 11; i >= 0; i--) {
        final month = DateTime(now.year, now.month - i, 1);
        double salesInMonth = 0.0;

        for (var invoice in salesInvoices) {
          if (invoice.paymentStatus == PaymentStatus.paid &&
              invoice.date.year == month.year &&
              invoice.date.month == month.month) {
            salesInMonth += invoice.totalPrice;
          }
        }

        monthlySales.add(SalesData(month, salesInMonth));
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

      await db.getUser();
      // Emit new state with loaded data - check if cubit is still open
      if (!isClosed) {
        emit(state.copyWith(
          username: db.username ?? '',
          totalProducts: db.productList.length,
          totalCustomers: db.customerList.length,
          totalRevenue: totalRevenue,
          totalOrders: totalPaidOrders,
          salesByCategory: salesByCategory,
          monthlySales: monthlySales,
          unreadChats: unreadChats,
          recentOrders: recentOrdersList,
          topProducts: topProducts,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing dashboard: $e');
      } // Lỗi khởi tạo dashboard
      // Optionally emit error state
    }
  }

  void navigateToChatList() {
    // Navigation will be handled by the view
  }

  Future<BusinessReportData> generateBusinessReportData({
    required DateTime startDate,
    required DateTime endDate,
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

    // Calculate revenue from paid sales invoices
    double totalRevenue = 0.0;
    int totalPaidOrders = 0;
    int totalItemsSold = 0;
    final revenueByDay = <String, double>{};
    final revenueByWeek = <String, double>{};
    final revenueByMonth = <String, double>{};
    final dailySalesTrend = <DailySalesData>[];
    final monthlySalesMap = <String, MonthlySalesData>{};

    for (var invoice in salesInvoices) {
      if (invoice.paymentStatus == PaymentStatus.paid) {
        totalRevenue += invoice.totalPrice;
        totalPaidOrders++;

        // Revenue by time period
        final dayKey =
            '${invoice.date.year}-${invoice.date.month.toString().padLeft(2, '0')}-${invoice.date.day.toString().padLeft(2, '0')}';
        revenueByDay[dayKey] = (revenueByDay[dayKey] ?? 0) + invoice.totalPrice;

        final weekKey = '${invoice.date.year}-W${_getWeekNumber(invoice.date)}';
        revenueByWeek[weekKey] =
            (revenueByWeek[weekKey] ?? 0) + invoice.totalPrice;

        final monthKey =
            '${invoice.date.year}-${invoice.date.month.toString().padLeft(2, '0')}';
        revenueByMonth[monthKey] =
            (revenueByMonth[monthKey] ?? 0) + invoice.totalPrice;

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
          dailySalesTrend.add(DailySalesData(
              date: dayStart,
              revenue: invoice.totalPrice,
              costs: 0,
              profit: invoice.totalPrice));
        } else {
          existingDay.revenue += invoice.totalPrice;
          existingDay.profit += invoice.totalPrice;
        }

        // Monthly sales trend
        final monthStart = DateTime(invoice.date.year, invoice.date.month, 1);
        final monthKey2 = '${monthStart.year}-${monthStart.month}';
        if (!monthlySalesMap.containsKey(monthKey2)) {
          monthlySalesMap[monthKey2] = MonthlySalesData(
              month: monthStart, revenue: 0, costs: 0, profit: 0);
        }
        monthlySalesMap[monthKey2]!.revenue += invoice.totalPrice;
        monthlySalesMap[monthKey2]!.profit += invoice.totalPrice;
      }
    }

    // Calculate costs from paid incoming invoices
    double totalCosts = 0.0;
    double costOfGoodsSold = 0.0;
    for (var invoice in incomingInvoices) {
      if (invoice.status == PaymentStatus.paid) {
        totalCosts += invoice.totalPrice;
        costOfGoodsSold +=
            invoice.totalPrice; // COGS = all incoming invoice costs

        // Update daily and monthly trends with costs
        final dayStart =
            DateTime(invoice.date.year, invoice.date.month, invoice.date.day);
        final dayTrend = dailySalesTrend.firstWhere(
          (d) =>
              d.date.year == dayStart.year &&
              d.date.month == dayStart.month &&
              d.date.day == dayStart.day,
          orElse: () =>
              DailySalesData(date: dayStart, revenue: 0, costs: 0, profit: 0),
        );
        dayTrend.costs += invoice.totalPrice;
        dayTrend.profit -= invoice.totalPrice;

        final monthStart = DateTime(invoice.date.year, invoice.date.month, 1);
        final monthKey2 = '${monthStart.year}-${monthStart.month}';
        if (monthlySalesMap.containsKey(monthKey2)) {
          monthlySalesMap[monthKey2]!.costs += invoice.totalPrice;
          monthlySalesMap[monthKey2]!.profit -= invoice.totalPrice;
        }
      }
    }

    // Calculate sales by category and top products
    final salesByCategory = <String, double>{};
    final Map<String, TopProductData> productSalesMap = {};
    final Map<String, int> productCostMap = {}; // For profit margin calculation

    for (var invoice in salesInvoices) {
      if (invoice.paymentStatus == PaymentStatus.paid) {
        final invoiceWithDetails =
            await firebase.getSalesInvoiceWithDetails(invoice.salesInvoiceID);
        for (var detail in invoiceWithDetails.details) {
          totalItemsSold += detail.quantity;

          final category = detail.category?.toString() ?? 'Unknown';
          final revenue = detail.quantity * detail.sellingPrice;
          salesByCategory[category] =
              (salesByCategory[category] ?? 0) + revenue;

          final productID = detail.productID;
          final productName = detail.productName ?? 'Unknown Product';
          final quantity = detail.quantity;
          final revenue2 = detail.subtotal;

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
      }
    }

    // Get product costs for profit margin calculation
    for (var invoice in incomingInvoices) {
      if (invoice.status == PaymentStatus.paid) {
        final invoiceWithDetails = await firebase
            .getIncomingInvoiceWithDetails(invoice.incomingInvoiceID ?? '');
        for (var detail in invoiceWithDetails.details) {
          productCostMap[detail.productID] =
              (productCostMap[detail.productID] ?? 0) +
                  (detail.importPrice * detail.quantity).toInt();
        }
      }
    }

    final topProducts = productSalesMap.values.toList()
      ..sort((a, b) => b.totalRevenue.compareTo(a.totalRevenue));

    final topProductsByQuantity = productSalesMap.values.toList()
      ..sort((a, b) => b.totalSales.compareTo(a.totalSales));

    // Calculate top products by profit margin
    final topProductsByProfitMargin = productSalesMap.entries.map((entry) {
      return BusinessReportTopProductData(
        productID: entry.value.productID,
        productName: entry.value.productName,
        totalSales: entry.value.totalSales,
        totalRevenue: entry.value.totalRevenue,
      );
    }).toList()
      ..sort((a, b) {
        final aCost = productCostMap[a.productID]?.toDouble() ?? 0.0;
        final bCost = productCostMap[b.productID]?.toDouble() ?? 0.0;
        final aMargin = a.totalRevenue > 0
            ? ((a.totalRevenue - aCost) / a.totalRevenue * 100)
            : 0.0;
        final bMargin = b.totalRevenue > 0
            ? ((b.totalRevenue - bCost) / b.totalRevenue * 100)
            : 0.0;
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

    int newCustomers = 0;
    int returningCustomers = 0;
    for (var invoice in salesInvoices) {
      if (invoice.paymentStatus == PaymentStatus.paid) {
        final firstOrderDate = customerFirstOrderMap[invoice.customerID];
        if (firstOrderDate != null &&
            firstOrderDate
                .isAfter(startDate.subtract(const Duration(days: 1))) &&
            firstOrderDate.isBefore(endDate.add(const Duration(days: 1)))) {
          newCustomers++;
        } else {
          returningCustomers++;
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

    // Calculate inventory turnover rate (simplified: COGS / Average Inventory)
    final averageInventory = totalStockValue / 2; // Simplified calculation
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
      topProducts: topProducts
          .map((data) => BusinessReportTopProductData(
                productID: data.productID,
                productName: data.productName,
                totalSales: data.totalSales,
                totalRevenue: data.totalRevenue,
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
          .map((data) => BusinessReportTopProductData(
                productID: data.productID,
                productName: data.productName,
                totalSales: data.totalSales,
                totalRevenue: data.totalRevenue,
              ))
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
