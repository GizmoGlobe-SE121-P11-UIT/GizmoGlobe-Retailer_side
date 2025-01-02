import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/objects/address_related/address.dart';
import 'sales_edit_state.dart';

class SalesEditCubit extends Cubit<SalesEditState> {
  final Firebase _firebase = Firebase();

  SalesEditCubit(SalesInvoice invoice) 
      : super(SalesEditState(
          invoice: invoice,
          selectedPaymentStatus: invoice.paymentStatus,
          selectedSalesStatus: invoice.salesStatus,
        )) {
    _init();
  }

  Future<void> _init() async {
    final userRole = await _firebase.getCurrentUserRole();
    emit(state.copyWith(userRole: userRole));
  }

  void updatePaymentStatus(PaymentStatus status) {
    final updatedInvoice = state.invoice.copyWith(paymentStatus: status);
    emit(state.copyWith(
      invoice: updatedInvoice,
      selectedPaymentStatus: status,
    ));
  }

  void updateSalesStatus(SalesStatus status) {
    final updatedInvoice = state.invoice.copyWith(salesStatus: status);
    emit(state.copyWith(
      invoice: updatedInvoice,
      selectedSalesStatus: status,
    ));
  }

  Future<SalesInvoice?> saveChanges() async {
    try {
      emit(state.copyWith(isLoading: true));
      await _firebase.updateSalesInvoice(state.invoice);
      emit(state.copyWith(isLoading: false));
      return state.invoice;
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
      return null;
    }
  }

  void updateAddress(Address address) {
    final updatedInvoice = state.invoice.copyWith(
      address: address,
    );
    emit(state.copyWith(invoice: updatedInvoice));
  }
} 