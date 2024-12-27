import 'package:flutter_bloc/flutter_bloc.dart';
import 'incoming_screen_state.dart';

class IncomingScreenCubit extends Cubit<IncomingScreenState> {
  IncomingScreenCubit() : super(const IncomingScreenState()) {
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
