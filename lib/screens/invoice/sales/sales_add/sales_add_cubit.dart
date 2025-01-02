import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice_detail.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/address_related/address.dart';
import 'sales_add_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesAddCubit extends Cubit<SalesAddState> {
  SalesAddCubit() : super(const SalesAddState()) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    try {
      emit(state.copyWith(isLoading: true));
      final customers = await Firebase().getCustomers();
      final products = await Firebase().getProducts();
      emit(state.copyWith(
        customers: customers,
        products: products,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
    }
  }

  void updateCustomer(Customer customer) {
    emit(state.copyWith(
      selectedCustomer: customer,
      address: null, // Clear address when customer changes
    ));
  }

  void updateAddress(Address address) {
    emit(state.copyWith(address: address));
  }

  void updateSelectedModalProduct(Product? product) {
    emit(state.copyWith(selectedModalProduct: product));
  }

  void updatePaymentStatus(PaymentStatus status) {
    emit(state.copyWith(paymentStatus: status));
  }

  void updateSalesStatus(SalesStatus status) {
    emit(state.copyWith(salesStatus: status));
  }

  void addInvoiceDetail(Product product, int quantity) {
    final details = List<SalesInvoiceDetail>.from(state.invoiceDetails);
    
    // Try to find existing detail with the same product
    final existingIndex = details.indexWhere(
      (detail) => detail.productID == product.productID
    );

    if (existingIndex >= 0) {
      // Product already exists, update quantity
      final existingDetail = details[existingIndex];
      final newQuantity = existingDetail.quantity + quantity;
      
      // Check if new quantity exceeds available stock
      if (newQuantity > product.stock) {
        emit(state.copyWith(
          error: 'Not enough stock available'
        ));
        return;
      }

      details[existingIndex] = SalesInvoiceDetail(
        productID: existingDetail.productID ?? '',
        productName: existingDetail.productName ?? '',
        quantity: newQuantity,
        sellingPrice: existingDetail.sellingPrice,
        subtotal: existingDetail.sellingPrice * newQuantity,
        salesInvoiceID: '',
      );
    } else {
      // New product, add new detail
      details.add(SalesInvoiceDetail(
        productID: product.productID ?? '',
        productName: product.productName,
        quantity: quantity,
        sellingPrice: product.sellingPrice,
        subtotal: product.sellingPrice * quantity,
        salesInvoiceID: '',
      ));
    }

    emit(state.copyWith(
      invoiceDetails: details,
      error: null, // Clear any previous errors
    ));
  }

  void updateDetailQuantity(int index, int newQuantity) {
    final details = List<SalesInvoiceDetail>.from(state.invoiceDetails);
    final detail = details[index];
    details[index] = SalesInvoiceDetail(
      productID: detail.productID ?? '',
      productName: detail.productName ?? '',
      quantity: newQuantity,
      sellingPrice: detail.sellingPrice,
      subtotal: detail.sellingPrice * newQuantity,
      salesInvoiceID: '',
    );
    emit(state.copyWith(invoiceDetails: details));
  }

  void removeDetail(int index) {
    final details = List<SalesInvoiceDetail>.from(state.invoiceDetails)
      ..removeAt(index);
    emit(state.copyWith(invoiceDetails: details));
  }

  Future<SalesInvoice?> createInvoice() async {
    try {
      emit(state.copyWith(isLoading: true));
      
      if (state.selectedCustomer == null || state.address == null) {
        throw Exception('Customer and address are required');
      }

      if (state.invoiceDetails.isEmpty) {
        throw Exception('At least one product is required');
      }

      // Generate a new document ID
      final docRef = FirebaseFirestore.instance.collection('salesInvoices').doc();
      final invoiceID = docRef.id;

      // Create invoice with the generated ID
      final invoice = SalesInvoice(
        salesInvoiceID: invoiceID, // Use the generated ID
        customerID: state.selectedCustomer!.customerID ?? '',
        customerName: state.selectedCustomer!.customerName ?? '',
        address: state.address!,
        details: state.invoiceDetails.map((detail) => 
          SalesInvoiceDetail(
            salesInvoiceID: invoiceID, // Set the invoice ID for each detail
            productID: detail.productID ?? '',
            productName: detail.productName ?? '',
            quantity: detail.quantity,
            sellingPrice: detail.sellingPrice,
            subtotal: detail.subtotal,
          )
        ).toList(),
        paymentStatus: state.paymentStatus,
        salesStatus: state.salesStatus,
        totalPrice: state.totalPrice,
        date: DateTime.now(),
      );

      final createdInvoice = await Firebase().createSalesInvoice(invoice);
      emit(state.copyWith(isLoading: false));
      return createdInvoice;
    } catch (e) {
      emit(state.copyWith(
        error: e.toString(),
        isLoading: false,
      ));
      return null;
    }
  }
} 