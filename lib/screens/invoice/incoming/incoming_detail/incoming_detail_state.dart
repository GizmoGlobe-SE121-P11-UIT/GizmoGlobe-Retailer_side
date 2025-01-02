import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';

class IncomingDetailState extends Equatable {
  final bool isLoading;
  final IncomingInvoice invoice;
  final Manufacturer? manufacturer;
  final Map<String, Product> products;
  final String? errorMessage;
  final String? userRole;

  const IncomingDetailState({
    this.isLoading = false,
    required this.invoice,
    this.manufacturer,
    this.products = const {},
    this.errorMessage,
    this.userRole,
  });

  IncomingDetailState copyWith({
    bool? isLoading,
    IncomingInvoice? invoice,
    Manufacturer? manufacturer,
    Map<String, Product>? products,
    String? errorMessage,
    String? userRole,
  }) {
    return IncomingDetailState(
      isLoading: isLoading ?? this.isLoading,
      invoice: invoice ?? this.invoice,
      manufacturer: manufacturer ?? this.manufacturer,
      products: products ?? this.products,
      errorMessage: errorMessage,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        invoice,
        manufacturer,
        products,
        errorMessage,
        userRole,
      ];
}
