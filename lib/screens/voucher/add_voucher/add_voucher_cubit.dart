import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/voucher/add_voucher/add_voucher_state.dart';

import '../../../data/database/database.dart';
import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../objects/voucher_related/voucher.dart';
import '../../../objects/voucher_related/voucher_argument.dart';

class AddVoucherCubit extends Cubit<AddVoucherState> {
  AddVoucherCubit() : super(const AddVoucherState()) {
    initialize();
  }

  void initialize() {
    emit(state.copyWith(voucherArgument: VoucherArgument(
      startTime: DateTime.now(),
      isVisible: true,
      isEnabled: true,

      isPercentage: false,
      hasEndTime: false,
      isLimited: false,

      endTime: DateTime.now().add(const Duration(days: 30)),
    )));
  }

  void updateVoucherArgument(VoucherArgument voucherArgument) {
    emit(state.copyWith(voucherArgument: voucherArgument));
  }

  void toSuccess() {
    emit(state.copyWith(processState: ProcessState.success));
  }

  void toIdle() {
    emit(state.copyWith(processState: ProcessState.idle));
  }

  void addVoucher() {
    emit(state.copyWith(processState: ProcessState.loading));
    try {
      Voucher voucher = state.voucherArgument!.createVoucher();
      // await Firebase().addVoucher(voucher);
      Database().voucherList.add(voucher);
      emit(state.copyWith(processState: ProcessState.success, dialogName: DialogName.success, notifyMessage: NotifyMessage.msg17));
    } catch (e) {
      emit(state.copyWith(processState: ProcessState.failure, dialogName: DialogName.failure, notifyMessage: NotifyMessage.msg18));
    }
  }
}