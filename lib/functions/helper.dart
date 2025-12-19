import 'package:intl/intl.dart';

import 'converter.dart';
import 'package:flutter/widgets.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

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

  static String toMoneyFormat(num value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '', decimalDigits: 0);
    return formatter.format(value * 1000);
  }

  static String toCurrencyFormat(num value) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(value * 1000);
  }
}
