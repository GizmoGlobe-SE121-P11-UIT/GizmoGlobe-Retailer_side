import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';

class SalesScreenState extends Equatable {
  final List<SalesInvoice> invoices;
  final bool isLoading;
  final String? error;
  final int? selectedIndex;
  final String searchQuery;
  final String userRole;

  const SalesScreenState({
    this.invoices = const [],
    this.isLoading = false,
    this.error,
    this.selectedIndex,
    this.searchQuery = '',
    this.userRole = '',
  });

  SalesScreenState copyWith({
    List<SalesInvoice>? invoices,
    bool? isLoading,
    String? error,
    int? selectedIndex,
    String? searchQuery,
    String? userRole,
  }) {
    return SalesScreenState(
      invoices: invoices ?? List.from(this.invoices),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedIndex: selectedIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [invoices, isLoading, error, selectedIndex, searchQuery, userRole];
}
