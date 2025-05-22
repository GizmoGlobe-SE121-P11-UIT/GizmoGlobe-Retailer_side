import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';

import '../../enums/processing/dialog_name_enum.dart';

class VoucherScreenState extends Equatable {
  final List<Voucher> voucherList;
  final List<Voucher> ongoingList;
  final List<Voucher> upcomingList;
  final List<Voucher> expiredList;
  final ProcessState processState;
  final DialogName dialogName;
  final String dialogMessage;

  const VoucherScreenState({
    this.voucherList = const [],
    this.ongoingList = const [],
    this.upcomingList = const [],
    this.expiredList = const [],
    this.processState = ProcessState.idle,
    this.dialogName = DialogName.empty,
    this.dialogMessage = '',
  });

  @override
  List<Object?> get props => [
    voucherList,
    ongoingList,
    upcomingList,
    expiredList,
    processState,
    dialogName,
    dialogMessage,
  ];

  VoucherScreenState copyWith({
    List<Voucher>? voucherList,
    List<Voucher>? ongoingList,
    List<Voucher>? upcomingList,
    List<Voucher>? expiredList,
    ProcessState? processState,
    DialogName? dialogName,
    String? dialogMessage,
  }) {
    return VoucherScreenState(
      voucherList: voucherList ?? this.voucherList,
      ongoingList: ongoingList ?? this.ongoingList,
      upcomingList: upcomingList ?? this.upcomingList,
      expiredList: expiredList ?? this.expiredList,
      processState: processState ?? this.processState,
      dialogName: dialogName ?? this.dialogName,
      dialogMessage: dialogMessage ?? this.dialogMessage,
    );
  }
}