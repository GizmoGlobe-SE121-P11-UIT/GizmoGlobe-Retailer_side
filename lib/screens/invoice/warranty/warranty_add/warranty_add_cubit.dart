import 'package:flutter/foundation.dart';
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
        errorMessage: 'Error loading customer invoices: $e', // Lỗi khi load hóa đơn khách hàng
        isLoading: false,
      ));
    }
  }

  void selectSalesInvoice(SalesInvoice invoice) async {
    emit(state.copyWith(
      selectedSalesInvoiceId: invoice.salesInvoiceID,
      selectedSalesInvoice: invoice,
      isLoading: true,  // Show loading while fetching products
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
      if (kDebugMode) {
        print('Error loading products: $e');
      } // Lỗi khi load sản phẩm
      emit(state.copyWith(
        errorMessage: 'Error loading product details', // Lỗi khi load chi tiết sản phẩm
        isLoading: false,
      ));
    }
  }

  void updateReason(String reason) {
    emit(state.copyWith(reason: reason));
  }

  void selectProduct(String productId) {
    if (kDebugMode) {
      print('Selecting product: $productId');
    } // Chọn sản phẩm
    try {
      final newSelected = Set<String>.from(state.selectedProducts)..add(productId);
      final newQuantities = Map<String, int>.from(state.productQuantities)
        ..putIfAbsent(productId, () => 1);
      if (kDebugMode) {
        print('New selected products: $newSelected');
      } // Sản phẩm đã chọn
      if (kDebugMode) {
        print('New quantities: $newQuantities');
      } // Số lượng
      emit(state.copyWith(
        selectedProducts: newSelected,
        productQuantities: newQuantities,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error selecting product: $e');
      } // Lỗi khi chọn sản phẩm
    }
  }

  void deselectProduct(String productId) {
    if (kDebugMode) {
      print('Deselecting product: $productId');
    } // Bỏ chọn sản phẩm
    try {
      final newSelected = Set<String>.from(state.selectedProducts)..remove(productId);
      final newQuantities = Map<String, int>.from(state.productQuantities)
        ..remove(productId);
      if (kDebugMode) {
        print('New selected products: $newSelected');
      } // Sản phẩm đã chọn
      if (kDebugMode) {
        print('New quantities: $newQuantities');
      } // Số lượng
      emit(state.copyWith(
        selectedProducts: newSelected,
        productQuantities: newQuantities,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error deselecting product: $e');
      } // Lỗi khi bỏ chọn sản phẩm
    }
  }

  void updateDetailQuantity(String productId, int quantity) {
    if (kDebugMode) {
      print('Updating quantity for product $productId to $quantity');
    } // Cập nhật số lượng cho sản phẩm
    try {
      if (!state.selectedProducts.contains(productId)) {
        if (kDebugMode) {
          print('Product $productId not in selected products');
        } // Sản phẩm không nằm trong danh sách sản phẩm đã chọn
        return;
      }
      
      final detail = state.selectedSalesInvoice?.details
          .firstWhere((d) => d.productID == productId);
      if (detail == null) {
        if (kDebugMode) {
          print('Product detail not found for $productId');
        } // Không tìm thấy chi tiết sản phẩm
        return;
      }

      if (kDebugMode) {
        print('Available quantity: ${detail.quantity}');
      } // Số lượng có sẵn
      final validQuantity = quantity.clamp(0, detail.quantity);
      if (kDebugMode) {
        print('Clamped quantity: $validQuantity');
      } // Số lượng đã giới hạn
      
      final newQuantities = Map<String, int>.from(state.productQuantities)
        ..[productId] = validQuantity;
      
      if (kDebugMode) {
        print('New quantities map: $newQuantities');
      } // Bản đồ số lượng mới
      emit(state.copyWith(productQuantities: newQuantities));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating quantity: $e');
      } // Lỗi khi cập nhật số lượng
    }
  }

  Future<WarrantyInvoice?> submit() async {
    if (kDebugMode) {
      print('Starting warranty invoice submission');
    } // Bắt đầu gửi hóa đơn bảo hành
    if (kDebugMode) {
      print('Selected products: ${state.selectedProducts}');
    } // Sản phẩm đã chọn
    if (kDebugMode) {
      print('Product quantities: ${state.productQuantities}');
    } // Số lượng sản phẩm
    
    try {
      // Validate required fields
      if (state.selectedCustomerId == null) {
        if (kDebugMode) {
          print('Error: No customer selected');
        } // Không chọn khách hàng
        emit(state.copyWith(errorMessage: 'Please select a customer')); // Vui lòng chọn khách hàng
        return null;
      }

      if (state.selectedSalesInvoiceId == null) {
        if (kDebugMode) {
          print('Error: No sales invoice selected');
        } // Không chọn hóa đơn bán hàng
        emit(state.copyWith(errorMessage: 'Please select a sales invoice')); // Vui lòng chọn hóa đơn bán hàng
        return null;
      }

      // Create warranty details
      final details = <WarrantyInvoiceDetail>[];
      
      // Check if selectedSalesInvoice is not null
      if (state.selectedSalesInvoice == null) {
        if (kDebugMode) {
          print('Error: Sales invoice details not loaded');
        } // Chi tiết hóa đơn bán hàng không được tải
        emit(state.copyWith(errorMessage: 'Sales invoice details not loaded')); // Chi tiết hóa đơn bán hàng không được tải
        return null;
      }

      // Build details list from selected products
      for (var salesDetail in state.selectedSalesInvoice!.details) {
        if (state.selectedProducts.contains(salesDetail.productID)) {
          final quantity = state.productQuantities[salesDetail.productID] ?? 0;
          if (quantity > 0) {
            if (kDebugMode) {
              print('Adding warranty detail for product ${salesDetail.productID} with quantity $quantity');
            } // Thêm chi tiết bảo hành cho sản phẩm với số lượng
            details.add(WarrantyInvoiceDetail(
              warrantyInvoiceDetailID: '',
              productID: salesDetail.productID,
              quantity: quantity,
              warrantyInvoiceID: '',
            ));
          }
        }
      }

      if (kDebugMode) {
        print('Created warranty details: ${details.length} items');
      } // Tạo chi tiết bảo hành
      if (details.isEmpty) {
        if (kDebugMode) {
          print('Error: No products selected or all quantities are 0');
        } // Không chọn sản phẩm hoặc tất cả số lượng là 0
        emit(state.copyWith(errorMessage: 'Please select at least one product')); // Vui lòng chọn ít nhất một sản phẩm
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

      if (kDebugMode) {
        print('Created warranty invoice: ${warrantyInvoice.warrantyInvoiceID}');
      } // Tạo hóa đơn bảo hành
      if (kDebugMode) {
        print('Details count: ${warrantyInvoice.details.length}');
      } // Số lượng chi tiết
      if (kDebugMode) {
        print('First detail: ${warrantyInvoice.details.firstOrNull?.toJson()}');
      } // Chi tiết đầu tiên

      final docId = await _firebase.createWarrantyInvoice(warrantyInvoice);
      if (kDebugMode) {
        print('Firebase document ID: $docId');
      } // ID tài liệu Firebase

      if (docId == null || docId.isEmpty) {
        if (kDebugMode) {
          print('Error: Firebase returned null or empty document ID');
        } // Firebase trả về ID tài liệu null hoặc trống
        emit(state.copyWith(
          errorMessage: 'Failed to create warranty invoice', // Không thể tạo hóa đơn bảo hành
          isSuccess: false
        ));
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

      if (kDebugMode) {
        print('Final warranty invoice created with ID: ${finalInvoice.warrantyInvoiceID}');
      } // Hóa đơn bảo hành cuối cùng được tạo với ID
      if (kDebugMode) {
        print('Final details count: ${finalInvoice.details.length}');
      } // Số lượng chi tiết cuối cùng
      
      emit(state.copyWith(
        errorMessage: null,
        isSuccess: true
      ));
      
      return finalInvoice;

    } catch (e) {
      if (kDebugMode) {
        print('Error in submit: $e');
      } // Lỗi khi gửi
      emit(state.copyWith(
        errorMessage: e.toString(),
        isSuccess: false
      ));
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