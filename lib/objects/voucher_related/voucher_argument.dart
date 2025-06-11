import 'package:gizmoglobe_client/objects/voucher_related/end_time_interface.dart';
import 'package:gizmoglobe_client/objects/voucher_related/percentage_interface.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher_factory.dart';

import 'limited_interface.dart';

class VoucherArgument {
  String? voucherID;
  String? voucherName;
  DateTime? startTime;
  double? discountValue;
  double? minimumPurchase;
  int? maxUsagePerPerson;
  bool? isVisible;
  bool? isEnabled;
  String? enDescription;
  String? viDescription;

  bool? isPercentage;
  bool? hasEndTime;
  bool? isLimited;

  double? maximumDiscountValue;

  int? maximumUsage;
  int? usageLeft;

  DateTime? endTime;

  VoucherArgument({
    this.voucherID,
    this.voucherName,
    this.startTime,
    this.discountValue,
    this.minimumPurchase,
    this.maxUsagePerPerson,
    this.isVisible,
    this.isEnabled,
    this.enDescription,
    this.viDescription,

    this.isPercentage,
    this.hasEndTime,
    this.isLimited,
    
    this.maximumDiscountValue,
    
    this.maximumUsage,
    this.usageLeft,
    
    this.endTime,
  });

  VoucherArgument copyWith({
    String? voucherID,
    String? voucherName,
    DateTime? startTime,
    double? discountValue,
    double? minimumPurchase,
    int? maxUsagePerPerson,
    bool? isVisible,
    bool? isEnabled,
    String? enDescription,
    String? viDescription,

    bool? isPercentage,
    bool? hasEndTime,
    bool? isLimited,

    double? maximumDiscountValue,

    int? maximumUsage,
    int? usageLeft,

    DateTime? endTime,
  }) {
    return VoucherArgument(
      voucherID: voucherID ?? this.voucherID,
      voucherName: voucherName ?? this.voucherName,
      startTime: startTime ?? this.startTime,
      discountValue: discountValue ?? this.discountValue,
      minimumPurchase: minimumPurchase ?? this.minimumPurchase,
      maxUsagePerPerson: maxUsagePerPerson ?? this.maxUsagePerPerson,
      isVisible: isVisible ?? this.isVisible,
      isEnabled: isEnabled ?? this.isEnabled,
      enDescription: enDescription ?? this.enDescription,
      viDescription: viDescription ?? this.viDescription,

      isPercentage: isPercentage ?? this.isPercentage,
      hasEndTime: hasEndTime ?? this.hasEndTime,
      isLimited: isLimited ?? this.isLimited,

      maximumDiscountValue: maximumDiscountValue ?? this.maximumDiscountValue,

      maximumUsage: maximumUsage ?? this.maximumUsage,
      usageLeft: usageLeft ?? this.usageLeft,

      endTime: endTime ?? this.endTime,
    );
  }

  Voucher createVoucher() {
    try {
      if (isLimited == null || isPercentage == null || hasEndTime == null) {
        throw Exception('Voucher type properties must not be null');
      }
      return VoucherFactory.createVoucher(
        isLimited: isLimited!,
        isPercentage: isPercentage!,
        hasEndTime: hasEndTime!,

        properties: {
          'voucherID': voucherID,
          'voucherName': voucherName,
          'startTime': startTime,
          'discountValue': discountValue,
          'minimumPurchase': minimumPurchase,
          'maxUsagePerPerson': maxUsagePerPerson,
          'isVisible': isVisible,
          'isEnabled': isEnabled,
          'enDescription': enDescription,
          'viDescription': viDescription,
          'maximumDiscountValue': maximumDiscountValue,
          'maximumUsage': maximumUsage,
          'usageLeft': usageLeft,
          'endTime': endTime,
          'isLimited': isLimited,
          'isPercentage': isPercentage,
          'hasEndTime': hasEndTime,
        },
      );
    } catch (e) {
      throw Exception('Failed to create voucher: $e');
    }
  }

  bool get isEnEmpty {
    return enDescription == null || enDescription!.isEmpty;
  }

  bool get isViEmpty {
    return viDescription == null || viDescription!.isEmpty;
  }

  static VoucherArgument fromVoucher(Voucher voucher) {
    VoucherArgument result = VoucherArgument(
      voucherID: voucher.voucherID,
      voucherName: voucher.voucherName,
      startTime: voucher.startTime,
      discountValue: voucher.discountValue,
      minimumPurchase: voucher.minimumPurchase,
      maxUsagePerPerson: voucher.maxUsagePerPerson,
      isVisible: voucher.isVisible,
      isEnabled: voucher.isEnabled,
      enDescription: voucher.enDescription,
      viDescription: voucher.viDescription,

      isPercentage: voucher.isPercentage,
      hasEndTime: voucher.hasEndTime,
      isLimited: voucher.isLimited,
    );

    if (voucher is PercentageInterface) {
      result.copyWith(maximumDiscountValue: (voucher as PercentageInterface).maximumDiscountValue);
    }

    if (voucher is LimitedInterface) {
      result.copyWith(
        maximumUsage: (voucher as LimitedInterface).maximumUsage,
        usageLeft: (voucher as LimitedInterface).usageLeft,
      );
    }

    if (voucher is EndTimeInterface) {
      result.copyWith(endTime: (voucher as EndTimeInterface).endTime);
    }

    return result;
  }
}