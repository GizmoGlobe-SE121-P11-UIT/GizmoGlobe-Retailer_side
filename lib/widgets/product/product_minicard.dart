import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../functions/helper.dart';
import '../../objects/product_related/product.dart';
import '../../screens/product/product_detail/product_detail_view.dart';
import '../../screens/product/product_detail/product_detail_webview.dart';
import '../../utils/app_navigator.dart';
import '../../data/database/database.dart';
import '../../screens/invoice/sales/rating_reply/rating_reply_cubit.dart';


class ProductMiniCard extends StatelessWidget {
  final Product product;

  const ProductMiniCard({super.key, required this.product});

  String get _name => product.productName;

  String get _category => product.category.toString().split('.').last.toLowerCase();

  Future<void> _openProductDetail(BuildContext context) async {
    final p = product;
    if (p.productID == null || p.productID!.isEmpty) {
      // fallback to named navigation if product id missing
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Product info loading")),
        );
      }
      return;
    }

    final route = MaterialPageRoute(
      builder: (_) => kIsWeb ? ProductDetailWebView.newInstance(p) : ProductDetailScreen.newInstance(p),
    );

    // Await the navigation result and then refresh ratings if needed
    dynamic result;
    try {
      result = await AppNavigator.push(route);
      if (result == null && context.mounted) {
        result = await Navigator.of(context).push(route);
      }
    } catch (e) {
      if (context.mounted) {
        result = await Navigator.of(context).push(route);
      }
    }

    if (kDebugMode) print('ProductMiniCard: returned from detail for ${p.productID} with result=$result');

    // Refresh central rating cache and try to notify RatingReplyCubit if present in the widget tree
    try {
      await Database().getRating();
    } catch (e) {
      if (kDebugMode) print('ProductMiniCard: error refreshing Database ratings: $e');
    }

    try {
      final cubit = context.read<RatingReplyCubit>();
      await cubit.fetchRatings();
    } catch (_) {
      // ignore if RatingReplyCubit not available in this context
    }
  }

  IconData _getCategoryIcon() {
    switch (_category) {
      case 'ram':
        return Icons.memory;
      case 'cpu':
        return Icons.developer_board;
      case 'gpu':
        return Icons.videocam;
      case 'psu':
        return Icons.power;
      case 'drive':
        return Icons.storage;
      case 'mainboard':
        return Icons.dashboard;
      default:
        return Icons.devices;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Compute discounted price (product.sellingPrice is an int)
    final double sp = product.sellingPrice.toDouble();
    final double disc = product.discount;
    final double discountedPrice = sp * (100 - disc) / 100.0;

    // Compact layout: smaller icon/photo area, 2-row display (name + price)
    return InkWell(
      onTap: () => _openProductDetail(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.outlineVariant.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: colorScheme.surfaceContainerHighest,
              ),
              child: Icon(
                _getCategoryIcon(),
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name (smaller font, allow up to 2 lines)
                  Text(
                    _name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Single price row (only discounted price)
                  Text(
                    Helper.toCurrencyFormat(discountedPrice),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
