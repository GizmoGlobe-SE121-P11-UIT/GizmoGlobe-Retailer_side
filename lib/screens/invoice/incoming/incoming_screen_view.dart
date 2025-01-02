import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/screens/invoice/incoming/incoming_add/incoming_add_view.dart';
import 'package:gizmoglobe_client/screens/invoice/incoming/permissions/incoming_invoice_permissions.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:intl/intl.dart';
import '../../../enums/invoice_related/payment_status.dart';
import '../../../objects/invoice_related/incoming_invoice.dart';
import 'incoming_detail/incoming_detail_view.dart';
import 'incoming_screen_cubit.dart';
import 'incoming_screen_state.dart';
import '../../../widgets/general/status_badge.dart';

class IncomingScreen extends StatefulWidget {
  const IncomingScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => IncomingScreenCubit(),
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
    return BlocBuilder<IncomingScreenCubit, IncomingScreenState>(
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
                        hintText: 'Find incoming invoices...',
                        fillColor: Theme.of(context).colorScheme.surface,
                        onChanged: (value) {
                          cubit.searchInvoices(value);
                        },
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.filter_list,
                      iconSize: 32,
                      onPressed: _showFilterDialog,
                    ),
                    if (state.userRole == 'admin')
                      const SizedBox(width: 8),
                    if (state.userRole == 'admin')
                      GradientIconButton(
                        icon: Icons.add,
                        iconSize: 32,
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => IncomingAddScreen.newInstance(),
                            ),
                          );
                          
                          if (result != null && mounted) {
                            context.read<IncomingScreenCubit>().loadInvoices();
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
                                'No incoming invoices found',
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onBackground
                                      .withOpacity(0.6),
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: state.invoices.length,
                              itemBuilder: (context, index) {
                                final invoice = state.invoices[index];
                                final isSelected = state.selectedIndex == index;

                                return GestureDetector(
                                  onTap: () async {
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
                                      final detailedInvoice = await firebase.getIncomingInvoiceWithDetails(invoice.incomingInvoiceID!);
                                      
                                      if (!mounted) return;
                                      
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => IncomingDetailScreen.newInstance(detailedInvoice),
                                        ),
                                      );
                                    } catch (e) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error loading invoice details: $e')),
                                      );
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
                                              color: Theme.of(context).cardColor,
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
                                                  title: const Text('View'),
                                                  onTap: () => _handleViewInvoice(context, invoice),
                                                ),
                                                if (IncomingInvoicePermissions.canEditPaymentStatus(state.userRole, invoice))
                                                  ListTile(
                                                    dense: true,
                                                    leading: const Icon(
                                                      Icons.edit_outlined,
                                                      size: 20,
                                                      color: Colors.white,
                                                    ),
                                                    title: const Text('Edit Payment'),
                                                    onTap: () => _handleEditInvoice(context, invoice),
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
                                                .primaryColor
                                                .withOpacity(0.1)
                                            : Theme.of(context).cardColor,
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
                                                Icons.inventory,
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
                                                    'Invoice #${invoice.incomingInvoiceID}',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    invoice.manufacturerID,
                                                    style: TextStyle(
                                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 4,
                                                    crossAxisAlignment: WrapCrossAlignment.center,
                                                    children: [
                                                      StatusBadge(status: invoice.status),
                                                      Text(
                                                        DateFormat('dd/MM/yyyy').format(invoice.date),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              '\$${invoice.totalPrice.toStringAsFixed(2)}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
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

  Future<void> _handleViewInvoice(BuildContext contextDialog, IncomingInvoice invoice) async {
    // Đóng dialog menu trước
    Navigator.pop(contextDialog);
    cubit.setSelectedIndex(null);

    // Hiển thị loading trong context chính
    if (!mounted) return;
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
      final detailedInvoice = await firebase.getIncomingInvoiceWithDetails(invoice.incomingInvoiceID!);
      
      if (!mounted) return;
      // Đóng dialog loading
      Navigator.of(dialogContext).pop();
      
      if (!mounted) return;
      // Navigate to detail screen
      await Navigator.push(
        dialogContext,
        MaterialPageRoute(
          builder: (context) => IncomingDetailScreen.newInstance(detailedInvoice),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Đóng dialog loading
      Navigator.of(dialogContext).pop();
      
      if (!mounted) return;
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(content: Text('Error loading invoice details: $e')),
      );
    }
  }

  Future<void> _handleEditInvoice(BuildContext contextDialog, IncomingInvoice invoice) async {
    // Chỉ cho phép chỉnh sửa từ unpaid sang paid
    if (invoice.status != PaymentStatus.unpaid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only unpaid invoices can be marked as paid')),
      );
      Navigator.pop(contextDialog);
      return;
    }

    Navigator.pop(contextDialog);
    cubit.setSelectedIndex(null);

    // Hiển thị dialog xác nhận
    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: const Text('Mark this invoice as paid?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await cubit.quickUpdatePaymentStatus(invoice.incomingInvoiceID!, PaymentStatus.paid);
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
                      const Text(
                        'Sort By',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text(
                      'Date (Newest First)',
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    selected: cubit.state.sortField == SortField.date && 
                             cubit.state.sortOrder == SortOrder.descending,
                    selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    onTap: () {
                      cubit.sortInvoices(SortField.date, SortOrder.descending);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Date (Oldest First)',
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    selected: cubit.state.sortField == SortField.date && 
                             cubit.state.sortOrder == SortOrder.ascending,
                    selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    onTap: () {
                      cubit.sortInvoices(SortField.date, SortOrder.ascending);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Price (Highest First)',
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: Icon(
                      Icons.attach_money,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    selected: cubit.state.sortField == SortField.totalPrice && 
                             cubit.state.sortOrder == SortOrder.descending,
                    selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    onTap: () {
                      cubit.sortInvoices(SortField.totalPrice, SortOrder.descending);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text(
                      'Price (Lowest First)',
                      style: TextStyle(color: Colors.white),
                    ),
                    leading: Icon(
                      Icons.attach_money,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    selected: cubit.state.sortField == SortField.totalPrice && 
                             cubit.state.sortOrder == SortOrder.ascending,
                    selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    onTap: () {
                      cubit.sortInvoices(SortField.totalPrice, SortOrder.ascending);
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
