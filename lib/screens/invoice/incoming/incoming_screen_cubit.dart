import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice.dart';
import '../../../enums/invoice_related/payment_status.dart';
import 'incoming_screen_state.dart';

class IncomingScreenCubit extends Cubit<IncomingScreenState> {
  final _firebase = Firebase();
  late final Stream<List<IncomingInvoice>> _invoicesStream;
  StreamSubscription<List<IncomingInvoice>>? _subscription;

  IncomingScreenCubit() : super(const IncomingScreenState()) {
    _invoicesStream = _firebase.incomingInvoicesStream();
    _listenToInvoices();
    loadInvoices();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final userRole = await _firebase.getUserRole();
      emit(state.copyWith(userRole: userRole));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user role: $e');
      } // Lỗi load user role
    }
  }

  void _listenToInvoices() {
    _subscription = _invoicesStream.listen((invoices) {
      if (state.searchQuery.isEmpty) {
        emit(state.copyWith(invoices: invoices));
      } else {
        searchInvoices(state.searchQuery);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> loadInvoices() async {
    emit(state.copyWith(isLoading: true));
    try {
      final invoices = await _firebase.getIncomingInvoices();
      emit(state.copyWith(
        invoices: invoices,
        isLoading: false,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading incoming invoices: $e');
      } // Lỗi lấy hóa đơn
      emit(state.copyWith(isLoading: false));
    }
  }

  void searchInvoices(String query) {
    emit(state.copyWith(searchQuery: query));
    
    if (query.isEmpty) {
      loadInvoices();
      return;
    }

    final filteredInvoices = state.invoices.where((invoice) {
      final searchQuery = query.toLowerCase();
      return invoice.manufacturerID.toLowerCase().contains(searchQuery) ||
          invoice.incomingInvoiceID!.toLowerCase().contains(searchQuery);
    }).toList();

    emit(state.copyWith(invoices: filteredInvoices));
  }

  void setSelectedIndex(int? index) {
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> updateIncomingInvoice(IncomingInvoice invoice) async {
    try {
      await _firebase.updateIncomingInvoice(invoice);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating incoming invoice: $e');
      } // Lỗi cập nhật hóa đơn
    }
  }

  Future<String?> createIncomingInvoice(IncomingInvoice invoice) async {
    try {
      final invoiceId = await _firebase.createIncomingInvoice(invoice);
      return invoiceId;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating incoming invoice: $e');
      } // Lỗi tạo hóa đơn
      return null;
    }
  }

  Future<void> deleteIncomingInvoice(String invoiceId) async {
    try {
      await _firebase.deleteIncomingInvoice(invoiceId);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting incoming invoice: $e');
      } // Lỗi xóa hóa đơn
    }
  }

  Future<IncomingInvoice?> getInvoiceWithDetails(String invoiceId) async {
    try {
      return await _firebase.getIncomingInvoiceWithDetails(invoiceId);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting invoice details: $e');
      } // Lỗi lấy chi tiết hóa đơn
      return null;
    }
  }

  Future<void> quickUpdatePaymentStatus(String invoiceId, PaymentStatus newStatus) async {
    try {
      final invoice = state.invoices.firstWhere((inv) => inv.incomingInvoiceID == invoiceId);
      final updatedInvoice = IncomingInvoice(
        incomingInvoiceID: invoice.incomingInvoiceID,
        manufacturerID: invoice.manufacturerID,
        date: invoice.date,
        status: newStatus,
        totalPrice: invoice.totalPrice,
        details: invoice.details,
      );

      await _firebase.updateIncomingInvoice(updatedInvoice);
      // Refresh sẽ được xử lý thông qua stream listener
    } catch (e) {
      if (kDebugMode) {
        print('Error updating payment status: $e');
      } // Lỗi cập nhật trạng thái thanh toán
    }
  }

  void sortInvoices(SortField field, [SortOrder? order]) {
    final currentOrder = order ?? 
      (state.sortField == field ? 
        (state.sortOrder == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending)
        : SortOrder.descending);

    final sortedInvoices = List<IncomingInvoice>.from(state.invoices);

    switch (field) {
      case SortField.date:
        sortedInvoices.sort((a, b) => currentOrder == SortOrder.ascending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date));
        break;
      case SortField.totalPrice:
        sortedInvoices.sort((a, b) => currentOrder == SortOrder.ascending
            ? a.totalPrice.compareTo(b.totalPrice)
            : b.totalPrice.compareTo(a.totalPrice));
        break;
    }

    emit(state.copyWith(
      invoices: sortedInvoices,
      sortField: field,
      sortOrder: currentOrder,
    ));
  }
}