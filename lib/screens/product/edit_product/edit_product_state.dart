import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/processing/dialog_name_enum.dart';
import 'package:gizmoglobe_client/enums/processing/notify_message_enum.dart';
import 'package:gizmoglobe_client/enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/objects/product_related/product_argument.dart';


class EditProductState extends Equatable {
  final ProductArgument? productArgument;
  final ProcessState processState;
  final DialogName dialogName;
  final NotifyMessage notifyMessage;

  const EditProductState({
    this.productArgument,
    this.processState = ProcessState.idle,
    this.dialogName = DialogName.empty,
    this.notifyMessage = NotifyMessage.empty,
  });

  @override
  List<Object?> get props => [productArgument, processState, dialogName, notifyMessage];

  EditProductState copyWith({
    ProductArgument? productArgument,
    ProcessState? processState,
    DialogName? dialogName,
    NotifyMessage? notifyMessage,
  }) {
    return EditProductState(
      productArgument: productArgument ?? this.productArgument,
      processState: processState ?? this.processState,
      dialogName: dialogName ?? this.dialogName,
      notifyMessage: notifyMessage ?? this.notifyMessage,
    );
  }
}