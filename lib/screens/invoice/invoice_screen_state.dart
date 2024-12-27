class InvoiceScreenState {
  final int selectedTabIndex;

  InvoiceScreenState({
    this.selectedTabIndex = 0,
  });

  InvoiceScreenState copyWith({
    int? selectedTabIndex,
  }) {
    return InvoiceScreenState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
}
