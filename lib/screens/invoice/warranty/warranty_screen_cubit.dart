import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/invoice_related/warranty_invoice.dart';
import 'package:gizmoglobe_client/enums/invoice_related/warranty_status.dart';
import 'warranty_screen_state.dart';

class WarrantyScreenCubit extends Cubit<WarrantyScreenState> {
  final _firebase = Firebase();
  late final Stream<List<WarrantyInvoice>> _invoicesStream;
  StreamSubscription<List<WarrantyInvoice>>? _subscription;
  bool _isClosed = false;

  WarrantyScreenCubit() : super(const WarrantyScreenState()) {
    _invoicesStream = _firebase.warrantyInvoicesStream();
    _listenToInvoices();
    loadInvoices();
    _loadUserRole();
  }

  void _listenToInvoices() {
    _subscription = _invoicesStream.listen((invoices) {
      if (_isClosed) return;
      if (state.searchQuery.isEmpty) {
        emit(state.copyWith(invoices: invoices));
      } else {
        searchInvoices(state.searchQuery);
      }
    });
  }

  Future<void> _loadUserRole() async {
    try {
      if (_isClosed) return;
      final userRole = await _firebase.getUserRole();
      emit(state.copyWith(userRole: userRole));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user role: $e');
      } // Lỗi load user role
    }
  }

  @override
  Future<void> close() async {
    _isClosed = true;
    await _subscription?.cancel();
    return super.close();
  }

  Future<void> loadInvoices() async {
    if (_isClosed) return;
    emit(state.copyWith(isLoading: true));
    try {
      final invoices = await _firebase.getWarrantyInvoices();
      if (!_isClosed) {
        emit(state.copyWith(
          invoices: invoices,
          isLoading: false,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading warranty invoices: $e');
      } // Lỗi lấy hóa đơn
      if (!_isClosed) {
        emit(state.copyWith(isLoading: false));
      }
    }
  }

  void searchInvoices(String query) {    
    emit(state.copyWith(searchQuery: query));
    
    if (query.isEmpty) {
      loadInvoices();
      return;
    }

    final filteredInvoices = state.invoices.where((invoice) {
      final matchesName = invoice.customerName?.toLowerCase().contains(query.toLowerCase()) ?? false;
      final matchesId = invoice.warrantyInvoiceID?.toLowerCase().contains(query.toLowerCase()) ?? false;
      return matchesName || matchesId;
    }).toList();

    emit(state.copyWith(invoices: filteredInvoices));
  }

  void setSelectedIndex(int? index) {
    if (_isClosed) return;
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> updateWarrantyStatus(String invoiceId, WarrantyStatus newStatus) async {
    if (_isClosed) return;
    try {
      final invoice = state.invoices.firstWhere((inv) => inv.warrantyInvoiceID == invoiceId);
      final updatedInvoice = WarrantyInvoice(
        warrantyInvoiceID: invoice.warrantyInvoiceID,
        customerID: invoice.customerID,
        customerName: invoice.customerName,
        date: invoice.date,
        status: newStatus,
        details: invoice.details,
        salesInvoiceID: invoice.salesInvoiceID,
        reason: invoice.reason,
      );

      await _firebase.updateWarrantyInvoice(updatedInvoice);
      // Refresh will be handled through stream listener
    } catch (e) {
      if (kDebugMode) {
        print('Error updating warranty status: $e');
      } // Lỗi cập nhật trạng thái bảo hành
    }
  }

  void sortInvoices(SortField field, [SortOrder? order]) {
    if (_isClosed) return;
    
    final currentOrder = order ?? 
      (state.sortField == field ? 
        (state.sortOrder == SortOrder.ascending ? SortOrder.descending : SortOrder.ascending)
        : SortOrder.descending);

    final sortedInvoices = List<WarrantyInvoice>.from(state.invoices);

    switch (field) {
      case SortField.date:
        sortedInvoices.sort((a, b) => currentOrder == SortOrder.ascending
            ? a.date.compareTo(b.date)
            : b.date.compareTo(a.date));
        break;
    }

    emit(state.copyWith(
      invoices: sortedInvoices,
      sortField: field,
      sortOrder: currentOrder,
    ));
  }
}