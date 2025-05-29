import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/voucher_related/voucher_status.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_state.dart';
import '../../../../data/database/database.dart';

class VoucherScreenCubit extends Cubit<VoucherScreenState> {
  VoucherScreenCubit() : super(const VoucherScreenState());

  void initialize() {
    List<Voucher> voucherList = Database().voucherList;
    voucherList.sort((a, b) => a.startTime.compareTo(b.startTime));

    List<Voucher> upcomingList = [];
    List<Voucher> ongoingList = [];
    List<Voucher> inactiveList = [];

    final now = DateTime.now();

    for (var voucher in voucherList) {
      if (voucher.voucherTimeStatus == VoucherTimeStatus.expired || voucher.voucherRanOut || !voucher.isEnabled) {
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
    ));
  }
}

