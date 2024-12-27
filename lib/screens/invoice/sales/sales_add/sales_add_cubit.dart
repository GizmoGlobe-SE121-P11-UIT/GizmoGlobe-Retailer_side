import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice_detail.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'sales_add_state.dart';

class SalesAddCubit extends Cubit<SalesAddState> {
  final _firebase = Firebase();

  SalesAddCubit() : super(SalesAddState()) {
    _loadCustomers();
    _loadProducts();
  }

  Future<void> _loadCustomers() async {
    try {
      final customers = await _firebase.getCustomers();
      emit(state.copyWith(customers: customers));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _firebase.getProducts();
      emit(state.copyWith(products: products));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void updateCustomer(customer) {
    emit(state.copyWith(selectedCustomer: customer));
  }

  void updateAddress(String address) {
    emit(state.copyWith(address: address));
  }

  void updatePaymentStatus(PaymentStatus status) {
    emit(state.copyWith(paymentStatus: status));
  }

  void updateSalesStatus(SalesStatus status) {
    emit(state.copyWith(salesStatus: status));
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void addInvoiceDetail(Product product, int quantity) {
    final detail = SalesInvoiceDetail.withQuantity(
      productID: product.productID!,
      productName: product.productName,
      category: product.category.getName(),
      sellingPrice: product.sellingPrice,
      quantity: quantity,
      salesInvoiceID: '',
    );

    final details = List<SalesInvoiceDetail>.from(state.invoiceDetails)
      ..add(detail);

    emit(state.copyWith(invoiceDetails: details));
  }

  void updateDetailQuantity(int index, int quantity) {
    final details = List<SalesInvoiceDetail>.from(state.invoiceDetails);
    final detail = details[index];
    
    details[index] = SalesInvoiceDetail.withQuantity(
      salesInvoiceDetailID: detail.salesInvoiceDetailID,
      salesInvoiceID: detail.salesInvoiceID,
      productID: detail.productID,
      productName: detail.productName,
      category: detail.category,
      sellingPrice: detail.sellingPrice,
      quantity: quantity,
    );

    emit(state.copyWith(invoiceDetails: details));
  }

  void removeDetail(int index) {
    final details = List<SalesInvoiceDetail>.from(state.invoiceDetails)
      ..removeAt(index);
    emit(state.copyWith(invoiceDetails: details));
  }

  Future<SalesInvoice?> createInvoice() async {
    if (state.selectedCustomer == null) {
      emit(state.copyWith(error: 'Please select a customer'));
      return null;
    }

    if (state.address.isEmpty) {
      emit(state.copyWith(error: 'Please enter delivery address'));
      return null;
    }

    if (state.invoiceDetails.isEmpty) {
      emit(state.copyWith(error: 'Please add at least one product'));
      return null;
    }

    emit(state.copyWith(isLoading: true, error: null));

    try {
      final invoice = SalesInvoice(
        customerID: state.selectedCustomer!.customerID!,
        customerName: state.selectedCustomer!.customerName,
        address: state.address,
        date: state.selectedDate,
        paymentStatus: state.paymentStatus,
        salesStatus: state.salesStatus,
        totalPrice: state.totalPrice,
        details: state.invoiceDetails,
      );

      final invoiceId = await _firebase.createSalesInvoice(invoice);
      invoice.salesInvoiceID = invoiceId;

      for (var detail in invoice.details) {
        await _firebase.createSalesInvoiceDetail(
          detail.copyWith(salesInvoiceID: invoiceId)
        );
      }

      emit(state.copyWith(isLoading: false));
      return invoice;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      return null;
    }
  }
} 