import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';
import 'package:gizmoglobe_client/widgets/general/status_badge.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/objects/voucher_related/end_time_interface.dart';

class VoucherCard extends StatelessWidget {
  final Voucher voucher;
  final VoidCallback onDelete;
  final bool isSelected;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.onDelete,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            Icon(
              Icons.card_giftcard,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    voucher.voucherName,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (voucher.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      voucher.description!,
                      style: AppTextStyle.smallText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(
              status: voucher.isEnabled
                  ? S.of(context).enabled
                  : S.of(context).disabled,
            ),
            IconButton(
              icon: Icon(
                voucher.isEnabled ? Icons.not_interested : Icons.check,
                color: voucher.isEnabled
                    ? colorScheme.error
                    : colorScheme.secondary,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
