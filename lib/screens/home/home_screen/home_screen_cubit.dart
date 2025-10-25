import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import '../../../data/database/database.dart';
import '../../../data/firebase/firebase.dart';
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
}
