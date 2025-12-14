class InvoiceScreenState {
  final int selectedTabIndex;
  final bool isChangingTab;

  InvoiceScreenState({
    required this.selectedTabIndex,
    this.isChangingTab = false,
  });

  InvoiceScreenState copyWith({
    int? selectedTabIndex,
    bool? isChangingTab,
  }) {
    return InvoiceScreenState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isChangingTab: isChangingTab ?? this.isChangingTab,
    );
  }
}
