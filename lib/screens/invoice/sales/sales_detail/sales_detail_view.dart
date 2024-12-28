import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:intl/intl.dart';
import 'sales_detail_cubit.dart';
import 'sales_detail_state.dart';
import '../sales_edit/sales_edit_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../../enums/product_related/category_enum.dart';

class SalesDetailScreen extends StatefulWidget {
  final SalesInvoice invoice;

  const SalesDetailScreen({
    super.key,
    required this.invoice,
  });

  @override
  State<SalesDetailScreen> createState() => _SalesDetailScreenState();
}

class _SalesDetailScreenState extends State<SalesDetailScreen> {
  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.device_unknown;
    
    // Convert string to CategoryEnum
    CategoryEnum? categoryEnum;
    try {
      categoryEnum = CategoryEnum.values.firstWhere(
        (e) => e.getName().toLowerCase() == category.toLowerCase()
      );
    } catch (e) {
      return Icons.device_unknown;
    }

    switch (categoryEnum) {
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

  Color _getStatusColor(dynamic status) {
    final statusStr = status.toString().toLowerCase();
    if (statusStr.contains('paid') || statusStr.contains('completed')) {
      return Colors.green;
    } else if (statusStr.contains('pending')) {
      return Colors.orange;
    } else if (statusStr.contains('cancelled') || statusStr.contains('failed')) {
      return Colors.red;
    }
    return Colors.grey;
  }

  Widget _buildTotalPriceRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ).createShader(bounds),
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesDetailCubit(widget.invoice),
      child: BlocBuilder<SalesDetailCubit, SalesDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: GradientIconButton(
                icon: Icons.chevron_left,
                onPressed: () {
                  Navigator.pop(context);
                },
                fillColor: Colors.transparent,
              ),
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 50,
                              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                              child: Icon(
                                Icons.receipt,
                                size: 50,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            child: Text(
                              'Invoice #${state.invoice.salesInvoiceID}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 32),
                          const Text(
                            'Invoice Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInfoRow('Customer', state.invoice.customerName ?? 'Unknown Customer'),
                          _buildInfoRow('Date', DateFormat('dd/MM/yyyy').format(state.invoice.date)),
                          _buildInfoRow(
                            'Address', 
                            state.invoice.address, 
                            wrap: true,
                            maxWidth: MediaQuery.of(context).size.width * 0.6,
                          ),
                          _buildInfoRow(
                            'Payment Status', 
                            state.invoice.paymentStatus.toString(),
                            valueColor: _getStatusColor(state.invoice.paymentStatus),
                          ),
                          _buildInfoRow(
                            'Sales Status', 
                            state.invoice.salesStatus.toString(),
                            valueColor: _getStatusColor(state.invoice.salesStatus),
                          ),
                          const SizedBox(height: 16),
                          _buildTotalPriceRow(
                            'Total Price',
                            '\$${state.invoice.totalPrice.toStringAsFixed(2)}',
                          ),
                          
                          const SizedBox(height: 32),
                          const Text(
                            'Products',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: state.invoice.details.length,
                            itemBuilder: (context, index) {
                              final detail = state.invoice.details[index];
                              return GestureDetector(
                                onTap: () {
                                  // TODO: Navigate to product detail screen
                                  print('Navigate to product ${detail.productID}');
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Product Image/Icon
                                            Container(
                                              width: 60,
                                              height: 60,
                                              decoration: BoxDecoration(
                                                color: Theme.of(context).colorScheme.primaryContainer,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                _getCategoryIcon(detail.category),
                                                size: 30,
                                                color: Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Product Details
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    detail.productName ?? 'Product #${detail.productID}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Unit Price: \$${detail.sellingPrice.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    'Subtotal: \$${detail.subtotal.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Quantity Badge
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).colorScheme.primary,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'x${detail.quantity}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  // child: Row(
                  //   children: [
                  //     Expanded(
                  //       child: ElevatedButton.icon(
                  //         onPressed: () async {
                  //           final updatedInvoice = await Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //               builder: (context) => SalesEditScreen(
                  //                 invoice: state.invoice,
                  //               ),
                  //             ),
                  //           );
                  //
                  //           if (updatedInvoice != null) {
                  //             final cubit = context.read<SalesDetailCubit>();
                  //             cubit.updateSalesInvoice(updatedInvoice);
                  //           }
                  //         },
                  //         icon: const Icon(
                  //           Icons.edit,
                  //           color: Colors.white,
                  //         ),
                  //         label: const Text(
                  //           'Edit',
                  //           style: TextStyle(color: Colors.white),
                  //         ),
                  //         style: ElevatedButton.styleFrom(
                  //           backgroundColor: Colors.green,
                  //           padding: const EdgeInsets.symmetric(vertical: 12),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, bool wrap = false, double? maxWidth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: wrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: maxWidth,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              textAlign: wrap ? TextAlign.left : TextAlign.right,
              softWrap: wrap,
            ),
          ),
        ],
      ),
    );
  }
}
