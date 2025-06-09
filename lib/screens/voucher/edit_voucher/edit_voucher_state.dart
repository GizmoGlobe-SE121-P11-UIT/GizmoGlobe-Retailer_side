import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/processing/dialog_name_enum.dart';
import 'package:gizmoglobe_client/enums/processing/notify_message_enum.dart';
import 'package:gizmoglobe_client/enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher_argument.dart';

class EditVoucherState extends Equatable {
  final VoucherArgument? voucherArgument;
  final ProcessState processState;
  final DialogName dialogName;
  final NotifyMessage notifyMessage;

  const EditVoucherState({
    this.voucherArgument,
    this.processState = ProcessState.idle,
    this.dialogName = DialogName.empty,
    this.notifyMessage = NotifyMessage.empty,
  });

  @override
  List<Object?> get props =>
      [voucherArgument, processState, dialogName, notifyMessage];

  EditVoucherState copyWith({
    VoucherArgument? voucherArgument,
    ProcessState? processState,
    DialogName? dialogName,
    NotifyMessage? notifyMessage,
  }) {
    return EditVoucherState(
      voucherArgument: voucherArgument ?? this.voucherArgument,
      processState: processState ?? this.processState,
      dialogName: dialogName ?? this.dialogName,
      notifyMessage: notifyMessage ?? this.notifyMessage,
    );
  }
}
