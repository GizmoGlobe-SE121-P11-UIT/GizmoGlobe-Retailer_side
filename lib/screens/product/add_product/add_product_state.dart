import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/processing/dialog_name_enum.dart';
import 'package:gizmoglobe_client/enums/processing/notify_message_enum.dart';
import 'package:gizmoglobe_client/enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/objects/product_related/product_argument.dart';

class AddProductState extends Equatable {
  final ProductArgument? productArgument;
  final ProcessState processState;
  final DialogName dialogName;
  final NotifyMessage notifyMessage;
  final String? imageUrl;
  final bool isUploadingImage;

  const AddProductState({
    this.productArgument,
    this.processState = ProcessState.idle,
    this.dialogName = DialogName.empty,
    this.notifyMessage = NotifyMessage.empty,
    this.imageUrl,
    this.isUploadingImage = false,
  });

  @override
  List<Object?> get props => [
        productArgument,
        processState,
        dialogName,
        notifyMessage,
        imageUrl,
        isUploadingImage,
      ];

  AddProductState copyWith({
    ProductArgument? productArgument,
    ProcessState? processState,
    DialogName? dialogName,
    NotifyMessage? notifyMessage,
    String? imageUrl,
    bool? isUploadingImage,
  }) {
    return AddProductState(
      productArgument: productArgument ?? this.productArgument,
      processState: processState ?? this.processState,
      dialogName: dialogName ?? this.dialogName,
      notifyMessage: notifyMessage ?? this.notifyMessage,
      imageUrl: imageUrl ?? this.imageUrl,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
    );
  }
}
