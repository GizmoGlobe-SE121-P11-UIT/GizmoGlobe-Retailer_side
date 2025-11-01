import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'sales_detail_state.dart';

class SalesDetailCubit extends Cubit<SalesDetailState> {
  final Firebase _firebase = Firebase();

  SalesDetailCubit(SalesInvoice invoice)
      : super(SalesDetailState(invoice: invoice)) {
    _init();
    _loadInvoiceDetails();
  }

  Future<void> _init() async {
    final userRole = await _firebase.getCurrentUserRole();
    if (!isClosed) emit(state.copyWith(userRole: userRole));
  }

  Future<Product?> getProduct(String productId) async {
    try {
      if (!isClosed) emit(state.copyWith(isLoading: true));
      final product = await _firebase.getProduct(productId);
      if (!isClosed) emit(state.copyWith(isLoading: false));
      return product;
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          error: 'Error loading product: $e', // Lỗi khi load sản phẩm
        ));
      }
      return null;
    }
  }

  Future<Map<String, Product>> getProductsMapForInvoice() async {
    final map = <String, Product>{};
    for (final detail in state.invoice.details) {
      if (!map.containsKey(detail.productID)) {
        final product = await _firebase.getProduct(detail.productID);
        if (product != null) {
          map[detail.productID] = product;
        }
      }
    }
    return map;
  }

  Future<void> _loadInvoiceDetails() async {
    if (!isClosed) emit(state.copyWith(isLoading: true));
    try {
      final updatedInvoice = await _firebase
          .getSalesInvoiceWithDetails(state.invoice.salesInvoiceID);
      if (!isClosed) {
        emit(state.copyWith(
          invoice: updatedInvoice,
          isLoading: false,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    }
  }

  Future<void> updateSalesInvoice(SalesInvoice updatedInvoice) async {
    if (!isClosed) emit(state.copyWith(isLoading: true));
    try {
      await _firebase.updateSalesInvoice(updatedInvoice);
      if (!isClosed) {
        emit(state.copyWith(
          invoice: updatedInvoice,
          isLoading: false,
        ));
      }
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    }
  }
}
