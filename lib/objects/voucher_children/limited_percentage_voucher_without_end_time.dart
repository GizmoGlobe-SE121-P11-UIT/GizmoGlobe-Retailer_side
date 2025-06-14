import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/objects/voucher_related/percentage_interface.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import '../../enums/voucher_related/voucher_status.dart';
import '../../functions/helper.dart';
import '../voucher_related/limited_interface.dart';
import '../../generated/l10n.dart';

class LimitedPercentageVoucherWithoutEndTime extends Voucher
    implements LimitedInterface, PercentageInterface {
  int _maximumUsage;
  int _usageLeft;
  double _maximumDiscountValue;

  LimitedPercentageVoucherWithoutEndTime({
    super.voucherID,
    required super.voucherName,
    required super.startTime,
    required super.discountValue,
    required super.minimumPurchase,
    required super.maxUsagePerPerson,
    required super.isVisible,
    required super.isEnabled,
    super.enDescription,
    super.viDescription,
    super.isPercentage = true,
    super.hasEndTime = false,
    super.isLimited = true,
    required int maximumUsage,
    required int usageLeft,
    required double maximumDiscountValue,
  })  : _maximumUsage = maximumUsage,
        _usageLeft = usageLeft,
        _maximumDiscountValue = maximumDiscountValue;

  @override
  int get maximumUsage => _maximumUsage;
  @override
  set maximumUsage(int value) => _maximumUsage = value;

  @override
  int get usageLeft => _usageLeft;
  @override
  set usageLeft(int value) => _usageLeft = value;

  @override
  double get maximumDiscountValue => _maximumDiscountValue;
  @override
  set maximumDiscountValue(double value) => _maximumDiscountValue = value;

  @override
  void updateVoucher({
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
    int? maximumUsage,
    int? usageLeft,
    double? maximumDiscountValue,
  }) {
    super.updateVoucher(
      voucherID: voucherID,
      voucherName: voucherName,
      startTime: startTime,
      discountValue: discountValue,
      minimumPurchase: minimumPurchase,
      maxUsagePerPerson: maxUsagePerPerson,
      isVisible: isVisible,
      isEnabled: isEnabled,
      enDescription: enDescription,
      viDescription: viDescription,
    );

    this.maximumUsage = maximumUsage ?? this.maximumUsage;
    this.usageLeft = usageLeft ?? this.usageLeft;
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
          '${s.discount} $discountValue% ${s.maximumDiscount}: \$$maximumDiscountValue',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${s.minimumPurchase}: \$$minimumPurchase',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        usageLeft > 0
            ? Text(
                '${s.usageLeft}: $usageLeft/$maximumUsage',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              )
            : Text(
                s.ranOut,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
        const SizedBox(height: 4),
        Text(
          Helper.getShortVoucherTimeWithoutEnd(startTime),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        if (!isVisible)
          Text(
            s.hidden,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        if (!isVisible) const SizedBox(height: 4),
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
    if (usageLeft <= 0) {
      return true;
    }
    return false;
  }
}
