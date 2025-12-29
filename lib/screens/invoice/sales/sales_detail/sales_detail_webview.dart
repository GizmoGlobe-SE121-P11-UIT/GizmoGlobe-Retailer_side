import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/functions/helper.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/widgets/general/status_badge.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';
import '../permissions/sales_invoice_permissions.dart';
import '../sales_edit/sales_edit_view.dart';
import 'sales_detail_cubit.dart';
import 'sales_detail_state.dart';
import 'package:printing/printing.dart';
import 'package:gizmoglobe_client/services/invoices/sales/sales_detail_pdf_service.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';

class SalesDetailWebView extends StatefulWidget {
  final SalesInvoice invoice;

  const SalesDetailWebView({
    super.key,
    required this.invoice,
  });

  static Widget newInstance(SalesInvoice invoice) => BlocProvider(
        create: (context) => SalesDetailCubit(invoice),
        child: SalesDetailWebView(invoice: invoice),
      );

  @override
  State<SalesDetailWebView> createState() => _SalesDetailWebViewState();
}

class _SalesDetailWebViewState extends State<SalesDetailWebView> {
  bool _isClosing = false;
  bool _isDownloading = false;

  Future<void> _downloadPdf(BuildContext context, SalesInvoice invoice) async {
    setState(() {
      _isDownloading = true;
    });
    try {
      final productsMap =
          await context.read<SalesDetailCubit>().getProductsMapForInvoice();
      final pdfDoc = await SalesInvoicePdfService.generatePdf(
          invoice: invoice, products: productsMap);
      final fileName = 'Sales_Invoice_${invoice.salesInvoiceID}.pdf';
      await Printing.sharePdf(bytes: await pdfDoc.save(), filename: fileName);
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => InformationDialog(
            title: 'Error',
            content: 'Error downloading invoice PDF: $e',
            buttonText: 'OK',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  void _safeClose(dynamic result) {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(result);
      }
    });
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.device_unknown;

    // Convert string to CategoryEnum
    CategoryEnum? categoryEnum;
    try {
      categoryEnum = CategoryEnum.getValues().firstWhere(
          (e) => e.getName().toLowerCase() == category.toLowerCase());
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

  Widget _buildTotalPriceRow(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .primaryContainer
            .withValues(alpha: 0.3),
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
              color: Theme.of(context).colorScheme.primary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesDetailCubit, SalesDetailState>(
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
              // Header (match SalesAddWebView style)
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
                            '${S.of(context).invoiceDetails} #${state.invoice.salesInvoiceID}',
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (_isDownloading)
                      const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    if (!_isDownloading)
                      GradientIconButton(
                        icon: Icons.download,
                        onPressed: () => _downloadPdf(context, state.invoice),
                        fillColor: Colors.transparent,
                      ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.close,
                      onPressed: () => _safeClose(false),
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
                        _buildInfoRow(
                            S.of(context).customer, state.invoice.customerName),
                        _buildInfoRow(
                            S.of(context).date,
                            DateFormat('dd/MM/yyyy')
                                .format(state.invoice.date)),
                        _buildInfoRow(
                          S.of(context).address,
                          state.invoice.address.toString(),
                          wrap: true,
                        ),
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
                              StatusBadge(status: state.invoice.paymentStatus),
                            ],
                          ),
                        ),
                        // Sales Status Row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                S.of(context).salesStatus,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              StatusBadge(status: state.invoice.salesStatus),
                            ],
                          ),
                        ),
                        // Payment Method Row
                        _buildInfoRow(
                          S.of(context).paymentMethod,
                          state.invoice.paymentMethod.getLocalizedDescription(
                            Localizations.localeOf(context).languageCode ==
                                'vi',
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
                            return Container(
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
                                            _getCategoryIcon(detail.category),
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
                                                (detail.productName != null &&
                                                        detail.productName!
                                                            .isNotEmpty)
                                                    ? detail.productName!
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
                                                '${S.of(context).price}: ${Helper.toCurrencyFormat(detail.sellingPrice)}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.6),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${S.of(context).subtotal}: ${Helper.toCurrencyFormat(detail.subtotal)}',
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
                                        borderRadius: BorderRadius.circular(12),
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
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Footer with edit button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    if (SalesInvoicePermissions.canEditInvoice(state.invoice))
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final updatedInvoice =
                                await SalesEditScreen.showModal(
                                    context, state.invoice);

                            if (updatedInvoice != null) {
                              final cubit = context.read<SalesDetailCubit>();
                              cubit.updateSalesInvoice(updatedInvoice);
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) _safeClose(true);
                              });
                            }
                          },
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.white,
                          ),
                          label: Text(
                            S.of(context).editInvoice,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
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

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, bool wrap = false, double? maxWidth}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment:
            wrap ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                color: valueColor ?? Theme.of(context).colorScheme.onSurface,
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
