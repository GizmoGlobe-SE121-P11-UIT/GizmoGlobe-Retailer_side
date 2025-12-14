import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_method.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_filter_argument.dart';
import 'sales_filter_state.dart';

class SalesFilterCubit extends Cubit<SalesFilterState> {
  SalesFilterCubit() : super(const SalesFilterState());

  void initialize({required SalesFilterArgument initialFilterValue}) {
    emit(state.copyWith(filterArgument: initialFilterValue));
  }

  void updateFilterArgument(SalesFilterArgument newFilter) {
    emit(state.copyWith(filterArgument: newFilter));
  }

  void togglePaymentStatus(PaymentStatus status) {
    final current =
        List<PaymentStatus>.from(state.filterArgument.paymentStatusList);
    if (current.contains(status)) {
      current.remove(status);
    } else {
      current.add(status);
    }
    emit(state.copyWith(
      filterArgument: state.filterArgument.copyWith(paymentStatusList: current),
    ));
  }

  void toggleSalesStatus(SalesStatus status) {
    final current =
        List<SalesStatus>.from(state.filterArgument.salesStatusList);
    if (current.contains(status)) {
      current.remove(status);
    } else {
      current.add(status);
    }
    emit(state.copyWith(
      filterArgument: state.filterArgument.copyWith(salesStatusList: current),
    ));
  }

  void togglePaymentMethod(PaymentMethod method) {
    final current =
        List<PaymentMethod>.from(state.filterArgument.paymentMethodList);
    if (current.contains(method)) {
      current.remove(method);
    } else {
      current.add(method);
    }
    emit(state.copyWith(
      filterArgument: state.filterArgument.copyWith(paymentMethodList: current),
    ));
  }

  void resetFilters() {
    emit(const SalesFilterState());
  }
}
