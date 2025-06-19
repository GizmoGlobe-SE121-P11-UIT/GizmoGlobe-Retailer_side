import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/objects/voucher_related/percentage_interface.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import '../../enums/voucher_related/voucher_status.dart';
import '../../functions/helper.dart';
import '../voucher_related/end_time_interface.dart';
import '../voucher_related/limited_interface.dart';
import '../../generated/l10n.dart';

class LimitedPercentageVoucherWithEndTime extends Voucher
    implements LimitedInterface, EndTimeInterface, PercentageInterface {
  int _maximumUsage;
  int _usageLeft;
  double _maximumDiscountValue;
  DateTime _endTime;

  LimitedPercentageVoucherWithEndTime({
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
    super.hasEndTime = true,
    super.isLimited = true,
    required int maximumUsage,
    required int usageLeft,
    required DateTime endTime,
    required double maximumDiscountValue,
  })  : _maximumUsage = maximumUsage,
        _usageLeft = usageLeft,
        _endTime = endTime,
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
  DateTime get endTime => _endTime;
  @override
  set endTime(DateTime value) => _endTime = value;

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
    DateTime? endTime,
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
      enDescription: enDescription,
      viDescription: viDescription,
    );

    this.maximumUsage = maximumUsage ?? this.maximumUsage;
    this.usageLeft = usageLeft ?? this.usageLeft;
    this.endTime = endTime ?? this.endTime;
    this.maximumDiscountValue =
        maximumDiscountValue ?? this.maximumDiscountValue;
  }

  @override
  Widget detailsWidget(BuildContext context) {
    final theme = Theme.of(context);
    final s = S.of(context);
    String time =
        Helper.getShortVoucherTimeWithEnd(context, startTime, endTime);

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
          time,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: time == s.expired
                ? theme.colorScheme.error
                : theme.colorScheme.onSurface,
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
    if (endTime.isBefore(DateTime.now())) {
      return VoucherTimeStatus.expired;
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

  @override
  LimitedPercentageVoucherWithEndTime copyWith({
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
    int? maximumUsage,
    int? usageLeft,
    DateTime? endTime,
    double? maximumDiscountValue,
  }) {
    return LimitedPercentageVoucherWithEndTime(
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
      maximumUsage: maximumUsage ?? this.maximumUsage,
      usageLeft: usageLeft ?? this.usageLeft,
      endTime: endTime ?? this.endTime,
      maximumDiscountValue: maximumDiscountValue ?? this.maximumDiscountValue,
    );
  }
}
