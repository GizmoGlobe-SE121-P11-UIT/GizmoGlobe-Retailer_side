import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/invoice_related/warranty_invoice.dart';
import 'package:gizmoglobe_client/objects/invoice_related/warranty_invoice_detail.dart';
import '../../../../enums/invoice_related/warranty_status.dart';
import '../../../../objects/invoice_related/sales_invoice.dart';
import '../../../../objects/product_related/product.dart';
import 'warranty_add_state.dart';

class WarrantyAddCubit extends Cubit<WarrantyAddState> {
  final _firebase = Firebase();

  // Add a map to store product details
  final Map<String, Product> _products = {};

  WarrantyAddCubit() : super(const WarrantyAddState()) {
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    emit(state.copyWith(isLoading: true));
    try {
      final customers = await _firebase.getCustomers();
      emit(state.copyWith(
        availableCustomers: customers,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: 'Error loading customers: $e', // Lỗi khi load khách hàng
        isLoading: false,
      ));
    }
  }

  Future<void> selectCustomer(String customerId) async {
    emit(state.copyWith(
      selectedCustomerId: customerId,
      selectedSalesInvoiceId: null,
      selectedSalesInvoice: null,
      selectedProducts: {},
      productQuantities: {},
      customerInvoices: [],
    ));
    await _loadCustomerInvoices(customerId);
  }

  Future<void> _loadCustomerInvoices(String customerId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final invoices = await _firebase.getCustomerSalesInvoices(customerId);
      emit(state.copyWith(
        customerInvoices: invoices,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage:
            'Error loading customer invoices: $e', // Lỗi khi load hóa đơn khách hàng
        isLoading: false,
      ));
    }
  }

  void selectSalesInvoice(SalesInvoice invoice) async {
    emit(state.copyWith(
      selectedSalesInvoiceId: invoice.salesInvoiceID,
      selectedSalesInvoice: invoice,
      isLoading: true, // Show loading while fetching products
    ));

    try {
      // Fetch product details for all products in the invoice
      for (var detail in invoice.details) {
        if (!_products.containsKey(detail.productID)) {
          final product = await _firebase.getProduct(detail.productID);
          if (product != null) {
            _products[detail.productID] = product;
          }
        }
      }

      emit(state.copyWith(
        products: _products,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage:
            'Error loading product details', // Lỗi khi load chi tiết sản phẩm
        isLoading: false,
      ));
    }
  }

  void updateReason(String reason) {
    emit(state.copyWith(reason: reason));
  }

  void selectProduct(String productId) {
    try {
      final newSelected = Set<String>.from(state.selectedProducts)
        ..add(productId);
      final newQuantities = Map<String, int>.from(state.productQuantities)
        ..putIfAbsent(productId, () => 1);
      emit(state.copyWith(
        selectedProducts: newSelected,
        productQuantities: newQuantities,
      ));
    } catch (e) {
      // Error selecting product
    }
  }

  void deselectProduct(String productId) {
    try {
      final newSelected = Set<String>.from(state.selectedProducts)
        ..remove(productId);
      final newQuantities = Map<String, int>.from(state.productQuantities)
        ..remove(productId);
      emit(state.copyWith(
        selectedProducts: newSelected,
        productQuantities: newQuantities,
      ));
    } catch (e) {
      // Error deselecting product
    }
  }

  void updateDetailQuantity(String productId, int quantity) {
    try {
      if (!state.selectedProducts.contains(productId)) {
        return;
      }

      final detail = state.selectedSalesInvoice?.details
          .firstWhere((d) => d.productID == productId);
      if (detail == null) {
        return;
      }

      final validQuantity = quantity.clamp(0, detail.quantity);

      final newQuantities = Map<String, int>.from(state.productQuantities)
        ..[productId] = validQuantity;

      emit(state.copyWith(productQuantities: newQuantities));
    } catch (e) {
      // Error updating quantity
    }
  }

  Future<WarrantyInvoice?> submit() async {
    try {
      // Validate required fields
      if (state.selectedCustomerId == null) {
        emit(state.copyWith(
            errorMessage:
                'Please select a customer')); // Vui lòng chọn khách hàng
        return null;
      }

      if (state.selectedSalesInvoiceId == null) {
        emit(state.copyWith(
            errorMessage:
                'Please select a sales invoice')); // Vui lòng chọn hóa đơn bán hàng
        return null;
      }

      // Create warranty details
      final details = <WarrantyInvoiceDetail>[];

      // Check if selectedSalesInvoice is not null
      if (state.selectedSalesInvoice == null) {
        emit(state.copyWith(
            errorMessage:
                'Sales invoice details not loaded')); // Chi tiết hóa đơn bán hàng không được tải
        return null;
      }

      // Build details list from selected products
      for (var salesDetail in state.selectedSalesInvoice!.details) {
        if (state.selectedProducts.contains(salesDetail.productID)) {
          final quantity = state.productQuantities[salesDetail.productID] ?? 0;
          if (quantity > 0) {
            details.add(WarrantyInvoiceDetail(
              warrantyInvoiceDetailID: '',
              productID: salesDetail.productID,
              quantity: quantity,
              warrantyInvoiceID: '',
            ));
          }
        }
      }

      if (details.isEmpty) {
        emit(state.copyWith(
            errorMessage:
                'Please select at least one product')); // Vui lòng chọn ít nhất một sản phẩm
        return null;
      }

      final selectedCustomer = state.availableCustomers
          .firstWhere((c) => c.customerID == state.selectedCustomerId);

      final warrantyInvoice = WarrantyInvoice(
        warrantyInvoiceID: '',
        salesInvoiceID: state.selectedSalesInvoiceId!,
        customerName: selectedCustomer.customerName,
        customerID: selectedCustomer.customerID ?? '',
        date: DateTime.now(),
        status: WarrantyStatus.pending,
        details: details,
        reason: state.reason,
      );

      final docId = await _firebase.createWarrantyInvoice(warrantyInvoice);

      if (docId == null || docId.isEmpty) {
        emit(state.copyWith(
            errorMessage:
                'Failed to create warranty invoice', // Không thể tạo hóa đơn bảo hành
            isSuccess: false));
        return null;
      }

      // Create final invoice with Firebase document ID
      final finalInvoice = WarrantyInvoice(
        warrantyInvoiceID: docId,
        salesInvoiceID: warrantyInvoice.salesInvoiceID,
        customerName: warrantyInvoice.customerName,
        customerID: warrantyInvoice.customerID,
        date: warrantyInvoice.date,
        status: warrantyInvoice.status,
        details: warrantyInvoice.details,
        reason: warrantyInvoice.reason,
      );

      emit(state.copyWith(errorMessage: null, isSuccess: true));

      return finalInvoice;
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString(), isSuccess: false));
      return null;
    }
  }

  void incrementProductQuantity(String productId) {
    final currentQuantity = state.productQuantities[productId] ?? 1;
    updateDetailQuantity(productId, currentQuantity + 1);
  }

  void decrementProductQuantity(String productId) {
    final currentQuantity = state.productQuantities[productId] ?? 1;
    if (currentQuantity > 1) {
      updateDetailQuantity(productId, currentQuantity - 1);
    }
  }
}
