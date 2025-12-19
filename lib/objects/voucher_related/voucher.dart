import 'package:flutter/cupertino.dart';
import 'package:gizmoglobe_client/enums/voucher_related/voucher_display_type.dart';

import '../../enums/voucher_related/voucher_status.dart';

abstract class Voucher {
  String? voucherID;
  String voucherName;
  DateTime startTime;
  int discountValue;
  int minimumPurchase;
  int maxUsagePerPerson;
  VoucherDisplayType displayType;
  bool isEnabled;
  String? enDescription;
  String? viDescription;
  int redeemPrice;

  bool isPercentage;
  bool hasEndTime;
  bool isLimited;

  Voucher({
    this.voucherID,
    required this.voucherName,
    required this.startTime,
    required this.discountValue,
    required this.minimumPurchase,
    required this.maxUsagePerPerson,
    required this.displayType,
    required this.isEnabled,
    this.enDescription,
    this.viDescription,
    required this.isPercentage,
    required this.hasEndTime,
    required this.isLimited,
    this.redeemPrice = 0,
  });

  void updateVoucher({
    String? voucherID,
    String? voucherName,
    int? discountValue,
    int? minimumPurchase,
    int? maxUsagePerPerson,
    DateTime? startTime,
    String? enDescription,
    String? viDescription,
    VoucherDisplayType? displayType,
    int? redeemPrice,
    bool? isEnabled,
  }) {
    this.voucherID = voucherID ?? this.voucherID;
    this.voucherName = voucherName ?? this.voucherName;
    this.startTime = startTime ?? this.startTime;
    this.discountValue = discountValue ?? this.discountValue;
    this.minimumPurchase = minimumPurchase ?? this.minimumPurchase;
    this.maxUsagePerPerson = maxUsagePerPerson ?? this.maxUsagePerPerson;
    this.displayType = displayType ?? this.displayType;
    this.isEnabled = isEnabled ?? this.isEnabled;
    this.enDescription = enDescription ?? this.enDescription;
    this.viDescription = viDescription ?? this.viDescription;
    this.redeemPrice = redeemPrice ?? this.redeemPrice;
  }

  Voucher copyWith({
    String? voucherID,
    String? voucherName,
    DateTime? startTime,
    int? discountValue,
    int? minimumPurchase,
    int? maxUsagePerPerson,
    int? redeemPrice,
    VoucherDisplayType? displayType,
    bool? isEnabled,
    String? enDescription,
    String? viDescription,

    bool? isPercentage,
    bool? hasEndTime,
    bool? isLimited,
  });

  VoucherTimeStatus get voucherTimeStatus;
  bool get voucherRanOut;
  Widget detailsWidget(BuildContext context);
}
