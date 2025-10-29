import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/functions/helper.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/widgets/general/status_badge.dart';

import '../../../../enums/invoice_related/payment_status.dart';
import '../../../../enums/invoice_related/sales_status.dart';
import '../../../../enums/product_related/category_enum.dart';
import '../permissions/sales_invoice_permissions.dart';
import 'sales_edit_cubit.dart';
import 'sales_edit_state.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';

class SalesEditWebView extends StatefulWidget {
  final SalesInvoice invoice;

  const SalesEditWebView({
    super.key,
    required this.invoice,
  });

  static Widget newInstance(SalesInvoice invoice) => BlocProvider(
        create: (context) => SalesEditCubit(invoice),
        child: SalesEditWebView(invoice: invoice),
      );

  @override
  State<SalesEditWebView> createState() => _SalesEditWebViewState();
}

class _SalesEditWebViewState extends State<SalesEditWebView> {
  late final SalesEditCubit cubit;
  bool _isClosing = false;
  late final bool _lockPaymentOnInit;
  late final bool _lockSalesOnInit;

  void _safeClose(dynamic result) {
    if (_isClosing || !mounted) return;
    _isClosing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop(result);
      }
    });
  }

  // no-op; success snackbar is shown by the caller (detail modal) before closing

  @override
  void initState() {
    super.initState();
    // Create a deep copy of the invoice to avoid modifying the original
    final invoiceCopy = SalesInvoice(
      salesInvoiceID: widget.invoice.salesInvoiceID,
      customerID: widget.invoice.customerID,
      customerName: widget.invoice.customerName,
      address: widget.invoice.address,
      date: widget.invoice.date,
      paymentStatus: widget.invoice.paymentStatus,
      salesStatus: widget.invoice.salesStatus,
      totalPrice: widget.invoice.totalPrice,
      loyaltyPoints: widget.invoice.loyaltyPoints,
      details: List.from(widget.invoice.details),
    );

    cubit = SalesEditCubit(invoiceCopy);

    // Lock snapshot based on initial invoice when opening modal
    _lockPaymentOnInit = widget.invoice.paymentStatus == PaymentStatus.paid;
    _lockSalesOnInit = widget.invoice.salesStatus == SalesStatus.completed ||
        widget.invoice.salesStatus == SalesStatus.cancelled;
  }

  @override
  void dispose() {
    cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => cubit,
      child: BlocBuilder<SalesEditCubit, SalesEditState>(
        builder: (context, state) {
          return Container(
            width: 900,
            height: 700,
            constraints: const BoxConstraints(
              maxWidth: 1000,
              maxHeight: 800,
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
                        child:
                            GradientText(text: S.of(context).editProductDetail),
                      ),
                      if (state.isLoading)
                        const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        GradientIconButton(
                          icon: Icons.check,
                          onPressed: () async {
                            final cubit = context.read<SalesEditCubit>();
                            final updatedInvoice = await cubit.saveChanges();
                            if (updatedInvoice != null && mounted) {
                              _safeClose(updatedInvoice);
                            }
                          },
                          fillColor: Colors.transparent,
                        ),
                      const SizedBox(width: 8),
                      GradientIconButton(
                        icon: Icons.close,
                        onPressed: () => _safeClose(null),
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
                          Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context)
                                    .dividerColor
                                    .withValues(alpha: 0.1),
                              ),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '#${state.invoice.salesInvoiceID}',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withValues(alpha: 0.1),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calendar_today_outlined,
                                            size: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            DateFormat('dd/MM/yyyy')
                                                .format(state.invoice.date),
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.person_outline,
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      S.of(context).customer,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  state.invoice.customerName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 20,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            S.of(context).address,
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                              fontSize: 14,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            state.invoice.address.toString(),
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (SalesInvoicePermissions
                                              .canEditAddress(state.userRole,
                                                  state.invoice))
                                            TextButton.icon(
                                              onPressed:
                                                  _showAddressBottomSheet,
                                              icon: const Icon(Icons.edit,
                                                  size: 16),
                                              label: Text(
                                                  S.of(context).changeAddress),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                minimumSize: const Size(0, 32),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Payment Status Section
                          Text(
                            S.of(context).paymentStatus,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          (_lockPaymentOnInit)
                              ? StatusBadge(
                                  status: state.invoice.paymentStatus,
                                )
                              : _buildStatusDropdown<PaymentStatus>(
                                  value: state.selectedPaymentStatus,
                                  items: PaymentStatus.values,
                                  onChanged: (status) {
                                    if (status != null) {
                                      context
                                          .read<SalesEditCubit>()
                                          .updatePaymentStatus(status);
                                    }
                                  },
                                ),

                          const SizedBox(height: 24),

                          // Sales Status Section
                          Text(
                            S.of(context).salesStatus,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          (_lockSalesOnInit)
                              ? StatusBadge(status: state.invoice.salesStatus)
                              : _buildStatusDropdown<SalesStatus>(
                                  value: state.selectedSalesStatus,
                                  items: SalesStatus.values,
                                  onChanged: (status) {
                                    if (status != null) {
                                      context
                                          .read<SalesEditCubit>()
                                          .updateSalesStatus(status);
                                    }
                                  },
                                ),

                          // Products List
                          const SizedBox(height: 16),
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
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(detail.category),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            detail.productName ??
                                                S.of(context).unknownProduct,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${S.of(context).quantity}: ${detail.quantity}',
                                            style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      Helper.toCurrencyFormat(detail.subtotal),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  S.of(context).totalAmount,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                Text(
                                  Helper.toCurrencyFormat(
                                      state.invoice.totalPrice),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null || category.trim().isEmpty) {
      return Icons.device_unknown;
    }

    // Quick path: if it's already an enum key or known alias, use extension
    try {
      final fromName = CategoryEnumExtension.fromName(category);
      return _iconForEnum(fromName);
    } catch (_) {}

    // Normalize: lowercase, remove enum prefix and non-alphanumerics
    String c = category.toLowerCase().trim();
    if (c.contains('categoryenum.')) {
      c = c.split('categoryenum.').last;
    }
    final norm = c.replaceAll(RegExp(r'[^a-z0-9]'), '');

    // 1) Try matching by localized/display name (normalized)
    try {
      final byDisplay = CategoryEnum.getValues().firstWhere((e) =>
          e.getName().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '') ==
          norm);
      return _iconForEnum(byDisplay);
    } catch (_) {}

    // 2) Try matching by enum key/name (normalized)
    try {
      final byKey = CategoryEnum.getValues()
          .firstWhere((e) => e.name.toLowerCase() == norm);
      return _iconForEnum(byKey);
    } catch (_) {}

    // 3) Heuristics for common aliases
    if (norm.contains('ram') || norm.contains('memory')) return Icons.memory;
    if (norm.contains('cpu') || norm.contains('processor'))
      return Icons.computer;
    if (norm.contains('psu') ||
        norm.contains('powersupply') ||
        norm.contains('power')) {
      return Icons.power;
    }
    if (norm.contains('gpu') ||
        norm.contains('vga') ||
        norm.contains('graphics') ||
        norm.contains('graphiccard')) {
      return Icons.videogame_asset;
    }
    if (norm.contains('ssd') ||
        norm.contains('hdd') ||
        norm.contains('drive') ||
        norm.contains('storage')) {
      return Icons.storage;
    }
    if (norm.contains('mainboard') ||
        norm.contains('motherboard') ||
        norm.contains('mb')) {
      return Icons.developer_board;
    }

    return Icons.device_unknown;
  }

  IconData _iconForEnum(CategoryEnum categoryEnum) {
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

  Widget _buildStatusDropdown<T extends Enum>({
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        dropdownColor: Theme.of(context).cardColor,
        underline: const SizedBox(),
        items: items.map((T item) {
          String displayText;
          if (item is PaymentStatus) {
            displayText = item.getLocalizedName(context);
          } else if (item is SalesStatus) {
            displayText = item.getLocalizedName(context);
          } else {
            displayText = item.toString().split('.').last;
          }
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              displayText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showAddressBottomSheet() async {
    try {
      final addresses =
          await Firebase().getCustomerAddresses(widget.invoice.customerID);
      final cubit = context.read<SalesEditCubit>();

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (bottomSheetContext) => BlocProvider.value(
          value: cubit,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(context).enterAddress,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (addresses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(S.of(context).noAddressFound),
                  )
                else
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            title: Text(
                              address.receiverName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              address.toString(),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.7),
                              ),
                            ),
                            trailing:
                                BlocBuilder<SalesEditCubit, SalesEditState>(
                              builder: (context, state) => state
                                          .invoice.address.addressID ==
                                      address.addressID
                                  ? Icon(
                                      Icons.check_circle,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            onTap: () {
                              cubit.updateAddress(address);
                              Navigator.pop(bottomSheetContext);
                            },
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => InformationDialog(
            title: S.of(context).errorOccurred,
            content: S.of(context).errorWithMessage(e.toString()),
            buttonText: 'OK',
          ),
        );
      }
    }
  }
}
