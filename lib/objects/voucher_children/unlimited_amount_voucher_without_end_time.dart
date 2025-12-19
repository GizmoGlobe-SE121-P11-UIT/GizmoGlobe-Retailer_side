import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import '../../enums/voucher_related/voucher_display_type.dart';
import '../../enums/voucher_related/voucher_status.dart';
import '../../functions/helper.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

class UnlimitedAmountVoucherWithoutEndTime extends Voucher {
  UnlimitedAmountVoucherWithoutEndTime({
    super.voucherID,
    required super.voucherName,
    required super.startTime,
    required super.discountValue,
    required super.minimumPurchase,
    required super.maxUsagePerPerson,
    required super.redeemPrice,
    required super.displayType,
    required super.isEnabled,
    super.enDescription,
    super.viDescription,
    super.isPercentage = false,
    super.hasEndTime = false,
    super.isLimited = false,
  });

  @override
  void updateVoucher({
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
    DateTime? endTime,
  }) {
    super.updateVoucher(
      voucherID: voucherID,
      voucherName: voucherName,
      startTime: startTime,
      discountValue: discountValue,
      minimumPurchase: minimumPurchase,
      maxUsagePerPerson: maxUsagePerPerson,
      redeemPrice: redeemPrice,
      displayType: displayType,
      isEnabled: isEnabled,
      enDescription: enDescription,
      viDescription: viDescription,
    );
  }

  @override
  Widget detailsWidget(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          voucherName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${s.discount} ${Helper.toCurrencyFormat(discountValue)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${s.minimumPurchase}: ${Helper.toCurrencyFormat(minimumPurchase)}',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          Helper.getShortVoucherTimeWithoutEnd(context, startTime),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Column(
          children: [
            Text(
              displayType == VoucherDisplayType.redeemable
                  ? '${displayType.description} for $redeemPrice'
                  : displayType.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          s.disabled,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        if (!isEnabled) const SizedBox(height: 4),
      ],
    );
  }

  @override
  VoucherTimeStatus get voucherTimeStatus {
    if (startTime.isAfter(DateTime.now())) {
      return VoucherTimeStatus.upcoming;
    }

    return VoucherTimeStatus.ongoing;
  }

  @override
  bool get voucherRanOut {
    return false;
  }

  @override
  UnlimitedAmountVoucherWithoutEndTime copyWith({
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
  }) {
    return UnlimitedAmountVoucherWithoutEndTime(
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
    );
  }
}
