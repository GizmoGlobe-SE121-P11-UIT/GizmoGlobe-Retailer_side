import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_filter_argument.dart';

class SalesScreenState extends Equatable {
  final List<SalesInvoice> invoices;
  final bool isLoading;
  final String? error;
  final int? selectedIndex;
  final String searchQuery;
  final String userRole;
  final SalesFilterArgument filterArgument;

  const SalesScreenState({
    this.invoices = const [],
    this.isLoading = false,
    this.error,
    this.selectedIndex,
    this.searchQuery = '',
    this.userRole = '',
    this.filterArgument = const SalesFilterArgument(),
  });

  SalesScreenState copyWith({
    List<SalesInvoice>? invoices,
    bool? isLoading,
    String? error,
    int? selectedIndex,
    String? searchQuery,
    String? userRole,
    SalesFilterArgument? filterArgument,
  }) {
    return SalesScreenState(
      invoices: invoices ?? List.from(this.invoices),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedIndex: selectedIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      userRole: userRole ?? this.userRole,
      filterArgument: filterArgument ?? this.filterArgument,
    );
  }

  @override
  List<Object?> get props => [
        invoices,
        isLoading,
        error,
        selectedIndex,
        searchQuery,
        userRole,
        filterArgument
      ];
}
