import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import '../../../../objects/invoice_related/sales_invoice_detail.dart';
import 'sales_edit_state.dart';

class SalesEditCubit extends Cubit<SalesEditState> {
  final Firebase _firebase = Firebase();

  SalesEditCubit(SalesInvoice invoice)
      : super(SalesEditState(
          invoice: invoice,
          selectedPaymentStatus: invoice.paymentStatus,
          selectedSalesStatus: invoice.salesStatus,
        ));

  void updatePaymentStatus(PaymentStatus status) {
    emit(state.copyWith(selectedPaymentStatus: status));
  }

  void updateSalesStatus(SalesStatus status) {
    emit(state.copyWith(selectedSalesStatus: status));
  }

  Future<SalesInvoice?> saveChanges() async {
    emit(state.copyWith(isLoading: true));
    try {
      final updatedInvoice = state.invoice;
      await _firebase.updateSalesInvoice(updatedInvoice);
      
      // Cập nhật chi tiết hóa đơn
      for (var detail in updatedInvoice.details) {
        await _firebase.updateSalesInvoiceDetail(detail);
      }
      
      emit(state.copyWith(
        invoice: updatedInvoice,
        isLoading: false,
      ));
      return updatedInvoice;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      return null;
    }
  }

  Future<void> updateInvoiceDetail(SalesInvoiceDetail updatedDetail) async {
    try {
      // Lấy chi tiết cũ để tính toán sự thay đổi
      final oldDetail = state.invoice.details.firstWhere(
        (d) => d.salesInvoiceDetailID == updatedDetail.salesInvoiceDetailID
      );
      
      // Tính toán sự thay đổi số lượng
      final quantityChange = updatedDetail.quantity - oldDetail.quantity;
      
      // Cập nhật chi tiết hóa đơn
      await _firebase.updateSalesInvoiceDetail(updatedDetail);

      // Cập nhật stock và sales của sản phẩm
      await _firebase.updateProductStockAndSales(
        updatedDetail.productID,
        -quantityChange, // Giảm stock
        quantityChange,  // Tăng sales
      );

      // Cập nhật state với chi tiết mới
      final details = List<SalesInvoiceDetail>.from(state.invoice.details);
      final index = details.indexWhere(
        (d) => d.salesInvoiceDetailID == updatedDetail.salesInvoiceDetailID
      );
      
      if (index != -1) {
        details[index] = updatedDetail;
        
        final newTotalPrice = details.fold<double>(
          0.0, 
          (sum, detail) => sum + (detail.subtotal),
        );

        final updatedInvoice = state.invoice.copyWith(
          details: details,
          totalPrice: newTotalPrice,
        );

        emit(state.copyWith(invoice: updatedInvoice));
      }
    } catch (e) {
      print('Error updating invoice detail: $e');
      rethrow;
    }
  }

  Future<void> removeInvoiceDetail(SalesInvoiceDetail detail) async {
    try {
      // Xóa chi tiết hóa đơn
      await _firebase.deleteSalesInvoiceDetail(detail.salesInvoiceDetailID!);

      // Hoàn lại stock và giảm sales của sản phẩm
      await _firebase.updateProductStockAndSales(
        detail.productID,
        detail.quantity,  // Tăng stock
        -detail.quantity, // Giảm sales
      );

      // Cập nhật state
      final details = List<SalesInvoiceDetail>.from(state.invoice.details)
        ..removeWhere((d) => d.salesInvoiceDetailID == detail.salesInvoiceDetailID);

      final newTotalPrice = details.fold<double>(
        0.0,
        (sum, detail) => sum + (detail.subtotal),
      );

      final updatedInvoice = state.invoice.copyWith(
        details: details,
        totalPrice: newTotalPrice,
      );

      emit(state.copyWith(invoice: updatedInvoice));
    } catch (e) {
      print('Error removing invoice detail: $e');
      rethrow;
    }
  }
} 