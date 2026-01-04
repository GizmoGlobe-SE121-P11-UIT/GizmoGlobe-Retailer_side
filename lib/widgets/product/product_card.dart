import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';
import 'package:gizmoglobe_client/enums/product_related/product_status_enum.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/product_related/product_extensions.dart';

import '../../functions/helper.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const ProductCard({
    super.key,
    required this.product,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : product.displayStatus == ProductStatusEnum.discontinued
                    ? Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.05)
                    : Theme.of(context)
                        .colorScheme
                        .tertiary
                        .withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: product.displayStatus == ProductStatusEnum.discontinued
                  ? Theme.of(context).colorScheme.error.withValues(alpha: 0.5)
                  : Theme.of(context)
                      .colorScheme
                      .tertiary
                      .withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Column 1: Category Icon
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(product.category),
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Column 2: Product information organized in rows
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: Product name with status icon
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.productName,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Status icon
                          Icon(
                            product.displayStatus ==
                                    ProductStatusEnum.discontinued
                                ? Icons.cancel_outlined
                                : Icons.check_circle_outline,
                            color: product.displayStatus ==
                                    ProductStatusEnum.discontinued
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.tertiary,
                            size: 16,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Row 2: Product details - responsive layout
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isNarrow = constraints.maxWidth < 280;

                          if (isNarrow) {
                            // Stack into 2 rows for narrow screens
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // First row: Stock and Sales
                                Row(
                                  children: [
                                    _buildDetailItem(
                                      context,
                                      Icons.inventory_2_outlined,
                                      '${product.stock}',
                                      product.stock > 0
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                          : Theme.of(context).colorScheme.error,
                                    ),
                                    const SizedBox(width: 16),
                                    _buildDetailItem(
                                      context,
                                      Icons.trending_up,
                                      '${product.sales}',
                                      Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Second row: Prices
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPriceItem(
                                        context,
                                        Icons.file_download_outlined,
                                        Helper.toCurrencyFormat(
                                            product.importPrice),
                                        Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _buildPriceItem(
                                        context,
                                        Icons.file_upload_outlined,
                                        Helper.toCurrencyFormat(
                                            product.sellingPrice),
                                        Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }

                          // Original single row for wider screens
                          return Row(
                            children: [
                              // Stock information
                              Expanded(
                                flex: 2,
                                child: _buildDetailItem(
                                  context,
                                  Icons.inventory_2_outlined,
                                  '${product.stock}',
                                  product.stock > 0
                                      ? Theme.of(context).colorScheme.onSurface
                                      : Theme.of(context).colorScheme.error,
                                ),
                              ),
                              // Sales information
                              Expanded(
                                flex: 2,
                                child: _buildDetailItem(
                                  context,
                                  Icons.trending_up,
                                  '${product.sales}',
                                  Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              // Import price
                              Expanded(
                                flex: 3,
                                child: _buildPriceItem(
                                  context,
                                  Icons.file_download_outlined,
                                  Helper.toCurrencyFormat(product.importPrice),
                                  Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                ),
                              ),
                              // Selling price
                              Expanded(
                                flex: 3,
                                child: _buildPriceItem(
                                  context,
                                  Icons.file_upload_outlined,
                                  Helper.toCurrencyFormat(product.sellingPrice),
                                  Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(CategoryEnum category) {
    switch (category) {
      case CategoryEnum.ram:
        return Icons.memory;
      case CategoryEnum.cpu:
        return Icons.computer;
      case CategoryEnum.psu:
        return Icons.power;
      case CategoryEnum.gpu:
        return Icons.videogame_asset;
      case CategoryEnum.drive:
        return Icons.storage;
      case CategoryEnum.mainboard:
        return Icons.developer_board;
      default:
        return Icons.device_unknown;
    }
  }

  Widget _buildDetailItem(
      BuildContext context, IconData icon, String value, Color valueColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: valueColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceItem(
      BuildContext context, IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: color,
        ),
        const SizedBox(width: 2),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
