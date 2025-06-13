import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/enums/invoice_related/warranty_status.dart';
import 'package:gizmoglobe_client/screens/invoice/warranty/permissions/warranty_invoice_permissions.dart';
import 'package:gizmoglobe_client/screens/invoice/warranty/warranty_add/warranty_add_view.dart';
import 'package:gizmoglobe_client/screens/invoice/warranty/warranty_detail/warranty_detail_view.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';

import '../../../generated/l10n.dart';
import '../../../objects/invoice_related/warranty_invoice.dart';
import '../../../widgets/general/status_badge.dart';
import 'warranty_screen_cubit.dart';
import 'warranty_screen_state.dart';

class WarrantyScreen extends StatefulWidget {
  const WarrantyScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => WarrantyScreenCubit(),
        child: const WarrantyScreen(),
      );

  @override
  State<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _WarrantyScreenState extends State<WarrantyScreen> {
  final TextEditingController searchController = TextEditingController();
  final firebase = Firebase();
  WarrantyScreenCubit get cubit => context.read<WarrantyScreenCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WarrantyScreenCubit, WarrantyScreenState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () => cubit.setSelectedIndex(null),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FieldWithIcon(
                        controller: searchController,
                        hintText: S.of(context).findWarrantyInvoices,
                        fillColor: Theme.of(context).colorScheme.surface,
                        onChanged: (value) {
                          cubit.searchInvoices(value);
                        },
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.filter_list,
                      iconSize: 32,
                      onPressed: _showFilterDialog,
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.add,
                      iconSize: 32,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WarrantyAddView.newInstance(),
                          ),
                        );

                        if (result == true) {
                          if (kDebugMode) {
                            print('Warranty invoice created, refreshing list');
                          } // Hóa đơn bảo hành được tạo, làm mới danh sách
                          cubit.loadInvoices();
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
                                S.of(context).noWarrantyInvoicesFound,
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

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => _navigateToDetail(invoice),
                                  onLongPress: () {
                                    cubit.setSelectedIndex(index);
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          child: Container(
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
                                                  leading: const Icon(
                                                    Icons.visibility_outlined,
                                                    size: 20,
                                                    color: Colors.white,
                                                  ),
                                                  title:
                                                      Text(S.of(context).view),
                                                  onTap: () =>
                                                      _handleViewFromMenu(
                                                          context, invoice),
                                                ),
                                                if (WarrantyInvoicePermissions
                                                    .canEditStatus(
                                                        state.userRole,
                                                        invoice))
                                                  ListTile(
                                                    dense: true,
                                                    leading: const Icon(
                                                      Icons
                                                          .check_circle_outline,
                                                      size: 20,
                                                      color: Colors.white,
                                                    ),
                                                    title: Text(S
                                                        .of(context)
                                                        .markAsCompleted),
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                      cubit.setSelectedIndex(
                                                          null);
                                                      cubit
                                                          .updateWarrantyStatus(
                                                        invoice
                                                            .warrantyInvoiceID!,
                                                        WarrantyStatus
                                                            .completed,
                                                      );
                                                    },
                                                  ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ).whenComplete(() {
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
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: state.selectedIndex == index
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.1)
                                            : Theme.of(context)
                                                .colorScheme
                                                .surface,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: Theme.of(context)
                                                  .colorScheme
                                                  .primaryContainer,
                                              child: Icon(
                                                Icons.build_circle,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${S.of(context).invoiceDetails} #${invoice.warrantyInvoiceID}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    invoice.customerName ??
                                                        'Anonymous',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface
                                                          .withValues(
                                                              alpha: 0.6),
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 4,
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      StatusBadge(
                                                          status: invoice.status
                                                              .localized(
                                                                  context)),
                                                      Text(
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(invoice
                                                                .date), // dd/MM/yyyy
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .onSurface
                                                                  .withValues(
                                                                      alpha:
                                                                          0.6),
                                                        ),
                                                      ),
                                                    ],
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

  Future<void> _navigateToDetail(WarrantyInvoice invoice) async {
    BuildContext dialogContext = context;
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final detailedInvoice = await firebase
          .getWarrantyInvoiceWithDetails(invoice.warrantyInvoiceID!);

      if (!mounted) return;
      Navigator.of(dialogContext).pop();

      if (!mounted) return;
      await Navigator.push(
        dialogContext,
        MaterialPageRoute(
          builder: (context) => WarrantyDetailView(invoice: detailedInvoice),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(dialogContext).pop();

      if (!mounted) return;
      showDialog(
        context: dialogContext,
        builder: (context) => InformationDialog(
          title: S.of(context).errorOccurred,
          content:
              S.of(context).errorLoadingWarrantyInvoiceDetails(e.toString()),
          buttonText: 'OK',
        ),
      );
    }
  }

  Future<void> _handleViewFromMenu(
      BuildContext contextDialog, WarrantyInvoice invoice) async {
    Navigator.pop(contextDialog); // Close menu first
    cubit.setSelectedIndex(null);
    await _navigateToDetail(invoice);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context).sortBy,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text(
                      S.of(context).dateNewestFirst,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    leading: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    selected: cubit.state.sortField == SortField.date &&
                        cubit.state.sortOrder == SortOrder.descending,
                    selectedTileColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    onTap: () {
                      cubit.sortInvoices(SortField.date, SortOrder.descending);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(
                      S.of(context).dateOldestFirst,
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface),
                    ),
                    leading: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    selected: cubit.state.sortField == SortField.date &&
                        cubit.state.sortOrder == SortOrder.ascending,
                    selectedTileColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    onTap: () {
                      cubit.sortInvoices(SortField.date, SortOrder.ascending);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
