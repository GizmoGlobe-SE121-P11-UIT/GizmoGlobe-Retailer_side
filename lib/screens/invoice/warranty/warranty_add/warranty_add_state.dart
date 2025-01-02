import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';

import '../../../../objects/product_related/product.dart';

class WarrantyAddState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final List<Customer> availableCustomers;
  final String? selectedCustomerId;
  final List<SalesInvoice> customerInvoices;
  final String? selectedSalesInvoiceId;
  final SalesInvoice? selectedSalesInvoice;
  final String reason;
  final Set<String> selectedProducts;
  final Map<String, int> productQuantities;
  final bool isSuccess;
  final Map<String, Product> products;

  const WarrantyAddState({
    this.isLoading = false,
    this.errorMessage,
    this.availableCustomers = const [],
    this.selectedCustomerId,
    this.customerInvoices = const [],
    this.selectedSalesInvoiceId,
    this.selectedSalesInvoice,
    this.reason = '',
    this.selectedProducts = const {},
    this.productQuantities = const {},
    this.isSuccess = false,
    this.products = const {},
  });

  WarrantyAddState copyWith({
    bool? isLoading,
    String? errorMessage,
    List<Customer>? availableCustomers,
    String? selectedCustomerId,
    List<SalesInvoice>? customerInvoices,
    String? selectedSalesInvoiceId,
    SalesInvoice? selectedSalesInvoice,
    String? reason,
    Set<String>? selectedProducts,
    Map<String, int>? productQuantities,
    bool? isSuccess,
    Map<String, Product>? products,
  }) {
    return WarrantyAddState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      availableCustomers: availableCustomers ?? this.availableCustomers,
      selectedCustomerId: selectedCustomerId ?? this.selectedCustomerId,
      customerInvoices: customerInvoices ?? this.customerInvoices,
      selectedSalesInvoiceId: selectedSalesInvoiceId ?? this.selectedSalesInvoiceId,
      selectedSalesInvoice: selectedSalesInvoice ?? this.selectedSalesInvoice,
      reason: reason ?? this.reason,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      productQuantities: productQuantities ?? this.productQuantities,
      isSuccess: isSuccess ?? this.isSuccess,
      products: products ?? this.products,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    errorMessage,
    availableCustomers,
    selectedCustomerId,
    customerInvoices,
    selectedSalesInvoiceId,
    selectedSalesInvoice,
    reason,
    selectedProducts,
    productQuantities,
    isSuccess,
    products,
  ];
}