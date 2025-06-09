import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/enums/processing/dialog_name_enum.dart';
import 'package:gizmoglobe_client/enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/enums/voucher_related/voucher_status.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_state.dart';

class VoucherScreenCubit extends Cubit<VoucherScreenState> {
  final Firebase _firebase = Firebase();

  VoucherScreenCubit() : super(const VoucherScreenState());

  Future<void> initialize() async {
    try {
      emit(state.copyWith(processState: ProcessState.loading));

      final List<Voucher> voucherList = await _firebase.getVouchers();
      voucherList.sort((a, b) => a.startTime.compareTo(b.startTime));

      List<Voucher> upcomingList = [];
      List<Voucher> ongoingList = [];
      List<Voucher> inactiveList = [];

      final now = DateTime.now();

      for (var voucher in voucherList) {
        if (voucher.voucherTimeStatus == VoucherTimeStatus.expired ||
            voucher.voucherRanOut ||
            !voucher.isEnabled) {
          inactiveList.add(voucher);
        } else if (voucher.startTime.isAfter(now)) {
          upcomingList.add(voucher);
        } else {
          ongoingList.add(voucher);
        }
      }

      emit(state.copyWith(
        voucherList: voucherList,
        ongoingList: ongoingList,
        upcomingList: upcomingList,
        inactiveList: inactiveList,
        processState: ProcessState.idle,
      ));
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        dialogMessage: S.current.errorLoadingVouchers,
      ));
    }
  }

  void setSelectedVoucher(Voucher? voucher) {
    emit(state.copyWith(selectedVoucher: voucher));
  }

  Future<void> toggleVoucherStatus(String voucherId) async {
    try {
      emit(state.copyWith(processState: ProcessState.loading));

      // Find the voucher in the list
      final voucher =
          state.voucherList.firstWhere((v) => v.voucherID == voucherId);

      // Create a copy of the voucher with updated status
      final updatedVoucher = voucher;
      updatedVoucher.updateVoucher(isEnabled: !voucher.isEnabled);

      // Update the voucher in Firebase
      await _firebase.updateVoucher(updatedVoucher);

      await initialize(); // Refresh the list after status change

      emit(state.copyWith(
        processState: ProcessState.success,
        dialogName: DialogName.success,
        dialogMessage:
            updatedVoucher.isEnabled ? S.current.enabled : S.current.disabled,
      ));
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        dialogMessage: S.current.errorUpdatingVoucher,
      ));
    }
  }
}
