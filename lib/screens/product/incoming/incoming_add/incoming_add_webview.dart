import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/functions/helper.dart' show Helper;
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice_detail.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import '../../../../enums/invoice_related/payment_status.dart';
import '../../../../widgets/general/gradient_icon_button.dart';
import 'incoming_add_cubit.dart';
import 'incoming_add_state.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

class IncomingAddWebView extends StatefulWidget {
  const IncomingAddWebView({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => IncomingAddCubit(),
        child: const IncomingAddWebView(),
      );

  @override
  State<IncomingAddWebView> createState() => _IncomingAddWebViewState();
}

class _IncomingAddWebViewState extends State<IncomingAddWebView> {
  IncomingAddCubit get cubit => context.read<IncomingAddCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncomingAddCubit, IncomingAddState>(
      builder: (context, state) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 500;

        return Container(
          width:
              isMobile ? screenWidth : MediaQuery.of(context).size.width * 0.8,
          height: isMobile
              ? MediaQuery.of(context).size.height
              : MediaQuery.of(context).size.height * 0.9,
          constraints: BoxConstraints(
            maxWidth: isMobile ? double.infinity : 1200,
            maxHeight: isMobile ? double.infinity : 800,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius:
                isMobile ? BorderRadius.zero : BorderRadius.circular(16),
            boxShadow: isMobile
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Column(
            children: [
              // Header (match sales add)
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
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
                        text: S.of(context).newIncomingInvoice,
                      ),
                    ),
                    state.isSubmitting
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : GradientIconButton(
                            icon: Icons.check,
                            onPressed: () async {
                              final success = await cubit.submitInvoice();
                              if (success && mounted) {
                                Navigator.of(context).pop(true);
                              }
                            },
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
              // Main Content Sections
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Manufacturer
                        Card(
                          elevation: 2,
                          child: Padding(
                            padding: EdgeInsets.all(isMobile ? 12 : 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.business,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      size: isMobile ? 18 : 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        S.of(context).selectManufacturer,
                                        style: TextStyle(
                                          fontSize: isMobile ? 16 : 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<Manufacturer>(
                                  decoration: InputDecoration(
                                    labelText: S.of(context).selectManufacturer,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    labelStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.8),
                                    ),
                                  ),
                                  isExpanded: true,
                                  initialValue: state.selectedManufacturer,
                                  hint: Text(
                                    S.of(context).selectManufacturer,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                  items:
                                      state.manufacturers.map((manufacturer) {
                                    return DropdownMenuItem(
                                      value: manufacturer,
                                      child: Text(
                                        manufacturer.manufacturerName,
                                        style: const TextStyle(fontSize: 16),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (manufacturer) {
                                    if (manufacturer != null) {
                                      cubit.selectManufacturer(manufacturer);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Product select/add
                        if (state.selectedManufacturer != null) ...[
                          _buildProductsSection(state),
                          const SizedBox(height: 24),
                          _buildDetailsSection(state),
                          const SizedBox(height: 24),
                          // Summary
                          Builder(
                            builder: (context) {
                              final isMobileContext =
                                  MediaQuery.of(context).size.width < 500;
                              return Card(
                                elevation: 2,
                                child: Padding(
                                  padding:
                                      EdgeInsets.all(isMobileContext ? 12 : 20),
                                  child: isMobileContext
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.calculate,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    S.of(context).totalPrice,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              Helper.toCurrencyFormat(
                                                  state.totalPrice),
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Theme.of(context).colorScheme.tertiary,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.calculate,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      S.of(context).totalPrice,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                Helper.toCurrencyFormat(
                                                    state.totalPrice),
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).colorScheme.tertiary,
                                                ),
                                                maxLines: 2,
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          // Payment status
                          Card(
                            elevation: 2,
                            child: Padding(
                              padding: EdgeInsets.all(isMobile ? 12 : 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.payment,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        size: isMobile ? 18 : 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          S.of(context).paymentStatus,
                                          style: TextStyle(
                                            fontSize: isMobile ? 16 : 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<PaymentStatus>(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      labelStyle: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.8),
                                      ),
                                    ),
                                    initialValue: state.paymentStatus,
                                    items: PaymentStatus.values.map((status) {
                                      return DropdownMenuItem(
                                        value: status,
                                        child: Text(
                                          status.getLocalizedName(context),
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (status) {
                                      if (status != null) {
                                        cubit.updatePaymentStatus(status);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]
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

  Widget _buildProductsSection(IncomingAddState state) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            color: Theme.of(context).colorScheme.primary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              S.of(context).products,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showAddProductDialog(context),
                          icon: Icon(
                            Icons.add,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                          label: Text(S.of(context).addProduct),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            color: Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            S.of(context).products,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showAddProductDialog(context),
                        icon: Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(S.of(context).addProduct),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 16),
            if (state.products.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).noProductsAvailableForManufacturer,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (isMobile)
              const SizedBox.shrink()
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 2 : 3,
                  childAspectRatio: isMobile ? 1.3 : 1.6,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: state.products.length,
                itemBuilder: (context, index) {
                  final product = state.products[index];
                  return InkWell(
                      onTap: () => _showAddProductDialog(context,
                          selectedProduct: product),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(isMobile ? 10 : 12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    product.productName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: isMobile ? 13 : 14,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(height: isMobile ? 6 : 8),
                              Text(
                                Helper.toCurrencyFormat(product.importPrice),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 12 : 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ));
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(IncomingAddState state) {
    final isMobile = MediaQuery.of(context).size.width < 500;

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).receiptDetails,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (state.details.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.3),
                    style: BorderStyle.solid,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        S.of(context).noProductsAddedYet,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.details.length,
                itemBuilder: (context, index) {
                  final detail = state.details[index];
                  final product = state.products.firstWhere(
                    (p) => p.productID == detail.productID,
                  );
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context)
                            .colorScheme
                            .outline
                            .withValues(alpha: 0.2),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  product.productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isMobile ? 15 : 16,
                                  ),
                                  maxLines: isMobile ? 3 : null,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  size: isMobile ? 20 : 24,
                                ),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () => _showEditDetailDialog(
                                  context,
                                  index,
                                  product,
                                  detail,
                                ),
                                constraints: BoxConstraints(
                                  minWidth: isMobile ? 36 : 40,
                                  minHeight: isMobile ? 36 : 40,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  size: isMobile ? 20 : 24,
                                ),
                                color: Theme.of(context).colorScheme.error,
                                onPressed: () => cubit.removeDetail(index),
                                constraints: BoxConstraints(
                                  minWidth: isMobile ? 36 : 40,
                                  minHeight: isMobile ? 36 : 40,
                                ),
                                padding: EdgeInsets.zero,
                              ),
                            ],
                          ),
                          SizedBox(height: isMobile ? 10 : 12),
                          isMobile
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${S.of(context).importPrice}: ',
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            Helper.toCurrencyFormat(
                                                detail.importPrice),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.9),
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: isMobile ? 10 : 12),
                                    isMobile
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer
                                                      .withValues(alpha: 0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                        color: detail.quantity >
                                                                1
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.3),
                                                        size: 20,
                                                      ),
                                                      onPressed: detail
                                                                  .quantity >
                                                              1
                                                          ? () => cubit
                                                              .updateDetailQuantity(
                                                                  index,
                                                                  detail.quantity -
                                                                      1)
                                                          : null,
                                                      constraints:
                                                          const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 48,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      child: Text(
                                                        '${detail.quantity}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        color: Colors.blue,
                                                        size: 20,
                                                      ),
                                                      onPressed: () => cubit
                                                          .updateDetailQuantity(
                                                        index,
                                                        detail.quantity + 1,
                                                      ),
                                                      constraints:
                                                          const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    S.of(context).subtotal,
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                              alpha: 0.6),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    Helper.toCurrencyFormat(
                                                        detail.subtotal),
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                      color: Colors.green,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          )
                                        : Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primaryContainer
                                                      .withValues(alpha: 0.3),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .remove_circle_outline,
                                                        color: detail.quantity >
                                                                1
                                                            ? Theme.of(context)
                                                                .colorScheme
                                                                .primary
                                                            : Theme.of(context)
                                                                .colorScheme
                                                                .onSurface
                                                                .withValues(
                                                                    alpha: 0.3),
                                                        size: 20,
                                                      ),
                                                      onPressed: detail
                                                                  .quantity >
                                                              1
                                                          ? () => cubit
                                                              .updateDetailQuantity(
                                                                  index,
                                                                  detail.quantity -
                                                                      1)
                                                          : null,
                                                      constraints:
                                                          const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 48,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8),
                                                      child: Text(
                                                        '${detail.quantity}',
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 16,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons
                                                            .add_circle_outline,
                                                        color: Colors.blue,
                                                        size: 20,
                                                      ),
                                                      onPressed: () => cubit
                                                          .updateDetailQuantity(
                                                        index,
                                                        detail.quantity + 1,
                                                      ),
                                                      constraints:
                                                          const BoxConstraints(
                                                        minWidth: 32,
                                                        minHeight: 32,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const Spacer(),
                                              Flexible(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      S.of(context).subtotal,
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                                alpha: 0.6),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 2),
                                                    Text(
                                                      Helper.toCurrencyFormat(
                                                          detail.subtotal),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.green,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      textAlign:
                                                          TextAlign.right,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${S.of(context).importPrice}: ${Helper.toCurrencyFormat(detail.importPrice)}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.8),
                                          fontSize: 14,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.remove_circle_outline,
                                              color: detail.quantity > 1
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.3),
                                              size: 20,
                                            ),
                                            onPressed: detail.quantity > 1
                                                ? () =>
                                                    cubit.updateDetailQuantity(
                                                        index,
                                                        detail.quantity - 1)
                                                : null,
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                          ),
                                          Container(
                                            width: 48,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8),
                                            child: Text(
                                              '${detail.quantity}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.add_circle_outline,
                                              color: Colors.blue,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                cubit.updateDetailQuantity(
                                              index,
                                              detail.quantity + 1,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 32,
                                              minHeight: 32,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          S.of(context).subtotal,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.6),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          Helper.toCurrencyFormat(
                                              detail.subtotal),
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.green,
                                          ),
                                          maxLines: 2,
                                          textAlign: TextAlign.right,
                                        ),
                                      ],
                                    ),
                                  ],
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
    );
  }

  Future<void> _showAddProductDialog(BuildContext context,
      {Product? selectedProduct}) async {
    Product? product = selectedProduct;
    final quantityController = TextEditingController(text: '1');
    final importPriceController = TextEditingController(
      text: selectedProduct?.importPrice.toString() ?? '',
    );

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      floatingLabelStyle:
          TextStyle(color: Theme.of(context).colorScheme.primary),
      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      fillColor: Theme.of(context).colorScheme.surface,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: GradientText(text: S.of(context).addProduct),
            content: BlocBuilder<IncomingAddCubit, IncomingAddState>(
              builder: (context, state) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Product>(
                        initialValue: product,
                        decoration: inputDecoration.copyWith(
                            labelText: S.of(context).selectProduct),
                        dropdownColor: Theme.of(context).cardColor,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                        items: state.products.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Text(
                              p.productName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        isExpanded: true,
                        onChanged: (p) {
                          setState(() {
                            product = p;
                            if (p != null) {
                              importPriceController.text =
                                  p.importPrice.toString();
                            }
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: importPriceController,
                        decoration: inputDecoration.copyWith(
                            labelText: S.of(context).importPrice,
                            suffixText: '.000 VND',
                            suffixStyle: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.6),
                            )),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: quantityController,
                        decoration: inputDecoration.copyWith(
                            labelText: S.of(context).quantity),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
              TextButton(
                onPressed: () {
                  if (product != null) {
                    final importPrice =
                        double.tryParse(importPriceController.text);
                    final quantity = int.tryParse(quantityController.text);

                    if (importPrice != null &&
                        quantity != null &&
                        quantity > 0) {
                      cubit.addDetail(product!, importPrice, quantity);
                      Navigator.pop(dialogContext);
                    }
                  }
                },
                child: Text(
                  S.of(context).add,
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showEditDetailDialog(
    BuildContext context,
    int index,
    Product currentProduct,
    IncomingInvoiceDetail detail,
  ) async {
    Product? selectedProduct = currentProduct;
    final quantityController =
        TextEditingController(text: detail.quantity.toString());
    final importPriceController =
        TextEditingController(text: detail.importPrice.toString());

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
            color:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
      ),
      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
      floatingLabelStyle:
          TextStyle(color: Theme.of(context).colorScheme.primary),
      hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
      fillColor: Theme.of(context).cardColor,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );

    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: Text(S.of(context).editProductDetail),
          content: BlocBuilder<IncomingAddCubit, IncomingAddState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Product>(
                      initialValue: selectedProduct,
                      decoration: inputDecoration.copyWith(
                          labelText: S.of(context).selectProduct),
                      dropdownColor: Theme.of(context).cardColor,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      items: state.products.map((product) {
                        return DropdownMenuItem(
                          value: product,
                          child: Text(
                            product.productName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      isExpanded: true,
                      onChanged: (product) {
                        selectedProduct = product;
                        if (product != null) {
                          importPriceController.text =
                              product.importPrice.toString();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: importPriceController,
                      decoration: inputDecoration.copyWith(
                          labelText: S.of(context).importPrice,
                          suffixText: '.000 VND',
                          suffixStyle: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          )),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      decoration: inputDecoration.copyWith(
                          labelText: S.of(context).quantity),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
            TextButton(
              onPressed: () {
                if (selectedProduct != null) {
                  final importPrice =
                      double.tryParse(importPriceController.text);
                  final quantity = int.tryParse(quantityController.text);

                  if (importPrice != null && quantity != null) {
                    cubit.removeDetail(index);
                    cubit.addDetail(selectedProduct!, importPrice, quantity);
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: Text(
                S.of(context).update,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
