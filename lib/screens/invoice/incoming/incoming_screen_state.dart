class IncomingScreenState {
  final bool isLoading;
  final List<IncomingInvoice> invoices;
  final int? selectedIndex;

  const IncomingScreenState({
    this.isLoading = false,
    this.invoices = const [],
    this.selectedIndex,
  });

  IncomingScreenState copyWith({
    bool? isLoading,
    List<IncomingInvoice>? invoices,
    int? selectedIndex,
  }) {
    return IncomingScreenState(
      isLoading: isLoading ?? this.isLoading,
      invoices: invoices ?? this.invoices,
      selectedIndex: selectedIndex,
    );
  }
}

class IncomingInvoice {
  final String id;
  final String date;
  // Add other properties as needed

  const IncomingInvoice({
    required this.id,
    required this.date,
  });
}
