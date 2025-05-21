import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/invoice_related/warranty_invoice.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import '../../../../enums/invoice_related/warranty_status.dart';
import 'warranty_detail_state.dart';

class WarrantyDetailCubit extends Cubit<WarrantyDetailState> {
  final Firebase _firebase = Firebase();
  bool _isClosed = false;

  WarrantyDetailCubit(WarrantyInvoice invoice) 
      : super(WarrantyDetailState(invoice: invoice)) {
    _loadInvoiceDetails();
    _loadUserRole();
  }

  Future<void> _loadInvoiceDetails() async {
    if (_isClosed) return;  // Check if cubit is closed
    emit(state.copyWith(isLoading: true));
    
    try {
      final updatedInvoice = await _firebase.getWarrantyInvoiceWithDetails(state.invoice.warrantyInvoiceID!);
      
      // Load all products referenced in details
      final Map<String, Product> products = {};
      final allProducts = await _firebase.getProducts();
      
      for (var detail in updatedInvoice.details) {
        final product = allProducts.firstWhere(
          (p) => p.productID == detail.productID,
          orElse: () => throw Exception('Product not found: ${detail.productID}'), // Không tìm thấy sản phẩm
        );
        products[detail.productID] = product;
      }

      if (!_isClosed) {  // Check again before final emit
        emit(state.copyWith(
          invoice: updatedInvoice,
          products: products,
          isLoading: false,
        ));
      }
    } catch (e) {
      if (!_isClosed) {  // Check before error emit
        emit(state.copyWith(
          isLoading: false,
          error: e.toString(),
        ));
      }
    }
  }

  Future<void> _loadUserRole() async {
    if (_isClosed) return;
    try {
      final userRole = await _firebase.getUserRole();
      emit(state.copyWith(userRole: userRole));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user role: $e');
      } // Lỗi load phân quyền user
    }
  }

  Future<void> updateWarrantyStatus(WarrantyStatus newStatus) async {
    if (_isClosed) return;
    try {
      final updatedInvoice = state.invoice.copyWith(status: newStatus);
      await _firebase.updateWarrantyInvoice(updatedInvoice);
      emit(state.copyWith(invoice: updatedInvoice));
    } catch (e) {
      emit(state.copyWith(error: 'Error updating warranty status: $e')); // Lỗi khi cập nhật trạng thái bảo hành
    }
  }

  void updateInvoice(WarrantyInvoice updatedInvoice) {
    emit(state.copyWith(
      invoice: updatedInvoice,
      isLoading: false,
    ));
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

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }
}