import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/database/database.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/product_related/product_argument.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_state.dart';

import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/category_enum.dart';
import '../../../objects/product_related/cpu.dart';
import '../../../objects/product_related/drive.dart';
import '../../../objects/product_related/gpu.dart';
import '../../../objects/product_related/mainboard.dart';
import '../../../objects/product_related/psu.dart';
import '../../../objects/product_related/ram.dart';
import 'add_product_state.dart';

class AddProductCubit extends Cubit<AddProductState> {
  AddProductCubit() : super(const AddProductState()) {
    initialize();
  }

  void initialize() {
    emit(state.copyWith(productArgument: ProductArgument(sales: 0, release: DateTime.now())));
  }

  void updateProductArgument(ProductArgument productArgument) {
    emit(state.copyWith(productArgument: productArgument));
  }

  void toIdle() {
    emit(state.copyWith(processState: ProcessState.idle));
  }

  Future<void> addProduct() async {
    emit(state.copyWith(processState: ProcessState.loading));
    try {
      Product product = state.productArgument!.buildProduct();
      await Firebase().addProduct(product);
      emit(state.copyWith(processState: ProcessState.success, dialogName: DialogName.success, notifyMessage: NotifyMessage.msg13));
    } catch (e) {
      emit(state.copyWith(processState: ProcessState.failure, dialogName: DialogName.failure, notifyMessage: NotifyMessage.msg14));
    }
  }
}