import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/processing/dialog_name_enum.dart';
import 'package:gizmoglobe_client/enums/processing/notify_message_enum.dart';
import 'package:gizmoglobe_client/enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';


class ProductDetailState extends Equatable {
  final Product product;
  final Map<String, String> technicalSpecs;
  final ProcessState processState;
  final DialogName dialogName;
  final NotifyMessage notifyMessage;

  const ProductDetailState({
    required this.product,
    this.technicalSpecs = const {},
    this.processState = ProcessState.idle,
    this.dialogName = DialogName.empty,
    this.notifyMessage = NotifyMessage.empty,
  });

  @override
  List<Object?> get props => [product, technicalSpecs, processState, dialogName, notifyMessage];

  ProductDetailState copyWith({
    Product? product,
    Map<String, String>? technicalSpecs,
    ProcessState? processState,
    DialogName? dialogName,
    NotifyMessage? notifyMessage,
  }) {
    return ProductDetailState(
      product: product ?? this.product,
      technicalSpecs: technicalSpecs ?? this.technicalSpecs,
      processState: processState ?? this.processState,
      dialogName: dialogName ?? this.dialogName,
      notifyMessage: notifyMessage ?? this.notifyMessage,
    );
  }
}