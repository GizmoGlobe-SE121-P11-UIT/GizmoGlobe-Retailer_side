import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'sales_screen_state.dart';

class SalesScreenCubit extends Cubit<SalesScreenState> {
  final _firebase = Firebase();
  StreamSubscription<List<SalesInvoice>>? _salesSubscription;
  String? _currentSortCriteria;
  bool _currentSortDescending = true;

  SalesScreenCubit() : super(const SalesScreenState()) {
    _init();
  }

  Future<void> _init() async {
    final userRole = await _firebase.getCurrentUserRole();
    emit(state.copyWith(userRole: userRole));
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    emit(state.copyWith(isLoading: true));
    try {
      final invoices = await _firebase.getSalesInvoices();
      emit(state.copyWith(
        invoices: invoices,
        isLoading: false,
      ));
      _subscribeToSales();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading sales invoices: $e');
      } // Lỗi khi load hóa đơn
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void _subscribeToSales() {
    _salesSubscription?.cancel();
    _salesSubscription = _firebase.salesInvoicesStream().listen(
      (invoices) {
        if (state.searchQuery.isEmpty) {
          final sortedInvoices = _applySorting(invoices);
          emit(state.copyWith(
            invoices: sortedInvoices,
            isLoading: false,
          ));
        } else {
          searchInvoices(state.searchQuery);
        }
      },
      onError: (error) {
        emit(state.copyWith(
          error: error.toString(),
          isLoading: false,
        ));
      },
    );
  }

  Future<void> refreshInvoices() async {
    emit(state.copyWith(isLoading: true));
    try {
      final invoices = await _firebase.getSalesInvoices();
      emit(state.copyWith(
        invoices: invoices,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  void searchInvoices(String query) {
    emit(state.copyWith(searchQuery: query));
    
    if (query.isEmpty) {
      _subscribeToSales();
      return;
    }

    final filteredInvoices = state.invoices.where((invoice) {
      return invoice.customerName.toLowerCase().contains(query.toLowerCase()) ||
             invoice.salesInvoiceID.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(state.copyWith(invoices: filteredInvoices));
  }

  void setSelectedIndex(int? index) {
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> updateSalesInvoice(SalesInvoice invoice) async {
    try {
      await _firebase.updateSalesInvoice(invoice);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating sales invoice: $e');
      } // Lỗi cập nhật hóa đơn
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<String?> createSalesInvoice(SalesInvoice invoice) async {
    try {
      await _firebase.createSalesInvoice(invoice);
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating sales invoice: $e');
      } // Lỗi tạo hóa đơn
      return e.toString();
    }
  }

  void sortInvoices(String criteria, bool descending) {
    _currentSortCriteria = criteria;
    _currentSortDescending = descending;
    
    if (state.invoices.isEmpty) return;

    final sortedInvoices = _applySorting(state.invoices);
    
    emit(state.copyWith(
      invoices: sortedInvoices,
      isLoading: false,
    ));
  }

  List<SalesInvoice> _applySorting(List<SalesInvoice> invoices) {
    if (_currentSortCriteria == null) return invoices;

    final sortedInvoices = List<SalesInvoice>.from(invoices);
    
    switch (_currentSortCriteria) {
      case 'date':
        sortedInvoices.sort((a, b) => _currentSortDescending
            ? b.date.compareTo(a.date)
            : a.date.compareTo(b.date));
        break;
      case 'price':
        sortedInvoices.sort((a, b) => _currentSortDescending
            ? b.totalPrice.compareTo(a.totalPrice)
            : a.totalPrice.compareTo(b.totalPrice));
        break;
    }
    
    return sortedInvoices;
  }

  @override
  Future<void> close() {
    _salesSubscription?.cancel();
    return super.close();
  }
}