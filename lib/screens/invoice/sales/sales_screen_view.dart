import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/invoice/sales/sales_add/sales_add_view.dart';
import 'package:gizmoglobe_client/screens/invoice/sales/sales_detail/sales_detail_view.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:intl/intl.dart';
import '../../../data/firebase/firebase.dart';
import '../../../objects/invoice_related/sales_invoice.dart';
import 'sales_screen_cubit.dart';
import 'sales_screen_state.dart';
import 'package:gizmoglobe_client/widgets/general/status_badge.dart';

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
                        hintText: 'Find sales invoices...', // Tìm hóa đơn bán hàng
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
                      onPressed: () {
                        _showSortOptions(context);
                      },
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.add,
                      iconSize: 32,
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SalesAddScreen(),
                          ),
                        );
                    
                        // Refresh list if new invoice was created
                        if (result != null && mounted) {
                          context.read<SalesScreenCubit>().loadInvoices();
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
                                'No sales invoices found', // Không tìm thấy hóa đơn bán hàng
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
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SalesDetailScreen(
                                          invoice: invoice,
                                        ),
                                      ),
                                    );
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
                                              borderRadius: BorderRadius.circular(8),
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
                                                  title: const Text('View'), // Xem
                                                  onTap: () => _handleViewInvoice(context, invoice),
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
                                      margin: const EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        color: state.selectedIndex == index
                                            ? Theme.of(context)
                                                .primaryColor
                                                .withValues(alpha: 0.1) 
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
                                                Icons.receipt,
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
                                                    'Invoice #${invoice.salesInvoiceID}', // Hóa đơn #
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
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
                                                      StatusBadge(status: invoice.paymentStatus),
                                                      StatusBadge(status: invoice.salesStatus),
                                                      Text(
                                                        DateFormat('dd/MM/yyyy').format(invoice.date), // Ngày
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(alpha: 0.6), 
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
                          Icons.filter_list,
                          color: Theme.of(dialogContext).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sort Options', // Tùy chọn sắp xếp
                          style: TextStyle(
                            color: Theme.of(dialogContext).colorScheme.onSurface,
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
                          'Date (Newest First)', // Ngày (Mới nhất trước)
                          Icons.calendar_today,
                          () {
                            cubit.sortInvoices('date', true);
                            Navigator.pop(dialogContext);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSortOption(
                          dialogContext,
                          'Date (Oldest First)', // Ngày (Cũ nhất trước)
                          Icons.calendar_today_outlined,
                          () {
                            cubit.sortInvoices('date', false);
                            Navigator.pop(dialogContext);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSortOption(
                          dialogContext,
                          'Price (Highest First)', // Giá (Cao nhất trước)
                          Icons.attach_money,
                          () {
                            cubit.sortInvoices('price', true);
                            Navigator.pop(dialogContext);
                          },
                        ),
                        const SizedBox(height: 8),
                        _buildSortOption(
                          dialogContext,
                          'Price (Lowest First)', // Giá (Thấp nhất trước)
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
                color: Theme.of(context).primaryColor,
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

  Future<void> _handleViewInvoice(BuildContext contextDialog, SalesInvoice invoice) async {
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
      final details = await firebase.getSalesInvoiceDetails(invoice.salesInvoiceID);
      invoice.details = details;

      if (!mounted) return;
      // Close loading dialog
      Navigator.pop(context);

      // Navigate to detail screen with full invoice
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SalesDetailScreen(
            invoice: invoice,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Close loading dialog
      Navigator.pop(context);
      
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading invoice details: $e')), // Lỗi tải chi tiết hóa đơn
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
}