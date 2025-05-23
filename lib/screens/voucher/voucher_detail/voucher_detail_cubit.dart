import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/database/database.dart';
import 'package:gizmoglobe_client/enums/voucher_related/voucher_status.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_detail/voucher_detail_state.dart';

import '../../../data/firebase/firebase.dart';
import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../../objects/voucher_related/voucher.dart';

class VoucherDetailCubit extends Cubit<VoucherDetailState> {
  VoucherDetailCubit(Voucher voucher) : super(VoucherDetailState(voucher: voucher));

  void toLoading() {
    emit(state.copyWith(processState: ProcessState.loading));
  }

  void toIdle() {
    emit(state.copyWith(processState: ProcessState.idle));
  }

  // Future<void> changeProductStatus() async {
  //   try {
  //     ProductStatusEnum status;
  //     if (state.product.status == ProductStatusEnum.discontinued) {
  //       if (state.product.stock == 0) {
  //         status = ProductStatusEnum.outOfStock;
  //       } else {
  //         status = ProductStatusEnum.active;
  //       }
  //     } else {
  //       status = ProductStatusEnum.discontinued;
  //     }
  //
  //     await Firebase().changeProductStatus(state.product.productID!, status);
  //
  //     Product product = state.product;
  //     product.updateProduct(status: status);
  //     emit(state.copyWith(product: product));
  //
  //     emit(state.copyWith(processState: ProcessState.success, notifyMessage: NotifyMessage.msg15, dialogName: DialogName.success));
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //     emit(state.copyWith(processState: ProcessState.failure, notifyMessage: NotifyMessage.msg16, dialogName: DialogName.failure));
  //   }
  // }
  //
  // void updateProduct() {
  //   Product product = Database().productList.firstWhere((element) => element.productID == state.product.productID);
  //   emit(state.copyWith(product: product));
  //   _initializeTechnicalSpecs();
  // }

}