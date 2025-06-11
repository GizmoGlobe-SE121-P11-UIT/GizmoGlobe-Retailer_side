import 'package:gizmoglobe_client/objects/voucher_children/limited_percentage_voucher_with_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_children/limited_percentage_voucher_without_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_children/limited_amount_voucher_with_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_children/limited_amount_voucher_without_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_children/unlimited_percentage_voucher_with_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_children/unlimited_percentage_voucher_without_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_children/unlimited_amount_voucher_with_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_children/unlimited_amount_voucher_without_end_time.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';

typedef VoucherConstructor = Voucher Function(Map<String, dynamic>);

class VoucherFactory {
  static final Map<String, VoucherConstructor> voucherConstructors = {
    'limited_percentage_end': (props) => LimitedPercentageVoucherWithEndTime(
      voucherID: props['voucherID'],
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      enDescription: props['enDescription'],
      viDescription: props['viDescription'],
      // Explicitly set the boolean flags
      isPercentage: true,
      isLimited: true,
      hasEndTime: true,
      maximumUsage: props['maximumUsage'],
      usageLeft: props['usageLeft'],
      maximumDiscountValue: props['maximumDiscountValue'],
      endTime: props['endTime'],
    ),

    'limited_percentage_noend': (props) => LimitedPercentageVoucherWithoutEndTime(
      voucherID: props['voucherID'],
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      enDescription: props['enDescription'],
      viDescription: props['viDescription'],
      // Explicitly set the boolean flags
      isPercentage: true,
      isLimited: true,
      hasEndTime: false,
      maximumUsage: props['maximumUsage'],
      usageLeft: props['usageLeft'],
      maximumDiscountValue: props['maximumDiscountValue'],
    ),

    'limited_amount_end': (props) => LimitedAmountVoucherWithEndTime(
      voucherID: props['voucherID'],
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      enDescription: props['enDescription'],
      viDescription: props['viDescription'],
      // Explicitly set the boolean flags
      isPercentage: false,
      isLimited: true,
      hasEndTime: true,
      maximumUsage: props['maximumUsage'],
      usageLeft: props['usageLeft'],
      endTime: props['endTime'],
    ),

    'limited_amount_noend': (props) => LimitedAmountVoucherWithoutEndTime(
      voucherID: props['voucherID'],
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      enDescription: props['enDescription'],
      viDescription: props['viDescription'],
      // Explicitly set the boolean flags
      isPercentage: false,
      isLimited: true,
      hasEndTime: false,
      maximumUsage: props['maximumUsage'],
      usageLeft: props['usageLeft'],
    ),

    'unlimited_percentage_end': (props) => UnlimitedPercentageVoucherWithEndTime(
      voucherID: props['voucherID'],
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      enDescription: props['enDescription'],
      viDescription: props['viDescription'],
      // Explicitly set the boolean flags
      isPercentage: true,
      isLimited: false,
      hasEndTime: true,
      maximumDiscountValue: props['maximumDiscountValue'],
      endTime: props['endTime'],
    ),

    'unlimited_percentage_noend': (props) => UnlimitedPercentageVoucherWithoutEndTime(
      voucherID: props['voucherID'],
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      enDescription: props['enDescription'],
      viDescription: props['viDescription'],
      // Explicitly set the boolean flags
      isPercentage: true,
      isLimited: false,
      hasEndTime: false,
      maximumDiscountValue: props['maximumDiscountValue'],
    ),

    'unlimited_amount_end': (props) => UnlimitedAmountVoucherWithEndTime(
      voucherID: props['voucherID'],
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      enDescription: props['enDescription'],
      viDescription: props['viDescription'],
      // Explicitly set the boolean flags
      isPercentage: false,
      isLimited: false,
      hasEndTime: true,
      endTime: props['endTime'],
    ),

    'unlimited_amount_noend': (props) => UnlimitedAmountVoucherWithoutEndTime(
      voucherID: props['voucherID'],
      voucherName: props['voucherName'],
      startTime: props['startTime'],
      discountValue: props['discountValue'],
      minimumPurchase: props['minimumPurchase'],
      maxUsagePerPerson: props['maxUsagePerPerson'],
      isVisible: props['isVisible'],
      isEnabled: props['isEnabled'],
      enDescription: props['enDescription'],
      viDescription: props['viDescription'],
      // Explicitly set the boolean flags
      isPercentage: false,
      isLimited: false,
      hasEndTime: false,
    ),
  };

  static String getKey({
    required bool isLimited,
    required bool isPercentage,
    required bool hasEndTime,
  }) {
    return '${isLimited ? "limited" : "unlimited"}_'
        '${isPercentage ? "percentage" : "amount"}_'
        '${hasEndTime ? "end" : "noend"}';
  }

  static Voucher createVoucher({
    required bool isLimited,
    required bool isPercentage,
    required bool hasEndTime,
    required Map<String, dynamic> properties,
  }) {
    final key = getKey(
      isLimited: isLimited,
      isPercentage: isPercentage,
      hasEndTime: hasEndTime,
    );
    final constructor = voucherConstructors[key];
    if (constructor == null) throw Exception('Invalid voucher type: $key');
    return constructor(properties);
  }

  static Voucher fromMap(String voucherID, Map<String, dynamic> map) {
    return createVoucher(
      isLimited: map['isLimited'] as bool,
      isPercentage: map['isPercentage'] as bool,
      hasEndTime: map['hasEndTime'] as bool,
      properties: map,
    );
  }
}