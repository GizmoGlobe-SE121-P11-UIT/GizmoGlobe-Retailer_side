import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/screens/product/incoming/permissions/incoming_invoice_permissions.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/snackbar/snackbar_service.dart';

import '../../../enums/invoice_related/payment_status.dart';
import '../../../functions/helper.dart';
import '../../../objects/invoice_related/incoming_invoice.dart';
import '../../../widgets/general/status_badge.dart';
import 'incoming_add/incoming_add_view.dart';
import 'incoming_detail/incoming_detail_view.dart';
import 'incoming_screen_cubit.dart';
import 'incoming_screen_state.dart';

class IncomingScreen extends StatefulWidget {
  const IncomingScreen({super.key});

  static Widget newInstance() => BlocProvider(
    create: (context) => IncomingScreenCubit()..loadInvoices(),
    child: const IncomingScreen(),
  );

  @override
  State<IncomingScreen> createState() => _IncomingScreenState();
}

class _IncomingScreenState extends State<IncomingScreen> {
  final TextEditingController searchController = TextEditingController();
  final firebase = Firebase();
  IncomingScreenCubit get cubit => context.read<IncomingScreenCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          S.of(context).incoming,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      body: BlocBuilder<IncomingScreenCubit, IncomingScreenState>(
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
                          hintText: S.of(context).searchIncomingInvoices,
                          fillColor: Theme.of(context).colorScheme.surface,
                          onChanged: (value) {
                            cubit.searchInvoices(value);
                          },
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GradientIconButton(
                        icon: Icons.filter_list,
                        iconSize: 32,
                        onPressed: _showFilterDialog,
                      ),
                      if (IncomingInvoicePermissions.canAddInvoice())
                        const SizedBox(width: 8),
                      if (IncomingInvoicePermissions.canAddInvoice())
                        GradientIconButton(
                          icon: Icons.add,
                          iconSize: 32,
                          onPressed: () async {
                            final successText = S.of(context).success;
                            final invoiceAddedText =
                                S.of(context).createIncomingInvoiceSuccess;
                            final result =
                            await IncomingAddScreen.showModal(context);
                            if (result == true && mounted && kIsWeb) {
                              Future.microtask(() {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (mounted) {
                                    SnackbarService.showSuccess(
                                      context,
                                      successText,
                                      invoiceAddedText,
                                    );
                                  }
                                });
                              });
                            }
                            if (result == true && mounted) {
                              context
                                  .read<IncomingScreenCubit>()
                                  .loadInvoices();
                            }
                          },
                        )
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: state.isLoading
                        ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                        : state.invoices.isEmpty
                        ? Center(
                      child: Text(
                        S.of(context).noIncomingInvoicesFound,
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
                        return GestureDetector(
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (BuildContext context) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                );
                              },
                            );

                            try {
                              final detailedInvoice = await firebase
                                  .getIncomingInvoiceWithDetails(
                                  invoice.incomingInvoiceID!);

                              if (!mounted) return;

                              Navigator.pop(context);
                              final successText =
                                  S.of(context).success;
                              final invoicePaidText = S
                                  .of(context)
                                  .updateIncomingInvoiceSuccess;
                              final detailResult =
                              await IncomingDetailScreen
                                  .showModal(
                                context,
                                detailedInvoice,
                              );
                              if (detailResult == true &&
                                  mounted &&
                                  kIsWeb) {
                                Future.microtask(() {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    if (mounted) {
                                      SnackbarService.showSuccess(
                                        context,
                                        successText,
                                        invoicePaidText,
                                      );
                                    }
                                  });
                                });
                              }
                              if (detailResult == true && mounted) {
                                context
                                    .read<IncomingScreenCubit>()
                                    .loadInvoices();
                              }
                            } catch (e) {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    InformationDialog(
                                      title: S.of(context).errorOccurred,
                                      content:
                                      '${S.of(context).errorLoadingInvoiceDetails('')}$e',
                                      buttonText: 'OK',
                                    ),
                              );
                            }
                          },
                          onLongPress: kIsWeb
                              ? null
                              : () {
                            if (!mounted) return;
                            cubit.setSelectedIndex(index);
                            showDialog(
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor:
                                  Colors.transparent,
                                  contentPadding:
                                  EdgeInsets.zero,
                                  content: Container(
                                    width: 120,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface,
                                      borderRadius:
                                      BorderRadius.circular(
                                          8),
                                    ),
                                    child: Column(
                                      mainAxisSize:
                                      MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          dense: true,
                                          leading: Icon(
                                            Icons
                                                .visibility_outlined,
                                            size: 20,
                                            color: Theme.of(
                                                context)
                                                .colorScheme
                                                .onSurface,
                                          ),
                                          title: Text(
                                            S.of(context).view,
                                            style: TextStyle(
                                              color: Theme.of(
                                                  context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                          ),
                                          onTap: () =>
                                              _handleViewInvoice(
                                                  context,
                                                  invoice),
                                        ),
                                        if (IncomingInvoicePermissions
                                            .canEditPaymentStatus(
                                            invoice))
                                          ListTile(
                                            dense: true,
                                            leading: Icon(
                                              Icons
                                                  .edit_outlined,
                                              size: 20,
                                              color: Theme.of(
                                                  context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            title: Text(
                                              S
                                                  .of(context)
                                                  .editPayment,
                                              style: TextStyle(
                                                color: Theme.of(
                                                    context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                            onTap: () =>
                                                _handleEditInvoice(
                                                    context,
                                                    invoice),
                                          ),
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
                            duration:
                            const Duration(milliseconds: 200),
                            opacity: state.selectedIndex == null ||
                                state.selectedIndex == index
                                ? 1.0
                                : 0.3,
                            child: Container(
                              margin:
                              const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surface,
                                borderRadius:
                                BorderRadius.circular(12),
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
                                      '${S.of(context).receiptDetails} #${invoice.incomingInvoiceID}',
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
                                            .error,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Row 3: Status and Date
                                    Row(
                                      children: [
                                        StatusBadge(
                                            status: invoice.status),
                                        const SizedBox(width: 8),
                                        Text(
                                          DateFormat('dd/MM/yyyy')
                                              .format(invoice.date),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(
                                                alpha: 0.6),
                                          ),
                                        ),
                                      ],

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
      ),
    );
  }

  Future<void> _handleViewInvoice(
      BuildContext contextDialog, IncomingInvoice invoice) async {
    Navigator.pop(contextDialog);
    cubit.setSelectedIndex(null);

    if (!mounted) return;
    BuildContext dialogContext = context;
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );

    try {
      final detailedInvoice = await firebase
          .getIncomingInvoiceWithDetails(invoice.incomingInvoiceID!);

      if (!mounted) return;
      Navigator.of(dialogContext).pop();

      if (!mounted) return;
      await IncomingDetailScreen.showModal(
        dialogContext,
        detailedInvoice,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(dialogContext).pop();

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => InformationDialog(
          title: S.of(context).errorOccurred,
          content: '${S.of(context).errorLoadingInvoiceDetails('')}$e',
          buttonText: 'OK',
        ),
      );
    }
  }

  Future<void> _handleEditInvoice(
      BuildContext contextDialog, IncomingInvoice invoice) async {
    if (invoice.status != PaymentStatus.unpaid) {
      showDialog(
        context: context,
        builder: (context) => InformationDialog(
          title: S.of(context).errorOccurred,
          content: S.of(context).onlyUnpaidCanBeMarkedPaid,
          buttonText: 'OK',
        ),
      );
      Navigator.pop(contextDialog);
      return;
    }

    Navigator.pop(contextDialog);
    cubit.setSelectedIndex(null);

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            S.of(context).paymentStatus,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: Text(
            S.of(context).markAsPaidQuestion,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                S.of(context).confirm,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await cubit.quickUpdatePaymentStatus(
          invoice.incomingInvoiceID!, PaymentStatus.paid);
    }
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
                  ListTile(
                    title: Text(
                      S.of(context).priceHighestFirst,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    leading: Icon(
                      Icons.attach_money,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    selected: cubit.state.sortField == SortField.totalPrice &&
                        cubit.state.sortOrder == SortOrder.descending,
                    selectedTileColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    onTap: () {
                      cubit.sortInvoices(
                          SortField.totalPrice, SortOrder.descending);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: Text(
                      S.of(context).priceLowestFirst,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    leading: Icon(
                      Icons.attach_money,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    selected: cubit.state.sortField == SortField.totalPrice &&
                        cubit.state.sortOrder == SortOrder.ascending,
                    selectedTileColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    onTap: () {
                      cubit.sortInvoices(
                          SortField.totalPrice, SortOrder.ascending);
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
