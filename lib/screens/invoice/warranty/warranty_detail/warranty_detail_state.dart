import 'package:gizmoglobe_client/objects/invoice_related/warranty_invoice.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';

class WarrantyDetailState {
  final WarrantyInvoice invoice;
  final bool isLoading;
  final String? error;
  final Map<String, Product> products;
  final String? userRole;

  const WarrantyDetailState({
    required this.invoice,
    this.isLoading = false,
    this.error,
    this.products = const {},
    this.userRole,
  });

  WarrantyDetailState copyWith({
    WarrantyInvoice? invoice,
    bool? isLoading,
    String? error,
    Map<String, Product>? products,
    String? userRole,
  }) {
    return WarrantyDetailState(
      invoice: invoice ?? this.invoice,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      products: products ?? this.products,
      userRole: userRole ?? this.userRole,
    );
  }
}