import 'package:gizmoglobe_client/enums/voucher_related/voucher_display_type.dart';
import 'package:gizmoglobe_client/objects/voucher_related/end_time_interface.dart';
import 'package:gizmoglobe_client/objects/voucher_related/percentage_interface.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher_factory.dart';

import 'limited_interface.dart';

class VoucherArgument {
  String? voucherID;
  String? voucherName;
  DateTime? startTime;
  int? discountValue;
  int? minimumPurchase;
  int? maxUsagePerPerson;
  int? redeemPrice;
  VoucherDisplayType? displayType;
  bool? isEnabled;
  String? enDescription;
  String? viDescription;

  bool? isPercentage;
  bool? hasEndTime;
  bool? isLimited;

  int? maximumDiscountValue;

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
    this.redeemPrice,
    this.displayType,
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
    int? maximumDiscountValue,
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
      redeemPrice: redeemPrice ?? this.redeemPrice,
      displayType: displayType ?? this.displayType,
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

      // Validate required fields depending on chosen voucher options
      final List<String> missing = [];

      if (voucherName == null || voucherName!.trim().isEmpty) missing.add('Voucher Name');
      if (startTime == null) missing.add('Start Time');
      if (discountValue == null || discountValue == 0) missing.add('Discount Value');
      if (minimumPurchase == null || minimumPurchase == 0) missing.add('Minimum Purchase');
      if (maxUsagePerPerson == null || maxUsagePerPerson == 0) missing.add('Max Usage Per Person');

      if (isPercentage == true) {
        if (maximumDiscountValue == null || maximumDiscountValue == 0) missing.add('Maximum Discount Value');
      }

      if (isLimited == true) {
        if (maximumUsage == null || maximumUsage == 0) missing.add('Maximum Usage');
      }

      if (hasEndTime == true) {
        if (endTime == null) missing.add('End Time');
      }

      if (displayType == VoucherDisplayType.redeemable) {
        if (redeemPrice == null || redeemPrice == 0) missing.add('Redeem Price');
      }

      if (missing.isNotEmpty) {
        throw Exception('Missing required fields for voucher creation: ${missing.join(', ')}');
      }

      return VoucherFactory.createVoucher(
        isLimited: isLimited!,
        isPercentage: isPercentage!,
        hasEndTime: hasEndTime!,
        properties: {
          'voucherID': voucherID,
          'voucherName': voucherName,
          'startTime': startTime,
          'discountValue': discountValue ?? 0,
          'minimumPurchase': minimumPurchase ?? 0,
          'maxUsagePerPerson': maxUsagePerPerson ?? 1,
          'redeemPrice': redeemPrice ?? 0,
          'displayType': displayType != null ? displayType!.name : VoucherDisplayType.adminOnly.name,
          'isEnabled': isEnabled ?? true,
          'enDescription': enDescription ?? '',
          'viDescription': viDescription ?? '',
          'maximumDiscountValue': maximumDiscountValue ?? 0,
          'maximumUsage': maximumUsage ?? 0,
          'usageLeft': usageLeft ?? 0,
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
      redeemPrice: voucher.redeemPrice,
      displayType: voucher.displayType,
      isEnabled: voucher.isEnabled,
      enDescription: voucher.enDescription,
      viDescription: voucher.viDescription,
      isPercentage: voucher.isPercentage,
      hasEndTime: voucher.hasEndTime,
      isLimited: voucher.isLimited,

    );

    if (voucher is PercentageInterface) {
      result.copyWith(
          maximumDiscountValue:
              (voucher as PercentageInterface).maximumDiscountValue);
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
