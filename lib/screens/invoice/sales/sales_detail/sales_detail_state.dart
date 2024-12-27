import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';

class SalesDetailState extends Equatable {
  final SalesInvoice invoice;
  final bool isLoading;
  final String? error;

  const SalesDetailState({
    required this.invoice,
    this.isLoading = false,
    this.error,
  });

  SalesDetailState copyWith({
    SalesInvoice? invoice,
    bool? isLoading,
    String? error,
  }) {
    return SalesDetailState(
      invoice: invoice ?? this.invoice,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [invoice, isLoading, error];
}
