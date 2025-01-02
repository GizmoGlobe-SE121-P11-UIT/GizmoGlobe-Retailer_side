import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';

class SalesDetailState extends Equatable {
  final SalesInvoice invoice;
  final bool isLoading;
  final String? error;
  final String userRole;

  const SalesDetailState({
    required this.invoice,
    this.isLoading = false,
    this.error,
    this.userRole = 'employee', // Default role
  });

  SalesDetailState copyWith({
    SalesInvoice? invoice,
    bool? isLoading,
    String? error,
    String? userRole,
  }) {
    return SalesDetailState(
      invoice: invoice ?? this.invoice,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [invoice, isLoading, error, userRole];
}
