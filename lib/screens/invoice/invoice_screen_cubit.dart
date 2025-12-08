import 'package:flutter_bloc/flutter_bloc.dart';
import 'invoice_screen_state.dart';

class InvoiceScreenCubit extends Cubit<InvoiceScreenState> {
  static int _lastSelectedTabIndex = 0;

  static int get lastSelectedTabIndex => _lastSelectedTabIndex;

  InvoiceScreenCubit({int? initialTabIndex})
      : super(InvoiceScreenState(
            selectedTabIndex: initialTabIndex ?? _lastSelectedTabIndex));

  Future<void> changeTab(int index) async {
    _lastSelectedTabIndex = index;
    // Update tab index immediately and start loading
    emit(state.copyWith(
      selectedTabIndex: index,
      isChangingTab: true,
    ));

    // Wait at least 1 second before hiding loading indicator
    await Future.delayed(const Duration(seconds: 1));

    // Hide loading indicator after the delay
    emit(state.copyWith(isChangingTab: false));
  }
}
