import 'package:flutter_bloc/flutter_bloc.dart';
import 'warranty_screen_state.dart';

class WarrantyScreenCubit extends Cubit<WarrantyScreenState> {
  WarrantyScreenCubit() : super(const WarrantyScreenState()) {
    loadInvoices();
  }

  Future<void> loadInvoices() async {
    emit(state.copyWith(isLoading: true));
    // TODO: Implement API call to load invoices
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
  }

  void searchInvoices(String query) {
    // TODO: Implement search logic
  }

  void setSelectedIndex(int? index) {
    emit(state.copyWith(selectedIndex: index));
  }
}
