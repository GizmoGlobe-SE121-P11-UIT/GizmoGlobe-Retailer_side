import 'package:cloud_firestore/cloud_firestore.dart';

import '../../enums/voucher_related/voucher_status.dart';

abstract class Voucher {
  String? voucherID;
  String voucherName;
  DateTime startTime;
  double discountValue;
  double minimumPurchase;
  int maxUsagePerPerson;
  bool isVisible;
  bool isEnabled;
  String? description;

  bool isPercentage;
  bool haveEndTime;
  bool isLimited;

  Voucher({
    this.voucherID,
    required this.voucherName,
    required this.startTime,
    required this.discountValue,
    required this.minimumPurchase,
    required this.maxUsagePerPerson,
    required this.isVisible,
    required this.isEnabled,
    this.description,

    required this.isPercentage,
    required this.haveEndTime,
    required this.isLimited,
  });

  void updateVoucher({
    String? voucherID,
    String? voucherName,
    DateTime? startTime,
    double? discountValue,
    double? minimumPurchase,
    int? maxUsagePerPerson,
    bool? isVisible,
    bool? isEnabled,
    String? description,
  }) {
    this.voucherID = voucherID ?? this.voucherID;
    this.voucherName = voucherName ?? this.voucherName;
    this.startTime = startTime ?? this.startTime;
    this.discountValue = discountValue ?? this.discountValue;
    this.minimumPurchase = minimumPurchase ?? this.minimumPurchase;
    this.maxUsagePerPerson = maxUsagePerPerson ?? this.maxUsagePerPerson;
    this.isVisible = isVisible ?? this.isVisible;
    this.isEnabled = isEnabled ?? this.isEnabled;
    this.description = description ?? this.description;
  }

  // Map<String, dynamic> toMap() {
  //   return {
  //     'voucherName': voucherName,
  //     'startTime': Timestamp.fromDate(startTime),
  //     'haveEndTime': haveEndTime,
  //     'endTime': haveEndTime ? Timestamp.fromDate(endTime) : null,
  //     'isPercentage': isPercentage,
  //     'discountValue': discountValue,
  //     'minimumPurchase': minimumPurchase,
  //     'maximumUsage': maximumValue,
  //     'quantity': usageLeft,
  //     'maxUsagePerPerson': maxUsagePerPerson,
  //     'description': description ?? '',
  //     'isVisible': isVisible,
  //     'isEnabled': isEnabled,
  //   };
  // }

  // static Voucher fromMap(String id, Map<String, dynamic> map) {
  //   Voucher voucher = Voucher(
  //     voucherID: id,
  //     voucherName: map['voucherName'],
  //     startTime: (map['startTime'] as Timestamp).toDate(),
  //     haveEndTime: map['haveEndTime'],
  //     endTime: map['haveEndTime'] == true
  //         ? (map['endTime'] as Timestamp).toDate()
  //         : DateTime.now(),
  //     isPercentage: map['isPercentage'],
  //     discountValue: (map['discountValue'] as num).toDouble(),
  //     minimumPurchase: (map['minimumPurchase'] as num).toDouble(),
  //     maximumValue: (map['maximumUsage'] as num).toDouble(),
  //     usageLeft: map['usageLeft'],
  //     maxUsagePerPerson: map['maxUsagePerPerson'],
  //     description: map['description'] ?? '',
  //     isVisible: map['isVisible'] ?? true,
  //     isEnabled: map['isEnabled'] ?? true,
  //     );
  //
  //   return voucher;
  // }

  VoucherTimeStatus get voucherStatus;
}

