import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:gizmoglobe_client/screens/voucher/edit_voucher/edit_voucher_state.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';

import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../objects/voucher_related/voucher.dart';
import '../../../objects/voucher_related/voucher_argument.dart';

class EditVoucherCubit extends Cubit<EditVoucherState> {
  EditVoucherCubit({VoucherArgument? initialArgument})
      : super(EditVoucherState(
          voucherArgument: initialArgument ??
              VoucherArgument(
                isLimited: false,
                isPercentage: false,
                hasEndTime: false,
                isVisible: true,
                isEnabled: true,
                startTime: DateTime.now(),
                maxUsagePerPerson: 1,
                maximumUsage: 0,
                usageLeft: 0,
                maximumDiscountValue: 0.0,
              ),
        ));

  void updateVoucherArgument(VoucherArgument voucherArgument) {
    final now = DateTime.now();
    final hasEndTime = voucherArgument.hasEndTime ?? false;
    final isLimited = voucherArgument.isLimited ?? false;
    final isPercentage = voucherArgument.isPercentage ?? false;

    emit(state.copyWith(
      voucherArgument: voucherArgument.copyWith(
        isLimited: isLimited,
        isPercentage: isPercentage,
        hasEndTime: hasEndTime,
        isVisible: voucherArgument.isVisible ?? true,
        isEnabled: voucherArgument.isEnabled ?? true,
        startTime: voucherArgument.startTime ?? now,
        maxUsagePerPerson: voucherArgument.maxUsagePerPerson ?? 1,
        endTime: hasEndTime
            ? (voucherArgument.endTime ?? now.add(const Duration(days: 7)))
            : null,
        // Handle limited voucher fields
        maximumUsage: isLimited ? (voucherArgument.maximumUsage ?? 0) : 0,
        usageLeft: isLimited ? (voucherArgument.usageLeft ?? 0) : 0,
        // Handle percentage voucher fields
        maximumDiscountValue:
            isPercentage ? (voucherArgument.maximumDiscountValue ?? 0.0) : 0.0,
      ),
    ));
  }

  void toSuccess() {
    emit(state.copyWith(processState: ProcessState.success));
  }

  void toIdle() {
    emit(state.copyWith(processState: ProcessState.idle));
  }

  void editVoucher() async {
    emit(state.copyWith(processState: ProcessState.loading));
    try {
      Voucher voucher = state.voucherArgument!.createVoucher();
      await Firebase().updateVoucher(voucher);
      emit(state.copyWith(
          processState: ProcessState.success,
          dialogName: DialogName.success,
          notifyMessage: NotifyMessage.msg17));
    } catch (e, stack) {
      print('Edit voucher error: $e');
      print(stack);
      emit(state.copyWith(
          processState: ProcessState.failure,
          dialogName: DialogName.failure,
          notifyMessage: NotifyMessage.msg18));
    }
  }
}
