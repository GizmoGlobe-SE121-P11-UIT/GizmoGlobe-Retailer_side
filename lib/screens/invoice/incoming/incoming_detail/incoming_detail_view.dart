import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice.dart';
import 'package:intl/intl.dart';
import '../../../../widgets/general/gradient_icon_button.dart';
import 'incoming_detail_cubit.dart';
import 'incoming_detail_state.dart';
import 'package:gizmoglobe_client/widgets/general/status_badge.dart';
import '../permissions/incoming_invoice_permissions.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_view.dart';

class IncomingDetailScreen extends StatefulWidget {
  final IncomingInvoice invoice;

  const IncomingDetailScreen({
    super.key,
    required this.invoice,
  });

  static Widget newInstance(IncomingInvoice invoice) => BlocProvider(
        create: (context) => IncomingDetailCubit(invoice),
        child: IncomingDetailScreen(invoice: invoice),
      );

  @override
  State<IncomingDetailScreen> createState() => _IncomingDetailScreenState();
}

class _IncomingDetailScreenState extends State<IncomingDetailScreen> {
  IncomingDetailCubit get cubit => context.read<IncomingDetailCubit>();

  Widget _buildTotalPriceRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
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
    return BlocConsumer<IncomingDetailCubit, IncomingDetailState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          cubit.clearError();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GradientIconButton(
              icon: Icons.chevron_left,
              onPressed: () => Navigator.pop(context),
              fillColor: Colors.transparent,
            ),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
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
                                    Icons.inventory,
                                    size: 50,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Invoice #${state.invoice.incomingInvoiceID}', // Hóa đơn #${state.invoice.incomingInvoiceID}
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
                              _buildInfoRow('Manufacturer', state.manufacturer?.manufacturerName ?? 'Unknown'), // Nhà sản xuất
                              _buildInfoRow('Date', DateFormat('dd/MM/yyyy').format(state.invoice.date)), // Ngày
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Payment Status', // Trạng thái thanh toán
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    StatusBadge(status: state.invoice.status),
                                  ],
                                ),
                              ),
                              _buildTotalPriceRow(
                                'Total Price', // Tổng giá
                                '\$${state.invoice.totalPrice.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 32),
                              const Text(
                                'Products', // Sản phẩm
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
                                  final product = state.products[detail.productID];

                                  return Card(
                                    child: ListTile(
                                      onTap: () async {
                                        final product = await context.read<IncomingDetailCubit>().getProduct(detail.productID);
                                        if (product != null && context.mounted) {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => BlocProvider(
                                                create: (context) => ProductDetailCubit(product),
                                                child: ProductDetailScreen(
                                                  product: product,
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      },
                                      title: Text(
                                        product?.productName ?? 'Product #${detail.productID}', // Sản phẩm #${detail.productID}
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Import Price: \$${detail.importPrice.toStringAsFixed(2)}', // Giá nhập: \$${detail.importPrice.toStringAsFixed(2)}
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                      trailing: Text(
                                        'Quantity: ${detail.quantity}', // Số lượng: ${detail.quantity}
                                        style: TextStyle(
                                          color: Theme
                                              .of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                        ),
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
                    if (IncomingInvoicePermissions.canEditPaymentStatus(state.userRole, state.invoice))
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Confirm Payment'), // Xác nhận thanh toán
                                        content: const Text('Mark this invoice as paid?'), // Đánh dấu hóa đơn này đã thanh toán?
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'), // Hủy
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);
                                              await cubit.updatePaymentStatus(
                                                  PaymentStatus.paid);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Confirm'), // Xác nhận
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                                label: const Text('Mark as Paid', style: TextStyle(color: Colors.white)), // Đánh dấu đã thanh toán
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
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
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}