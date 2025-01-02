import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice_detail.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';

import '../../../../enums/invoice_related/payment_status.dart';

class IncomingAddState extends Equatable {
  final bool isLoading;
  final List<Manufacturer> manufacturers;
  final List<Product> products;
  final Manufacturer? selectedManufacturer;
  final List<IncomingInvoiceDetail> details;
  final String? errorMessage;
  final bool isSubmitting;
  final PaymentStatus paymentStatus;

  const IncomingAddState({
    this.isLoading = false,
    this.manufacturers = const [],
    this.products = const [],
    this.selectedManufacturer,
    this.details = const [],
    this.errorMessage,
    this.isSubmitting = false,
    this.paymentStatus = PaymentStatus.unpaid,
  });

  double get totalPrice => details.fold(
        0,
        (sum, detail) => sum + detail.subtotal,
      );

  IncomingAddState copyWith({
    bool? isLoading,
    List<Manufacturer>? manufacturers,
    List<Product>? products,
    Manufacturer? selectedManufacturer,
    List<IncomingInvoiceDetail>? details,
    String? errorMessage,
    bool? isSubmitting,
    PaymentStatus? paymentStatus,
  }) {
    return IncomingAddState(
      isLoading: isLoading ?? this.isLoading,
      manufacturers: manufacturers ?? this.manufacturers,
      products: products ?? this.products,
      selectedManufacturer: selectedManufacturer ?? this.selectedManufacturer,
      details: details ?? this.details,
      errorMessage: errorMessage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        manufacturers,
        products,
        selectedManufacturer,
        details,
        errorMessage,
        isSubmitting,
        paymentStatus,
      ];
} 