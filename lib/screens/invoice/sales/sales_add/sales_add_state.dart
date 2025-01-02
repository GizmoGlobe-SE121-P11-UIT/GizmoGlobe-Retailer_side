import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice_detail.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/address_related/address.dart';

class SalesAddState {
  final List<Customer> customers;
  final List<Product> products;
  final List<SalesInvoiceDetail> invoiceDetails;
  final Customer? selectedCustomer;
  final Product? selectedModalProduct;
  final Address? address;
  final PaymentStatus paymentStatus;
  final SalesStatus salesStatus;
  final bool isLoading;
  final String? error;

  double get totalPrice => invoiceDetails.fold(
        0,
        (sum, detail) => sum + detail.subtotal,
      );

  const SalesAddState({
    this.customers = const [],
    this.products = const [],
    this.invoiceDetails = const [],
    this.selectedCustomer,
    this.selectedModalProduct,
    this.address,
    this.paymentStatus = PaymentStatus.unpaid,
    this.salesStatus = SalesStatus.pending,
    this.isLoading = false,
    this.error,
  });

  SalesAddState copyWith({
    List<Customer>? customers,
    List<Product>? products,
    List<SalesInvoiceDetail>? invoiceDetails,
    Customer? selectedCustomer,
    Product? selectedModalProduct,
    Address? address,
    PaymentStatus? paymentStatus,
    SalesStatus? salesStatus,
    bool? isLoading,
    String? error,
  }) {
    return SalesAddState(
      customers: customers ?? this.customers,
      products: products ?? this.products,
      invoiceDetails: invoiceDetails ?? this.invoiceDetails,
      selectedCustomer: selectedCustomer ?? this.selectedCustomer,
      selectedModalProduct: selectedModalProduct ?? this.selectedModalProduct,
      address: address ?? this.address,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      salesStatus: salesStatus ?? this.salesStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
} 