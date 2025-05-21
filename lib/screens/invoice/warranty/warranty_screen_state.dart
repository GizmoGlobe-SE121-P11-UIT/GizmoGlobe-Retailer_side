import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/warranty_invoice.dart';

enum SortField {
  date,
}

enum SortOrder {
  ascending,
  descending,
}

class WarrantyScreenState extends Equatable {
  final List<WarrantyInvoice> invoices;
  final bool isLoading;
  final String searchQuery;
  final int? selectedIndex;
  final String? userRole;
  final SortField? sortField;
  final SortOrder sortOrder;

  const WarrantyScreenState({
    this.invoices = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedIndex,
    this.userRole,
    this.sortField,
    this.sortOrder = SortOrder.descending,
  });

  WarrantyScreenState copyWith({
    List<WarrantyInvoice>? invoices,
    bool? isLoading,
    String? searchQuery,
    int? selectedIndex,
    String? userRole,
    SortField? sortField,
    SortOrder? sortOrder,
  }) {
    return WarrantyScreenState(
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