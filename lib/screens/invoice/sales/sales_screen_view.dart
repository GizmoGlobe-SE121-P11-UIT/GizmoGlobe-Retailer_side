import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_filter_argument.dart';
import 'package:gizmoglobe_client/screens/invoice/sales/sales_add/sales_add_view.dart';
import 'package:gizmoglobe_client/screens/invoice/sales/sales_detail/sales_detail_view.dart';
import 'package:gizmoglobe_client/screens/invoice/sales/filter/sales_filter_view.dart';
import 'package:gizmoglobe_client/screens/invoice/sales/filter/sales_filter_webview.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/status_badge.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/snackbar/snackbar_service.dart';

import '../../../data/firebase/firebase.dart';
import '../../../functions/helper.dart';
import '../../../objects/invoice_related/sales_invoice.dart';
import 'sales_screen_cubit.dart';
import 'sales_screen_state.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => SalesScreenCubit(),
        child: const SalesScreen(),
      );

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final TextEditingController searchController = TextEditingController();
  final firebase = Firebase();
  SalesScreenCubit get cubit => context.read<SalesScreenCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesScreenCubit, SalesScreenState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            if (state.selectedIndex != null) {
              cubit.setSelectedIndex(null);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FieldWithIcon(
                        controller: searchController,
                        hintText: S.of(context).searchSalesInvoices,
                        fillColor: Theme.of(context).colorScheme.surface,
                        onChanged: (value) {
                          cubit.searchInvoices(value);
                        },
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.filter_list,
                      iconSize: 32,
                      onPressed: () {
                        _showFilterDialog(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.sort,
                      iconSize: 32,
                      onPressed: () {
                        _showSortOptions(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.add,
                      iconSize: 32,
                      onPressed: () async {
                        final result = await SalesAddScreen.showModal(context);
                        if (result == true && mounted) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (!mounted) return;
                            SnackbarService.showSuccess(
                              context,
                              S.of(context).success,
                              S.of(context).createInvoiceSuccess,
                            );
                            context.read<SalesScreenCubit>().loadInvoices();
                          });
                        }
                      },
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : state.invoices.isEmpty
                          ? Center(
                              child: Text(
                                S.of(context).noSalesInvoicesFound,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.invoices.length,
                              itemBuilder: (context, index) {
                                final invoice = state.invoices[index];
                                // final isSelected = state.selectedIndex == index;

                                return InkWell(
                                  splashColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  overlayColor: const WidgetStatePropertyAll(
                                      Colors.transparent),
                                  onTap: () async {
                                    final result =
                                        await SalesDetailScreen.showModal(
                                            context, invoice);
                                    if (result == true && context.mounted) {
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        if (!context.mounted) return;
                                        SnackbarService.showSuccess(
                                          context,
                                          S.of(context).success,
                                          S.of(context).editInvoiceSuccess,
                                        );
                                      });
                                    }
                                  },
                                  onLongPress: () {
                                    if (!mounted) return;
                                    cubit.setSelectedIndex(index);
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          backgroundColor: Colors.transparent,
                                          contentPadding: EdgeInsets.zero,
                                          content: Container(
                                            width: 120,
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(context).cardColor,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                ListTile(
                                                  dense: true,
                                                  leading: Icon(
                                                    Icons.visibility_outlined,
                                                    size: 20,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                  title: Text(
                                                    S.of(context).view,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                  ),
                                                  onTap: () =>
                                                      _handleViewInvoice(
                                                          context, invoice),
                                                ),
                                                // if (SalesInvoicePermissions.canEditInvoice(state.userRole, invoice))
                                                //   ListTile(
                                                //     dense: true,
                                                //     leading: const Icon(
                                                //       Icons.edit_outlined,
                                                //       size: 20,
                                                //       color: Colors.white,
                                                //     ),
                                                //     title: const Text('Edit Invoice'),
                                                //     onTap: () => _handleEditInvoice(context, invoice),
                                                //   ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ).then((_) {
                                      cubit.setSelectedIndex(null);
                                    });
                                  },
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 200),
                                    opacity: state.selectedIndex == null ||
                                            state.selectedIndex == index
                                        ? 1.0
                                        : 0.3,
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: state.selectedIndex == index
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .outline
                                                  .withValues(alpha: 0.2),
                                          width: state.selectedIndex == index
                                              ? 2
                                              : 1,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Row 1: Invoice ID
                                            Text(
                                              '${S.of(context).invoiceDetails} #${invoice.salesInvoiceID}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 12),

                                            // Row 2: Price
                                            Text(
                                              Helper.toCurrencyFormat(
                                                  invoice.totalPrice),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .tertiary,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            // Row 3: Sales Status and Payment Status
                                            Row(
                                              children: [
                                                StatusBadge(
                                                    status:
                                                        invoice.salesStatus),
                                                const SizedBox(width: 8),
                                                StatusBadge(
                                                    status:
                                                        invoice.paymentStatus),
                                              ],
                                            ),
                                            const SizedBox(height: 12),

                                            // Row 4: Date
                                            Text(
                                              DateFormat('dd/MM/yyyy')
                                                  .format(invoice.date),
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Color _getStatusColor(String status) {
  //   switch (status.toLowerCase()) {
  //     case 'paid':
  //       return Colors.green;
  //     case 'unpaid':
  //       return Colors.red;
  //     case 'pending':
  //       return Colors.orange;
  //     default:
  //       return Colors.grey;
  //   }
  // }

  void _showSortOptions(BuildContext context) {
    final cubit = context.read<SalesScreenCubit>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => GestureDetector(
        onTap: () => Navigator.pop(dialogContext),
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: Theme.of(dialogContext).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.sort,
                          color: Theme.of(dialogContext).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          S.of(context).sortBy,
                          style: TextStyle(
                            color:
                                Theme.of(dialogContext).colorScheme.onSurface,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSortOption(
                          dialogContext,
                          S.of(context).dateNewestFirst,
                          Icons.calendar_today,
                          () {
                            cubit.sortInvoices('date', true);
                            Navigator.pop(dialogContext);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSortOption(
                          dialogContext,
                          S.of(context).dateOldestFirst,
                          Icons.calendar_today_outlined,
                          () {
                            cubit.sortInvoices('date', false);
                            Navigator.pop(dialogContext);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSortOption(
                          dialogContext,
                          S.of(context).priceHighestFirst,
                          Icons.attach_money,
                          () {
                            cubit.sortInvoices('price', true);
                            Navigator.pop(dialogContext);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSortOption(
                          dialogContext,
                          S.of(context).priceLowestFirst,
                          Icons.money_off,
                          () {
                            cubit.sortInvoices('price', false);
                            Navigator.pop(dialogContext);
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
      ),
    );
  }

  Widget _buildSortOption(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleViewInvoice(
      BuildContext contextDialog, SalesInvoice invoice) async {
    // Close menu dialog first
    Navigator.pop(contextDialog);
    cubit.setSelectedIndex(null);

    if (!mounted) return;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // Get invoice details
      final details =
          await firebase.getSalesInvoiceDetails(invoice.salesInvoiceID);
      invoice.details = details;

      if (!mounted) return;
      // Close loading dialog
      Navigator.pop(context);

      // Navigate to detail screen with full invoice (web uses dialog)
      await SalesDetailScreen.showModal(context, invoice);
    } catch (e) {
      if (!mounted) return;
      // Close loading dialog
      Navigator.pop(context);

      // Show error message
      showDialog(
        context: context,
        builder: (context) => InformationDialog(
          title: S.of(context).errorOccurred,
          content: S.of(context).errorLoadingInvoiceDetails(e.toString()),
          buttonText: 'OK',
        ),
      );
    }
  }

  // Future<void> _handleEditInvoice(BuildContext contextDialog, SalesInvoice invoice) async {
  //   // Close menu dialog first
  //   Navigator.pop(contextDialog);
  //   cubit.setSelectedIndex(null);
  //
  //   if (!mounted) return;
  //
  //   // Show loading dialog
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return const Center(
  //         child: CircularProgressIndicator(),
  //       );
  //     },
  //   );
  //
  //   try {
  //     // Get invoice details
  //     final details = await firebase.getSalesInvoiceDetails(invoice.salesInvoiceID);
  //     invoice.details = details;
  //
  //     if (!mounted) return;
  //     // Close loading dialog
  //     Navigator.pop(context);
  //
  //     // Navigate to edit screen with full invoice
  //     final result = await Navigator.push(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => SalesEditScreen(
  //           invoice: invoice,
  //         ),
  //       ),
  //     );
  //
  //     if (result != null && mounted) {
  //       context.read<SalesScreenCubit>().refreshInvoices();
  //     }
  //   } catch (e) {
  //     if (!mounted) return;
  //     // Close loading dialog
  //     Navigator.pop(context);
  //
  //     // Show error message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error loading invoice details: $e')), // Lỗi tải chi tiết hóa đơn
  //     );
  //   }
  // }

  Future<void> _showFilterDialog(BuildContext context) async {
    final SalesFilterArgument? result;

    if (kIsWeb) {
      result = await showDialog(
        context: context,
        builder: (context) => SalesFilterWebView.newInstance(
          arguments: cubit.state.filterArgument,
        ),
      );
    } else {
      result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalesFilterView.newInstance(
            arguments: cubit.state.filterArgument,
          ),
        ),
      );
    }

    if (result != null && mounted) {
      cubit.updateFilterArgument(result);
    }
  }
}
