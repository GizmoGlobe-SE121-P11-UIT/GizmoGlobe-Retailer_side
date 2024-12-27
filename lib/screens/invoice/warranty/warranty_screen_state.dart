class WarrantyScreenState {
  final bool isLoading;
  final List<WarrantyInvoice> invoices;
  final int? selectedIndex;

  const WarrantyScreenState({
    this.isLoading = false,
    this.invoices = const [],
    this.selectedIndex,
  });

  WarrantyScreenState copyWith({
    bool? isLoading,
    List<WarrantyInvoice>? invoices,
    int? selectedIndex,
  }) {
    return WarrantyScreenState(
      isLoading: isLoading ?? this.isLoading,
      invoices: invoices ?? this.invoices,
      selectedIndex: selectedIndex,
    );
  }
}

class WarrantyInvoice {
  final String id;
  final String date;
  // Add other properties as needed

  const WarrantyInvoice({
    required this.id,
    required this.date,
  });
}
