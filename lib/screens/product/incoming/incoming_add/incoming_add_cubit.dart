import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice_detail.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import '../../../../objects/product_related/cpu_related/cpu.dart';
import '../../../../objects/product_related/drive_related/drive.dart';
import '../../../../objects/product_related/gpu_related/gpu.dart';
import '../../../../objects/product_related/mainboard_related/mainboard.dart';
import '../../../../objects/product_related/product_factory.dart';
import '../../../../objects/product_related/psu_related/psu.dart';
import '../../../../objects/product_related/ram_related/ram.dart';
import 'incoming_add_state.dart';

class IncomingAddCubit extends Cubit<IncomingAddState> {
  final _firebase = Firebase();

  IncomingAddCubit() : super(const IncomingAddState()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final manufacturers = await _firebase.getManufacturers();
      emit(state.copyWith(
        manufacturers: manufacturers,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage:
            'Error loading manufacturers: $e', // Lỗi khi load dữ liệu nhà sản xuất
        isLoading: false,
      ));
    }
  }

  Future<void> selectManufacturer(Manufacturer manufacturer) async {
    emit(state.copyWith(
      isLoading: true,
      selectedManufacturer: manufacturer,
      details: [], // Reset details when manufacturer changes
    ));

    await updateProducts(manufacturer);
    emit(state.copyWith(isLoading: false));
  }

  Future<void> updateProducts(Manufacturer manufacturer) async {
    try {
      final allProducts = await _firebase.getProducts();
      final manufacturerProducts = allProducts
          .where((product) =>
      product.manufacturer.manufacturerID ==
          manufacturer.manufacturerID)
          .toList();

      emit(state.copyWith(
        products: manufacturerProducts,
      ));
    } catch (e) {
      emit(state.copyWith(
        errorMessage:
        'Error loading products: $e',
      ));
    }
  }

  void addDetail(Product product, double importPrice, int quantity) {
    if (importPrice <= 0) {
      emit(state.copyWith(
          errorMessage:
              'Import price must be greater than 0')); // Giá nhập phải lớn hơn 0
      return;
    }

    if (quantity <= 0) {
      emit(state.copyWith(
          errorMessage:
              'Quantity must be greater than 0')); // Số lượng phải lớn hơn 0
      return;
    }

    // Kiểm tra xem sản phẩm đã tồn tại trong details chưa
    final existingDetailIndex = state.details.indexWhere(
      (detail) => detail.productID == product.productID,
    );

    final List<IncomingInvoiceDetail> updatedDetails = List.from(state.details);

    if (existingDetailIndex != -1) {
      // Nếu sản phẩm đã tồn tại, cập nhật số lượng và subtotal
      final existingDetail = state.details[existingDetailIndex];
      final updatedDetail = IncomingInvoiceDetail(
        incomingInvoiceID: existingDetail.incomingInvoiceID,
        productID: product.productID!,
        importPrice: importPrice, // Sử dụng giá import mới nhất
        quantity: existingDetail.quantity + quantity,
        subtotal: importPrice * (existingDetail.quantity + quantity),
      );
      updatedDetails[existingDetailIndex] = updatedDetail;
    } else {
      // Nếu sản phẩm chưa tồn tại, thêm mới
      final detail = IncomingInvoiceDetail(
        incomingInvoiceID: '',
        productID: product.productID!,
        importPrice: importPrice,
        quantity: quantity,
        subtotal: importPrice * quantity,
      );
      updatedDetails.add(detail);
    }

    emit(state.copyWith(
      details: updatedDetails,
      errorMessage: null,
    ));
  }

  void removeDetail(int index) {
    final updatedDetails = List<IncomingInvoiceDetail>.from(state.details)
      ..removeAt(index);

    emit(state.copyWith(details: updatedDetails));
  }

  void updateDetailQuantity(int index, int newQuantity) {
    if (newQuantity <= 0) {
      emit(state.copyWith(
          errorMessage:
              'Quantity must be greater than 0')); // Số lượng phải lớn hơn 0
      return;
    }

    final detail = state.details[index];
    final updatedDetail = IncomingInvoiceDetail(
      incomingInvoiceID: detail.incomingInvoiceID,
      productID: detail.productID,
      importPrice: detail.importPrice,
      quantity: newQuantity,
      subtotal: detail.importPrice * newQuantity,
    );

    final updatedDetails = List<IncomingInvoiceDetail>.from(state.details)
      ..[index] = updatedDetail;

    emit(state.copyWith(
      details: updatedDetails,
      errorMessage: null,
    ));
  }

  Future<bool> submitInvoice() async {
    if (state.selectedManufacturer == null) {
      emit(state.copyWith(
          errorMessage:
              'Please select a manufacturer')); // Vui lòng chọn nhà sản xuất
      return false;
    }

    if (state.details.isEmpty) {
      emit(state.copyWith(
          errorMessage:
              'Please add at least one product')); // Vui lòng thêm ít nhất một sản phẩm
      return false;
    }

    emit(state.copyWith(isSubmitting: true));

    try {
      final invoice = IncomingInvoice(
        manufacturerID: state.selectedManufacturer?.manufacturerID ?? '',
        date: DateTime.now(),
        status: state.paymentStatus,
        totalPrice: state.totalPrice,
        details: state.details,
      );

      await _firebase.createIncomingInvoice(invoice);

      // Update products after successful invoice creation
      for (var detail in state.details) {
        final product = state.products.firstWhere(
          (p) => p.productID == detail.productID,
        );

        // Create a map of product properties with updated values
        final Map<String, dynamic> productProps = {
          'productID': product.productID!,
          'productName': product.productName,
          'manufacturer': {
            'manufacturerID': product.manufacturer.manufacturerID,
            'manufacturerName': product.manufacturer.manufacturerName,
            'status': product.manufacturer.status.name,
          }, // Use Map not String!
          'category': product.category.name,
          'importPrice': detail.importPrice, // Use new import price from detail
          'sellingPrice': product.sellingPrice,
          'discount': product.discount,
          'release': product.release,
          'sales': product.sales,
          'stock': product.stock + detail.quantity,
          'status': product.status,
        };

        // Add specific properties based on product type
        if (product is RAM) {
          productProps.addAll({});
        } else if (product is CPU) {
          productProps.addAll({});
        } else if (product is GPU) {
          productProps.addAll({});
        } else if (product is Mainboard) {
          productProps.addAll({});
        } else if (product is Drive) {
          productProps.addAll({});
        } else if (product is PSU) {
          productProps.addAll({});
        }

        // Create new product instance and update
        try {
          final updatedProduct = ProductFactory.createProduct(productProps);
          await _firebase.updateProduct(updatedProduct);
        } catch (e) {
          // Error updating product, continue with other products
        }
      }

      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: null,
      ));

      return true;
    } catch (e) {
      emit(state.copyWith(
        isSubmitting: false,
        errorMessage: 'Error creating invoice: $e', // Lỗi khi tạo hóa đơn
      ));
      return false;
    }
  }

  void clearError() {
    emit(state.copyWith(errorMessage: null));
  }

  void updatePaymentStatus(PaymentStatus status) {
    emit(state.copyWith(paymentStatus: status));
  }
}
