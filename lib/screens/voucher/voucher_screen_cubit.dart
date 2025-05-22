import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_screen_state.dart';
import '../../../data/database/database.dart';

class VoucherScreenCubit extends Cubit<VoucherScreenState> {
  VoucherScreenCubit() : super(const VoucherScreenState());

  void initialize() {
    List<Voucher> voucherList = List.from(Database().voucherList);
    voucherList.sort((a, b) => a.startTime.compareTo(b.startTime));

    List<Voucher> upcomingList = [];
    List<Voucher> ongoingList = [];
    List<Voucher> inactiveList = [];

    for (var voucher in voucherList) {
      if (voucher.startTime.isAfter(DateTime.now())) {
        upcomingList.add(voucher);
      } else if (voucher.haveEndTime && voucher.endTime.isBefore(DateTime.now())) {
        inactiveList.add(voucher);
      } else {
        ongoingList.add(voucher);
      }
    }

    emit(state.copyWith(
      voucherList: voucherList,
      ongoingList: ongoingList,
      upcomingList: upcomingList,
      expiredList: expiredList,
    ));
  }
}

