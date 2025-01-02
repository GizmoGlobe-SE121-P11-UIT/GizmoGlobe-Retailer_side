import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice.dart';

enum SortField {
  date,
  totalPrice,
}

enum SortOrder {
  ascending,
  descending,
}

class IncomingScreenState extends Equatable {
  final List<IncomingInvoice> invoices;
  final bool isLoading;
  final String searchQuery;
  final int? selectedIndex;
  final String? userRole;
  final SortField? sortField;
  final SortOrder sortOrder;

  const IncomingScreenState({
    this.invoices = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedIndex,
    this.userRole,
    this.sortField,
    this.sortOrder = SortOrder.descending,
  });

  IncomingScreenState copyWith({
    List<IncomingInvoice>? invoices,
    bool? isLoading,
    String? searchQuery,
    int? selectedIndex,
    String? userRole,
    SortField? sortField,
    SortOrder? sortOrder,
  }) {
    return IncomingScreenState(
      invoices: invoices ?? this.invoices,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIndex: selectedIndex,
      userRole: userRole ?? this.userRole,
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  List<Object?> get props => [
    invoices, 
    isLoading, 
    searchQuery, 
    selectedIndex, 
    userRole,
    sortField,
    sortOrder,
  ];
}
