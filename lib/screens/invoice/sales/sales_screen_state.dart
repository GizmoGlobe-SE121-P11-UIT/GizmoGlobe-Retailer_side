import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';

class SalesScreenState extends Equatable {
  final List<SalesInvoice> invoices;
  final bool isLoading;
  final String searchQuery;
  final int? selectedIndex;

  const SalesScreenState({
    this.invoices = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedIndex,
  });

  SalesScreenState copyWith({
    List<SalesInvoice>? invoices,
    bool? isLoading,
    String? searchQuery,
    int? selectedIndex,
  }) {
    return SalesScreenState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIndex: selectedIndex,
    );
  }

  @override
  List<Object?> get props => [invoices, isLoading, searchQuery, selectedIndex];
}
