import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import '../../enums/voucher_related/voucher_status.dart';

class LimitedAmountVoucherWithoutEndTime extends Voucher {
  int maximumUsage;
  int usageLeft;

  LimitedAmountVoucherWithoutEndTime({
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
    super.haveEndTime = false,
    super.isLimited = true,

    required this.maximumUsage,
    required this.usageLeft,
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

    int? maximumUsage,
    int? usageLeft,
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

    this.maximumUsage = maximumUsage ?? this.maximumUsage;
    this.usageLeft = usageLeft ?? this.usageLeft;
  }

  @override
  VoucherTimeStatus get voucherStatus {
    if (startTime.isAfter(DateTime.now())) {
      return VoucherTimeStatus.upcoming;
    }

    return VoucherTimeStatus.ongoing;
  }
}