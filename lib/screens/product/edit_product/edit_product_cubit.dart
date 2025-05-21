import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/product_related/product_argument.dart';

import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import 'edit_product_state.dart';

class EditProductCubit extends Cubit<EditProductState> {
  EditProductCubit() : super(const EditProductState());

  void initialize(Product product) {
    ProductArgument productArgument = ProductArgument();
    emit(state.copyWith(productArgument: productArgument.fromProduct(product)));
  }

  void updateProductArgument(ProductArgument productArgument) {
    emit(state.copyWith(productArgument: productArgument));
  }

  void toIdle() {
    emit(state.copyWith(processState: ProcessState.idle));
  }

  Future<void> editProduct() async {
    emit(state.copyWith(processState: ProcessState.loading));
    try {
      Product product = state.productArgument!.buildProduct();
      await Firebase().updateProduct(product);
      emit(state.copyWith(processState: ProcessState.success, dialogName: DialogName.success, notifyMessage: NotifyMessage.msg15));
    } catch (e) {
      emit(state.copyWith(processState: ProcessState.failure, dialogName: DialogName.failure, notifyMessage: NotifyMessage.msg16));
    }
  }
}