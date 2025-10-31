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
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:gizmoglobe_client/functions/helper.dart';

class IncomingDetailWebView extends StatefulWidget {
  final IncomingInvoice invoice;

  const IncomingDetailWebView({
    super.key,
    required this.invoice,
  });

  static Widget newInstance(IncomingInvoice invoice) => BlocProvider(
        create: (context) => IncomingDetailCubit(invoice),
        child: IncomingDetailWebView(invoice: invoice),
      );

  @override
  State<IncomingDetailWebView> createState() => _IncomingDetailWebViewState();
}

class _IncomingDetailWebViewState extends State<IncomingDetailWebView> {
  IncomingDetailCubit get cubit => context.read<IncomingDetailCubit>();

  Widget _buildTotalPriceRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
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
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontSize: 24,
              fontWeight: FontWeight.w700,
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
          showDialog(
            context: context,
            builder: (context) => InformationDialog(
              title: S.of(context).errorOccurred,
              content: state.errorMessage!,
              buttonText: 'OK',
              onPressed: () {
                cubit.clearError();
              },
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          width: 800,
          height: 600,
          constraints: const BoxConstraints(
            maxWidth: 900,
            maxHeight: 700,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header (same style as sales)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientText(
                        text:
                            '${S.of(context).invoiceDetails} #${state.invoice.incomingInvoiceID}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.download,
                      onPressed: () => cubit.printInvoice(),
                      fillColor: Colors.transparent,
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.close,
                      onPressed: () => Navigator.of(context).pop(false),
                      fillColor: Colors.transparent,
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                            child: Icon(
                              Icons.receipt,
                              size: 40,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          S.of(context).invoiceDetails,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow(S.of(context).manufacturerName,
                            state.manufacturer?.manufacturerName ?? 'Unknown'),
                        _buildInfoRow(
                            S.of(context).date,
                            DateFormat('dd/MM/yyyy')
                                .format(state.invoice.date)),
                        // Payment Status Row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).paymentStatus,
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
                        const SizedBox(height: 16),
                        _buildTotalPriceRow(
                          S.of(context).totalPrice,
                          Helper.toCurrencyFormat(state.invoice.totalPrice),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          S.of(context).products,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
                            return InkWell(
                              onTap: () async {
                                // Get product details and navigate
                                final product = await context
                                    .read<IncomingDetailCubit>()
                                    .getProduct(detail.productID);
                                if (product != null && context.mounted) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                        create: (context) =>
                                            ProductDetailCubit(product),
                                        child: ProductDetailScreen(
                                            product: product),
                                      ),
                                    ),
                                  );
                                }
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Product Image/Icon
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.inventory,
                                              size: 30,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Product Details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  (product?.productName !=
                                                              null &&
                                                          product!.productName
                                                              .isNotEmpty)
                                                      ? product.productName
                                                      : '${S.of(context).products} #${detail.productID}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${S.of(context).importPrice}: ${Helper.toCurrencyFormat(detail.importPrice)}',
                                                  style: TextStyle(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface
                                                        .withValues(alpha: 0.6),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '${S.of(context).subtotal}: ${Helper.toCurrencyFormat(detail.importPrice * detail.quantity)}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
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
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          'x${detail.quantity}',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
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
                        const SizedBox(height: 18),
                        if (IncomingInvoicePermissions.canEditPaymentStatus(
                            state.userRole, state.invoice))
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(S.of(context).paymentStatus),
                                      content: Text(
                                          S.of(context).markAsPaidQuestion),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: Text(
                                            S.of(context).cancel,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                            ),
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: () async {
                                            Navigator.pop(
                                                context); // close confirmation dialog
                                            try {
                                              await cubit.updatePaymentStatus(
                                                  PaymentStatus.paid);
                                              if (mounted) {
                                                Navigator.of(context).pop(
                                                    true); // close detail modal only on success
                                              }
                                            } catch (e) {
                                              if (mounted) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      InformationDialog(
                                                    title: S
                                                        .of(context)
                                                        .errorOccurred,
                                                    content: e.toString(),
                                                    buttonText: 'OK',
                                                  ),
                                                );
                                              }
                                            }
                                          },
                                          child: Text(
                                            S.of(context).confirm,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(
                                Icons.check_circle_outline,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                S.of(context).markAsPaidQuestion,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
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
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
