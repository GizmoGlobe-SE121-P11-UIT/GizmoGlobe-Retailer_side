import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import '../../../../objects/invoice_related/sales_invoice_detail.dart';
import 'sales_detail_state.dart';

class SalesDetailCubit extends Cubit<SalesDetailState> {
  final Firebase _firebase = Firebase();

  SalesDetailCubit(SalesInvoice invoice) 
      : super(SalesDetailState(invoice: invoice)) {
    _loadInvoiceDetails();
  }

  Future<void> _loadInvoiceDetails() async {
    emit(state.copyWith(isLoading: true));
    try {
      final updatedInvoice = await _firebase.getSalesInvoiceWithDetails(state.invoice.salesInvoiceID!);
      emit(state.copyWith(
        invoice: updatedInvoice,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> updateSalesInvoice(SalesInvoice updatedInvoice) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _firebase.updateSalesInvoice(updatedInvoice);
      emit(state.copyWith(
        invoice: updatedInvoice,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
}
