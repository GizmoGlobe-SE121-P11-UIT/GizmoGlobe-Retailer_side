import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/functions/converter.dart';
import '../../enums/voucher_related/voucher_status.dart';
import '../../objects/voucher_related/voucher.dart';
import '../general/app_text_style.dart';

class VoucherWidget extends StatelessWidget {
  final Voucher voucher;
  final VoidCallback onPressed;

  const VoucherWidget({
    super.key,
    required this.voucher,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(voucher.voucherName, style: AppTextStyle.regularTitle),
              const SizedBox(height: 4),
              detailsBuilder(context, voucher),
            ],
          ),
        ),
      ),
    );
  }
}

Widget detailsBuilder(BuildContext context, Voucher voucher) {
  final List<Widget> details = [];

  if (voucher.isLimited) {
    details.add(
      Text('Usage left: ${voucher}', style: AppTextStyle.regularText),
    );
  }

  if (voucher is HasEndTime) {
    final now = DateTime.now();
    final diff = voucher.endTime.difference(now);
    String expiry;
    if (diff.isNegative) {
      expiry = 'Expired';
    } else if (diff.inMinutes < 60) {
      expiry = 'in ${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'}';
    } else if (diff.inHours < 24) {
      expiry = 'in ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}';
    } else {
      expiry = 'in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
    }
    details.add(
      Text('Expires $expiry', style: AppTextStyle.regularText),
    );
  }

  if (details.isEmpty) {
    details.add(
      Text('No extra details', style: AppTextStyle.regularText),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: details,
  );
}

String getTimeLeftString(DateTime endTime) {
  final now = DateTime.now();
  if (endTime.isBefore(now)) return "Expired";
  final diff = endTime.difference(now);
  if (diff.inMinutes < 60) {
    return "in ${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'}";
  } else if (diff.inHours < 24) {
    return "in ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}";
  } else {
    return "in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}";
  }
}

String getTimeUntilString(DateTime startTime) {
  final now = DateTime.now();
  if (startTime.isBefore(now)) return "Started";
  final diff = startTime.difference(now);
  if (diff.inMinutes < 60) {
    return "in ${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'}";
  } else if (diff.inHours < 24) {
    return "in ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}";
  } else {
    return "in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}";
  }
}