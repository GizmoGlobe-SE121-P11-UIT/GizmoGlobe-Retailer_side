import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/enums/voucher_related/distribution_type.dart';
import 'package:gizmoglobe_client/objects/voucher_related/percentage_interface.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import '../../enums/voucher_related/voucher_status.dart';
import '../../functions/helper.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

class UnlimitedPercentageVoucherWithoutEndTime extends Voucher
    implements PercentageInterface {
  int _maximumDiscountValue;

  UnlimitedPercentageVoucherWithoutEndTime({
    super.voucherID,
    required super.voucherName,
    required super.startTime,
    required super.discountValue,
    required super.minimumPurchase,
    required super.maxUsagePerPerson,
    required super.redeemPrice,
    required super.distributionType,
    required super.isEnabled,
    super.enDescription,
    super.viDescription,
    super.isPercentage = false,
    super.hasEndTime = true,
    super.isLimited = false,
    required int maximumDiscountValue,
  }) : _maximumDiscountValue = maximumDiscountValue;

  @override
  int get maximumDiscountValue => _maximumDiscountValue;
  @override
  set maximumDiscountValue(int value) => _maximumDiscountValue = value;

  @override
  void updateVoucher({
    String? voucherID,
    String? voucherName,
    DateTime? startTime,
    int? discountValue,
    int? minimumPurchase,
    int? maxUsagePerPerson,
    int? redeemPrice,
    DistributionType? distributionType,
    bool? isEnabled,
    String? enDescription,
    String? viDescription,
    DateTime? endTime,
    int? maximumDiscountValue,
  }) {
    super.updateVoucher(
      voucherID: voucherID,
      voucherName: voucherName,
      startTime: startTime,
      discountValue: discountValue,
      minimumPurchase: minimumPurchase,
      maxUsagePerPerson: maxUsagePerPerson,
      redeemPrice: redeemPrice,
      distributionType: distributionType,
      isEnabled: isEnabled,
      enDescription: enDescription,
      viDescription: viDescription,
    );

    this.maximumDiscountValue =
        maximumDiscountValue ?? this.maximumDiscountValue;
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
          '${s.discount} $discountValue% ${s.maximumDiscount}: ${Helper.toCurrencyFormat(maximumDiscountValue)}',
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
              distributionType == DistributionType.rewards
                ? '${distributionType.description} for $redeemPrice'
                : distributionType.description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        if (!isEnabled)
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
  UnlimitedPercentageVoucherWithoutEndTime copyWith({
    String? voucherID,
    String? voucherName,
    DateTime? startTime,
    int? discountValue,
    int? minimumPurchase,
    int? maxUsagePerPerson,
    int? redeemPrice,
    DistributionType? distributionType,
    bool? isEnabled,
    String? enDescription,
    String? viDescription,
    bool? isPercentage,
    bool? hasEndTime,
    bool? isLimited,
    DateTime? endTime,
    int? maximumDiscountValue,
  }) {
    return UnlimitedPercentageVoucherWithoutEndTime(
      voucherID: voucherID ?? this.voucherID,
      voucherName: voucherName ?? this.voucherName,
      startTime: startTime ?? this.startTime,
      discountValue: discountValue ?? this.discountValue,
      minimumPurchase: minimumPurchase ?? this.minimumPurchase,
      maxUsagePerPerson: maxUsagePerPerson ?? this.maxUsagePerPerson,
      redeemPrice: redeemPrice ?? this.redeemPrice,
      distributionType: distributionType ?? this.distributionType,
      isEnabled: isEnabled ?? this.isEnabled,
      enDescription: enDescription ?? this.enDescription,
      viDescription: viDescription ?? this.viDescription,
      isPercentage: isPercentage ?? this.isPercentage,
      hasEndTime: hasEndTime ?? this.hasEndTime,
      maximumDiscountValue: maximumDiscountValue ?? this.maximumDiscountValue,
    );
  }
}
