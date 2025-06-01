import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/objects/invoice_related/warranty_invoice.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_view.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/status_badge.dart';
import 'package:intl/intl.dart';

import '../../../../enums/invoice_related/warranty_status.dart';
import '../permissions/warranty_invoice_permissions.dart';
import 'warranty_detail_cubit.dart';
import 'warranty_detail_state.dart';

class WarrantyDetailView extends StatelessWidget {
  final WarrantyInvoice invoice;

  const WarrantyDetailView({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WarrantyDetailCubit(invoice),
      child: const _WarrantyDetailView(),
    );
  }
}

class _WarrantyDetailView extends StatelessWidget {
  const _WarrantyDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WarrantyDetailCubit, WarrantyDetailState>(
      builder: (context, state) {
        final cubit = context.read<WarrantyDetailCubit>();

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
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Icon(
                                  Icons.build_circle,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                S.of(context).warrantyReceipt(
                                    state.invoice.warrantyInvoiceID.toString()),
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              S.of(context).warrantyInformation,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildInfoRow(
                                S.of(context).customer,
                                state.invoice.customerName ??
                                    S.of(context).unknownProduct),
                            _buildInfoRow(
                                S.of(context).date,
                                DateFormat('dd/MM/yyyy')
                                    .format(state.invoice.date)),
                            _buildInfoRow(S.of(context).salesInvoice,
                                '#${state.invoice.salesInvoiceID}'),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    S.of(context).status,
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    S.of(context).reasonForWarranty,
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    state.invoice.reason,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              S.of(context).productsUnderWarranty,
                              style: const TextStyle(
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
                                final product =
                                    state.products[detail.productID];
                                return Card(
                                  child: ListTile(
                                    onTap: () async {
                                      final product = await context
                                          .read<WarrantyDetailCubit>()
                                          .getProduct(detail.productID);
                                      if (product != null && context.mounted) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => BlocProvider(
                                              create: (context) =>
                                                  ProductDetailCubit(product),
                                              child: ProductDetailScreen(
                                                product: product,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    title: Text(
                                      product?.productName ??
                                          '${S.of(context).products} #${detail.productID}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      product?.category.toString() ??
                                          S.of(context).unknownCategory,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.6),
                                      ),
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'x${detail.quantity}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (WarrantyInvoicePermissions.canEditStatus(
                                state.userRole, state.invoice)) ...[
                              const SizedBox(height: 32),
                              SizedBox(
                                width: double.infinity,
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext dialogContext) {
                                        WarrantyStatus? selectedStatus =
                                            state.invoice.status;

                                        return StatefulBuilder(
                                          builder: (context, setState) {
                                            return AlertDialog(
                                              title: Text(S
                                                  .of(context)
                                                  .updateWarrantyStatus),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  DropdownButton<
                                                      WarrantyStatus>(
                                                    value: selectedStatus,
                                                    isExpanded: true,
                                                    items: WarrantyStatus.values
                                                        .map((status) {
                                                      return DropdownMenuItem(
                                                        value: status,
                                                        child: Text(
                                                          status
                                                              .toString()
                                                              .split('.')
                                                              .last,
                                                          style: TextStyle(
                                                            fontWeight: status ==
                                                                    state
                                                                        .invoice
                                                                        .status
                                                                ? FontWeight
                                                                    .bold
                                                                : FontWeight
                                                                    .normal,
                                                          ),
                                                        ),
                                                      );
                                                    }).toList(),
                                                    onChanged: (WarrantyStatus?
                                                        newStatus) {
                                                      if (newStatus != null) {
                                                        setState(() {
                                                          selectedStatus =
                                                              newStatus;
                                                        });
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          dialogContext),
                                                  child: Text(
                                                      S.of(context).cancel),
                                                ),
                                                TextButton(
                                                  onPressed: selectedStatus ==
                                                          state.invoice.status
                                                      ? null
                                                      : () async {
                                                          final confirmed =
                                                              await showDialog<
                                                                  bool>(
                                                            context:
                                                                dialogContext,
                                                            builder: (BuildContext
                                                                confirmContext) {
                                                              return AlertDialog(
                                                                title: Text(S
                                                                    .of(context)
                                                                    .confirmStatusUpdate),
                                                                content: Text(
                                                                  S.of(context).areYouSureChangeStatus(
                                                                      selectedStatus
                                                                          .toString()
                                                                          .split(
                                                                              '.')
                                                                          .last),
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            confirmContext,
                                                                            false),
                                                                    child: Text(S
                                                                        .of(context)
                                                                        .cancel),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            confirmContext,
                                                                            true),
                                                                    child: Text(S
                                                                        .of(context)
                                                                        .confirm),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );

                                                          if (confirmed ==
                                                              true) {
                                                            Navigator.pop(
                                                                dialogContext);
                                                            cubit.updateWarrantyStatus(
                                                                selectedStatus!);
                                                          }
                                                        },
                                                  child:
                                                      Text(S.of(context).save),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                  icon: const Icon(Icons.edit),
                                  label: Text(S.of(context).updateStatus),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ],
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

  // IconData _getCategoryIcon(String? category) {
  //   if (category == null) return Icons.device_unknown;
  //
  //   // Convert string to CategoryEnum
  //   CategoryEnum? categoryEnum;
  //   try {
  //     categoryEnum = CategoryEnum.nonEmptyValues.firstWhere(
  //       (e) => e.getName().toLowerCase() == category.toLowerCase()
  //     );
  //   } catch (e) {
  //     return Icons.device_unknown;
  //   }
  //
  //   switch (categoryEnum) {
  //     case CategoryEnum.ram:
  //       return Icons.memory;
  //     case CategoryEnum.cpu:
  //       return Icons.computer;
  //     case CategoryEnum.psu:
  //       return Icons.power;
  //     case CategoryEnum.gpu:
  //       return Icons.videogame_asset;
  //     case CategoryEnum.drive:
  //       return Icons.storage;
  //     case CategoryEnum.mainboard:
  //       return Icons.developer_board;
  //     default:
  //       return Icons.device_unknown;
  //   }
  // }
}
