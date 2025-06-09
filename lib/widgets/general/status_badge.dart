import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/enums/product_related/product_status_enum.dart';

class StatusBadge extends StatelessWidget {
  final dynamic status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color color;
    IconData icon;
    String text;

    // Always use localized text for ProductStatusEnum
    if (status is ProductStatusEnum) {
      text = (status as ProductStatusEnum).localized(context);
    } else {
      // Try to get localized text if the status object has getLocalizedName method
      try {
        if (status.getLocalizedName != null) {
          text = status.getLocalizedName(context);
        } else if (status is Enum) {
          text = status.toString().split('.').last;
        } else {
          text = status.toString();
        }
      } catch (e) {
        // Fallback to toString if getLocalizedName is not available
        if (status is Enum) {
          text = status.toString().split('.').last;
        } else {
          text = status.toString();
        }
      }
    }

    if (text.toLowerCase().contains('cancelled') ||
        text.toLowerCase().contains('unpaid') ||
        text.toLowerCase().contains('denied') ||
        text.toLowerCase().contains('inactive') ||
        text.toLowerCase().contains('discontinued') ||
        text.toLowerCase().contains('đã hủy') ||
        text.toLowerCase().contains('chưa thanh toán') ||
        text.toLowerCase().contains('từ chối') ||
        text.toLowerCase().contains('không hoạt động') ||
        text.toLowerCase().contains('ngừng kinh doanh') ||
        text.toLowerCase().contains('ngừng sản xuất')) {
      color = theme.colorScheme.error;
      icon = Icons.cancel;
    } else if (text.toLowerCase().contains('pending') ||
        text.toLowerCase().contains('preparing') ||
        text.toLowerCase().contains('shipping') ||
        text.toLowerCase().contains('processing') ||
        text.toLowerCase().contains('out of stock') ||
        text.toLowerCase().contains('đang chờ') ||
        text.toLowerCase().contains('đang chuẩn bị') ||
        text.toLowerCase().contains('đang vận chuyển') ||
        text.toLowerCase().contains('đang xử lý') ||
        text.toLowerCase().contains('hết hàng')) {
      color = theme.colorScheme.outline;
      icon = Icons.pending;
    } else if (text.toLowerCase().contains('completed') ||
        text.toLowerCase().contains('active') ||
        text.toLowerCase().contains('shipped') ||
        text.toLowerCase().contains('đã thanh toán') ||
        text.toLowerCase().contains('hoàn thành') ||
        text.toLowerCase().contains('đang hoạt động') ||
        text.toLowerCase().contains('đã giao hàng') ||
        text.toLowerCase().contains('còn hàng') ||
        text.toLowerCase().contains('đã sử dụng'))
         {
      color = theme.colorScheme.tertiary;
      icon = Icons.check_circle;
    } else {
      color = theme.colorScheme.outline;
      icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            // overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
