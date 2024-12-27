import 'package:flutter_bloc/flutter_bloc.dart';
import 'invoice_screen_state.dart';

class InvoiceScreenCubit extends Cubit<InvoiceScreenState> {
  InvoiceScreenCubit() : super(InvoiceScreenState());

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }
}
