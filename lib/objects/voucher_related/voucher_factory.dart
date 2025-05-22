import 'package:gizmoglobe_client/objects/voucher_related/limited_percentage_voucher_with_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_related/limited_percentage_voucher_without_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_related/limited_amount_voucher_with_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_related/limited_amount_voucher_without_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_related/unlimited_percentage_voucher_with_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_related/unlimited_percentage_voucher_without_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_related/unlimited_amount_voucher_with_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_related/unlimited_amount_voucher_without_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';

typedef VoucherConstructor = Voucher Function(Map<String, dynamic>);

class VoucherFactory {
  static final Map<String, VoucherConstructor> voucherConstructors = {
    'limited_percentage_end': (props) => LimitedPercentageVoucherWithEndTime(
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      description: props['description'],

      maximumUsage: props['maximumUsage'],
      usageLeft: props['numberOfUsage'],
      maximumDiscountValue: props['maximumDiscountValue'],
      endTime: props['endTime'],
    )..voucherID = props['voucherID'],

    'limited_percentage_noend': (props) => LimitedPercentageVoucherWithoutEndTime(
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      description: props['description'],

      maximumUsage: props['maximumUsage'],
      usageLeft: props['numberOfUsage'],
      maximumDiscountValue: props['maximumDiscountValue'],
    )..voucherID = props['voucherID'],

    'limited_amount_end': (props) => LimitedAmountVoucherWithEndTime(
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      description: props['description'],

      maximumUsage: props['maximumUsage'],
      usageLeft: props['numberOfUsage'],
      endTime: props['endTime'],
    )..voucherID = props['voucherID'],

    'limited_amount_noend': (props) => LimitedAmountVoucherWithoutEndTime(
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      description: props['description'],

      maximumUsage: props['maximumUsage'],
      usageLeft: props['numberOfUsage'],
    )..voucherID = props['voucherID'],

    'unlimited_percentage_end': (props) => UnlimitedPercentageVoucherWithEndTime(
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      description: props['description'],

      maximumDiscountValue: props['maximumDiscountValue'],
      endTime: props['endTime'],
    )..voucherID = props['voucherID'],

    'unlimited_percentage_noend': (props) => UnlimitedPercentageVoucherWithoutEndTime(
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      description: props['description'],

      maximumDiscountValue: props['maximumDiscountValue'],
    )..voucherID = props['voucherID'],

    'unlimited_amount_end': (props) => UnlimitedAmountVoucherWithEndTime(
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      description: props['description'],

      endTime: props['endTime'],
    )..voucherID = props['voucherID'],

    'unlimited_amount_noend': (props) => UnlimitedAmountVoucherWithoutEndTime(
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      description: props['description'],
    )..voucherID = props['voucherID'],
  };

  static String getKey({
    required bool isLimited,
    required bool isPercentage,
    required bool haveEndTime,
  }) {
    return '${isLimited ? "limited" : "unlimited"}_'
        '${isPercentage ? "percentage" : "amount"}_'
        '${haveEndTime ? "end" : "noend"}';
  }

  static Voucher createVoucher({
    required bool isLimited,
    required bool isPercentage,
    required bool haveEndTime,
    required Map<String, dynamic> properties,
  }) {
    final key = getKey(
      isLimited: isLimited,
      isPercentage: isPercentage,
      haveEndTime: haveEndTime,
    );
    final constructor = voucherConstructors[key];
    if (constructor == null) throw Exception('Invalid voucher type: $key');
    return constructor(properties);
  }
}