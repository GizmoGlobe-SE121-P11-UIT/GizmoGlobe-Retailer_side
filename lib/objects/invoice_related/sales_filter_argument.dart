import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_method.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';

class SalesFilterArgument extends Equatable {
  final List<PaymentStatus> paymentStatusList;
  final List<SalesStatus> salesStatusList;
  final List<PaymentMethod> paymentMethodList;

  const SalesFilterArgument({
    this.paymentStatusList = const [],
    this.salesStatusList = const [],
    this.paymentMethodList = const [],
  });

  SalesFilterArgument copyWith({
    List<PaymentStatus>? paymentStatusList,
    List<SalesStatus>? salesStatusList,
    List<PaymentMethod>? paymentMethodList,
  }) {
    return SalesFilterArgument(
      paymentStatusList: paymentStatusList ?? this.paymentStatusList,
      salesStatusList: salesStatusList ?? this.salesStatusList,
      paymentMethodList: paymentMethodList ?? this.paymentMethodList,
    );
  }

  bool get hasActiveFilters =>
      paymentStatusList.isNotEmpty ||
      salesStatusList.isNotEmpty ||
      paymentMethodList.isNotEmpty;

  @override
  List<Object?> get props => [
        paymentStatusList,
        salesStatusList,
        paymentMethodList,
      ];
}
