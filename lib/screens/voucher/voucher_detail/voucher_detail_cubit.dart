import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_detail/voucher_detail_state.dart';

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

  void changeVoucherStatus() {
    Voucher newVoucher = state.voucher;
    newVoucher.updateVoucher(isEnabled: !newVoucher.isEnabled);
    emit(state.copyWith(voucher: newVoucher));
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
