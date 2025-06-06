import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import '../../../data/database/database.dart';
import '../../../data/firebase/firebase.dart';
import 'home_screen_state.dart';

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

      await db.getUser();
      // Emit new state with loaded data
      emit(state.copyWith(
        username: db.username ?? '',
        totalProducts: db.productList.length,
        totalCustomers: db.customerList.length,
        totalRevenue: totalRevenue,
        totalOrders: totalPaidOrders,
        salesByCategory: salesByCategory,
        monthlySales: monthlySales,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing dashboard: $e');
      } // Lỗi khởi tạo dashboard
      // Optionally emit error state
    }
  }
}
