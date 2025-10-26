import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../../../enums/invoice_related/payment_status.dart';
import 'incoming_detail_state.dart';
import 'incoming_detail_pdf_service.dart';

// Import for web platform
import 'dart:html' as html show Blob, Url, AnchorElement;

class IncomingDetailCubit extends Cubit<IncomingDetailState> {
  final _firebase = Firebase();
  final IncomingInvoice invoice;

  IncomingDetailCubit(this.invoice) : super(IncomingDetailState(invoice: invoice)) {
    loadDetails();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final userRole = await _firebase.getUserRole();
      if (!isClosed) {
        emit(state.copyWith(userRole: userRole));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'Error loading user role: $e')); // Lỗi khi load user role
      }
    }
  }

  Future<void> loadDetails() async {
    if (isClosed) return;
    emit(state.copyWith(isLoading: true));

    try {
      // Load manufacturer
      final manufacturer = await _firebase.getManufacturerById(invoice.manufacturerID);
      
      // Load all products referenced in details
      final Map<String, Product> products = {};
      final allProducts = await _firebase.getProducts();
      
      for (var detail in invoice.details) {
        final product = allProducts.firstWhere(
          (p) => p.productID == detail.productID,
          orElse: () => throw Exception('Product not found: ${detail.productID}'), // Không tìm thấy sản phẩm
        );
        products[detail.productID] = product;
      }

      if (!isClosed) {
        emit(state.copyWith(
          manufacturer: manufacturer,
          products: products,
          isLoading: false,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          errorMessage: 'Error loading details: $e', // Lỗi khi load chi tiết sản phẩm
          isLoading: false,
        ));
      }
    }
  }

  void clearError() {
    if (!isClosed) {
      emit(state.copyWith(errorMessage: null));
    }
  }

  Future<void> updatePaymentStatus(PaymentStatus newStatus) async {
    try {
      final updatedInvoice = IncomingInvoice(
        incomingInvoiceID: invoice.incomingInvoiceID,
        manufacturerID: invoice.manufacturerID,
        date: invoice.date,
        status: newStatus,
        totalPrice: invoice.totalPrice,
        details: invoice.details,
      );

      await _firebase.updateIncomingInvoice(updatedInvoice);
      if (!isClosed) {
        emit(state.copyWith(invoice: updatedInvoice));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'Error updating payment status: $e')); // Lỗi khi cập nhật trạng thái thanh toán
      }
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      return await _firebase.getProduct(productId);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading product: $e');
      } // Lỗi khi load sản phẩm
      return null;
    }
  }

  Future<void> printInvoice() async {
    try {
      // Generate PDF
      final pdf = await IncomingInvoicePdfService.generatePdf(
        invoice: state.invoice,
        manufacturer: state.manufacturer,
        products: state.products,
      );

      // Download PDF
      final bytes = await pdf.save();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'Invoice_${state.invoice.incomingInvoiceID}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading invoice: $e');
      }
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'Error downloading invoice: $e'));
      }
    }
  }

  Future<void> shareInvoice() async {
    try {
      // Generate PDF
      final pdf = await IncomingInvoicePdfService.generatePdf(
        invoice: state.invoice,
        manufacturer: state.manufacturer,
        products: state.products,
      );

      // Download PDF (web doesn't support share API)
      final bytes = await pdf.save();
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'Invoice_${state.invoice.incomingInvoiceID}.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (kDebugMode) {
        print('Error downloading invoice: $e');
      }
      if (!isClosed) {
        emit(state.copyWith(errorMessage: 'Error downloading invoice: $e'));
      }
    }
  }
}
