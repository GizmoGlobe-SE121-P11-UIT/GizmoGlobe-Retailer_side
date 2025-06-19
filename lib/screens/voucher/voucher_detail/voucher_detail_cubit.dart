import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_detail/voucher_detail_state.dart';

import '../../../data/firebase/firebase.dart';
import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../objects/voucher_related/voucher.dart';
import '../../../data/database/database.dart';

class VoucherDetailCubit extends Cubit<VoucherDetailState> {
  VoucherDetailCubit(Voucher voucher)
      : super(VoucherDetailState(voucher: voucher));

  void toLoading() {
    emit(state.copyWith(processState: ProcessState.loading));
  }

  void toIdle() {
    emit(state.copyWith(processState: ProcessState.idle));
  }

  Future<void> changeVoucherStatus() async {
    try {
      final bool status = !state.voucher.isEnabled;

      await Firebase().changeVoucherStatus(state.voucher.voucherID!, status);

      final updatedVoucher = state.voucher.copyWith(isEnabled: status);
      emit(state.copyWith(voucher: updatedVoucher, processState: ProcessState.success, notifyMessage: NotifyMessage.msg24, dialogName: DialogName.success));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(state.copyWith(processState: ProcessState.failure, notifyMessage: NotifyMessage.msg25, dialogName: DialogName.failure));
    }
  }

  void updateVoucher() async {
    // Fetch the latest voucher from the database by ID
    final voucherID = state.voucher.voucherID;
    if (voucherID == null) return;
    final vouchers = Database().voucherList;
    final updated = vouchers.firstWhere(
      (v) => v.voucherID == voucherID,
      orElse: () => state.voucher,
    );
    emit(state.copyWith(voucher: updated));
  }

  // void updateProduct() {
  //   Product product = Database().productList.firstWhere((element) => element.productID == state.product.productID);
  //   emit(state.copyWith(product: product));
  //   _initializeTechnicalSpecs();
  // }
}
