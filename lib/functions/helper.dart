import 'converter.dart';
import 'package:flutter/widgets.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

class Helper {
  static String getShortVoucherTimeWithEnd(
      BuildContext context, DateTime startTime, DateTime endTime) {
    final now = DateTime.now();
    if (startTime.isAfter(now)) {
      return "${S.of(context).starts} ${Converter.getTimeUntilString(startTime)}";
    } else if (endTime.isAfter(now)) {
      return "${S.of(context).expires} ${Converter.getTimeLeftString(endTime)}";
    } else {
      return S.of(context).expired;
    }
  }

  static String getShortVoucherTimeWithoutEnd(
      BuildContext context, DateTime startTime) {
    final now = DateTime.now();
    if (startTime.isAfter(now)) {
      return "${S.of(context).starts} ${Converter.getTimeUntilString(startTime)}";
    } else {
      return S.of(context).ongoing;
    }
  }
}
