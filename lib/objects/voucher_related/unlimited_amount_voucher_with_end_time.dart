import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import '../../enums/voucher_related/voucher_status.dart';

class UnlimitedAmountVoucherWithEndTime extends Voucher {
  DateTime endTime;

  UnlimitedAmountVoucherWithEndTime({
    super.voucherID,
    required super.voucherName,
    required super.startTime,
    required super.discountValue,
    required super.minimumPurchase,
    required super.maxUsagePerPerson,
    required super.isVisible,
    required super.isEnabled,
    super.description,

    super.isPercentage = true,
    super.haveEndTime = true,
    super.isLimited = false,

    required this.endTime,
  });

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
    String? description,

    DateTime? endTime,
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
      description: description,
    );

    this.endTime = endTime ?? this.endTime;
  }

  @override
  VoucherTimeStatus get voucherStatus {
    if (startTime.isAfter(DateTime.now())) {
      return VoucherTimeStatus.upcoming;
    }
    if (endTime.isBefore(DateTime.now())) {
      return VoucherTimeStatus.expired;
    }
    return VoucherTimeStatus.ongoing;
  }
}