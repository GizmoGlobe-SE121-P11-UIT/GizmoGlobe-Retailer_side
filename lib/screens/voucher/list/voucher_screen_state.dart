import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';

import '../../../enums/processing/dialog_name_enum.dart';

class VoucherScreenState extends Equatable {
  final List<Voucher> voucherList;
  final List<Voucher> ongoingList;
  final List<Voucher> upcomingList;
  final List<Voucher> inactiveList;
  final ProcessState processState;
  final DialogName dialogName;
  final String dialogMessage;

  const VoucherScreenState({
    this.voucherList = const [],
    this.ongoingList = const [],
    this.upcomingList = const [],
    this.inactiveList = const [],
    this.processState = ProcessState.idle,
    this.dialogName = DialogName.empty,
    this.dialogMessage = '',
  });

  @override
  List<Object?> get props => [
    voucherList,
    ongoingList,
    upcomingList,
    inactiveList,
    processState,
    dialogName,
    dialogMessage,
  ];

  VoucherScreenState copyWith({
    List<Voucher>? voucherList,
    List<Voucher>? ongoingList,
    List<Voucher>? upcomingList,
    List<Voucher>? inactiveList,
    ProcessState? processState,
    DialogName? dialogName,
    String? dialogMessage,
  }) {
    return VoucherScreenState(
      voucherList: voucherList ?? this.voucherList,
      ongoingList: ongoingList ?? this.ongoingList,
      upcomingList: upcomingList ?? this.upcomingList,
      inactiveList: inactiveList ?? this.inactiveList,
      processState: processState ?? this.processState,
      dialogName: dialogName ?? this.dialogName,
      dialogMessage: dialogMessage ?? this.dialogMessage,
    );
  }
}