import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../../../../widgets/general/gradient_icon_button.dart';
import 'warranty_add_cubit.dart';
import 'warranty_add_state.dart';

class WarrantyAddView extends StatefulWidget {
  const WarrantyAddView({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => WarrantyAddCubit(),
        child: const WarrantyAddView(),
      );

  @override
  State<WarrantyAddView> createState() => _WarrantyAddViewState();
}

class _WarrantyAddViewState extends State<WarrantyAddView> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  WarrantyAddCubit get cubit => context.read<WarrantyAddCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WarrantyAddCubit, WarrantyAddState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GradientIconButton(
              icon: Icons.chevron_left,
              onPressed: () => Navigator.pop(context),
              fillColor: Colors.transparent,
            ),
            title: GradientText(text: S.of(context).createInvoice),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: state.isLoading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : GradientIconButton(
                        icon: Icons.check,
                        onPressed: () => _saveInvoice(state),
                        fillColor: Colors.transparent,
                      ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Information Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            S.of(context).customerInformation,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Customer Selection
                          DropdownButtonFormField<String>(
                            value: state.selectedCustomerId,
                            decoration: InputDecoration(
                              labelText: S.of(context).selectCustomer,
                              labelStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8)),
                              prefixIcon: Icon(Icons.person_outline,
                                  color: Colors.white.withValues(alpha: 0.7)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    const BorderSide(color: Colors.white),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                            items: state.availableCustomers.map((customer) {
                              return DropdownMenuItem(
                                value: customer.customerID,
                                child: Text(customer.customerName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                cubit.selectCustomer(value);
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).pleaseSelectCustomer;
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (state.selectedCustomerId != null) ...[
                    if (state.customerInvoices.isEmpty)
                      // No Invoices Message Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                S.of(context).noSalesInvoicesAvailable,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                S.of(context).noEligibleSalesInvoices,
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    else ...[
                      // Invoice Details Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.of(context).invoiceDetails,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Sales Invoice Selection
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: S.of(context).salesInvoice,
                                  labelStyle: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  filled: true,
                                  fillColor:
                                      Theme.of(context).colorScheme.surface,
                                ),
                                style: const TextStyle(color: Colors.white),
                                dropdownColor:
                                    Theme.of(context).colorScheme.surface,
                                items: state.customerInvoices.map((invoice) {
                                  return DropdownMenuItem<String>(
                                    value: invoice.salesInvoiceID,
                                    child: Text(
                                      '${invoice.salesInvoiceID} - ${invoice.customerName}',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? invoiceId) {
                                  if (invoiceId != null) {
                                    final selectedInvoice =
                                        state.customerInvoices.firstWhere(
                                      (invoice) =>
                                          invoice.salesInvoiceID == invoiceId,
                                      orElse: () =>
                                          state.customerInvoices.first,
                                    );
                                    cubit.selectSalesInvoice(selectedInvoice);
                                  }
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return S
                                        .of(context)
                                        .pleaseSelectSalesInvoice;
                                  }
                                  return null;
                                },
                                value: state.customerInvoices.any((invoice) =>
                                        invoice.salesInvoiceID ==
                                        state.selectedSalesInvoiceId)
                                    ? state.selectedSalesInvoiceId
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              // Reason Input
                              TextFormField(
                                controller: _reasonController,
                                decoration: InputDecoration(
                                  labelText:
                                      S.of(context).reasonForWarrantyLabel,
                                  labelStyle: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8)),
                                  prefixIcon: Icon(Icons.description_outlined,
                                      color:
                                          Colors.white.withValues(alpha: 0.7)),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        const BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                maxLines: 3,
                                onChanged: cubit.updateReason,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Products Card
                      if (state.selectedSalesInvoice != null)
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).selectProductsForWarranty,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: state
                                      .selectedSalesInvoice!.details.length,
                                  itemBuilder: (context, index) {
                                    final detail = state
                                        .selectedSalesInvoice!.details[index];
                                    final product =
                                        state.products[detail.productID];
                                    final isSelected = state.selectedProducts
                                        .contains(detail.productID);

                                    return Card(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      child: ListTile(
                                        leading: Checkbox(
                                          value: isSelected,
                                          onChanged: (bool? value) {
                                            if (value == true) {
                                              cubit.selectProduct(
                                                  detail.productID);
                                            } else {
                                              cubit.deselectProduct(
                                                  detail.productID);
                                            }
                                          },
                                          activeColor:
                                              Theme.of(context).primaryColor,
                                          checkColor: Colors.white,
                                          side: BorderSide(
                                            color: Colors.white
                                                .withValues(alpha: 0.8),
                                            width: 2,
                                          ),
                                        ),
                                        title: Text(
                                          product?.productName ??
                                              S.of(context).loading,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${S.of(context).category}: ${product?.category.toString() ?? S.of(context).unknownCategory}',
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .primaryColor,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withValues(alpha: 0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                  ),
                                                  child: Text(
                                                    '${S.of(context).price}: \$${detail.sellingPrice.toStringAsFixed(2)}',
                                                    style: const TextStyle(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            if (isSelected)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Text(
                                                    '${S.of(context).availableStock}: ${detail.quantity}',
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap:
                                                        () {}, // Prevent tap propagation
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: IconButton(
                                                            icon: Icon(
                                                              Icons
                                                                  .remove_circle_outline,
                                                              color: state.productQuantities[
                                                                          detail
                                                                              .productID] ==
                                                                      1
                                                                  ? Colors.grey
                                                                  : Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                            ),
                                                            onPressed:
                                                                state.productQuantities[
                                                                            detail.productID] ==
                                                                        1
                                                                    ? null
                                                                    : () {
                                                                        cubit.decrementProductQuantity(
                                                                            detail.productID);
                                                                      },
                                                            constraints:
                                                                const BoxConstraints(
                                                              minWidth: 40,
                                                              minHeight: 40,
                                                            ),
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                        ),
                                                        Container(
                                                          width: 40,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor
                                                                .withValues(
                                                                    alpha: 0.1),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 4),
                                                          child: Text(
                                                            '${state.productQuantities[detail.productID] ?? 1}',
                                                            style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor,
                                                            ),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        ),
                                                        Material(
                                                          color: Colors
                                                              .transparent,
                                                          child: IconButton(
                                                            icon: Icon(
                                                              Icons
                                                                  .add_circle_outline,
                                                              color: (state.productQuantities[detail
                                                                              .productID] ??
                                                                          1) >=
                                                                      detail
                                                                          .quantity
                                                                  ? Colors.grey
                                                                  : Theme.of(
                                                                          context)
                                                                      .primaryColor,
                                                            ),
                                                            onPressed: (state.productQuantities[detail
                                                                            .productID] ??
                                                                        1) >=
                                                                    detail
                                                                        .quantity
                                                                ? null
                                                                : () {
                                                                    cubit.incrementProductQuantity(
                                                                        detail
                                                                            .productID);
                                                                  },
                                                            constraints:
                                                                const BoxConstraints(
                                                              minWidth: 40,
                                                              minHeight: 40,
                                                            ),
                                                            padding:
                                                                EdgeInsets.zero,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                            else
                                              Text(
                                                '${S.of(context).availableStock}: ${detail.quantity}',
                                                style: const TextStyle(
                                                  color: Colors.blue,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                          ],
                                        ),
                                        onTap: () {
                                          if (isSelected) {
                                            cubit.deselectProduct(
                                                detail.productID);
                                          } else {
                                            cubit.selectProduct(
                                                detail.productID);
                                          }
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _saveInvoice(WarrantyAddState state) async {
    // Unfocus any text field first
    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));

    if (!_formKey.currentState!.validate()) {
      if (kDebugMode) {
        print('Form validation failed');
      } // Lỗi xác thực biểu mẫu
      return;
    }

    if (kDebugMode) {
      print('Starting save process');
    } // Bắt đầu quá trình lưu

    // Store context before async operation
    final BuildContext dialogContext = context;

    // Show loading indicator
    showDialog(
      context: dialogContext,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const PopScope(
          canPop: false,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );

    try {
      final invoice = await cubit.submit();

      if (!mounted) return;

      // Hide loading indicator
      if (Navigator.canPop(dialogContext)) {
        Navigator.pop(dialogContext);
      }

      if (invoice != null) {
        if (kDebugMode) {
          print(
              'Invoice created successfully, force navigating back to warranty screen');
        } // Tạo hóa đơn thành công

        // Show success message using root context
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).warrantyInvoiceCreated),
            backgroundColor: Colors.green,
          ),
        );

        // Force navigation back to warranty screen
        if (mounted) {
          // Pop until we reach the warranty screen
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      } else if (state.errorMessage != null) {
        if (kDebugMode) {
          print('Error creating invoice: ${state.errorMessage}');
        } //
        ScaffoldMessenger.of(dialogContext).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error during save process: $e');
      }
      if (!mounted) return;

      // Hide loading indicator if still showing
      if (Navigator.canPop(dialogContext)) {
        Navigator.pop(dialogContext);
      }

      // Show error message
      ScaffoldMessenger.of(dialogContext).showSnackBar(
        SnackBar(
          content:
              Text(S.of(context).errorCreatingWarrantyInvoice(e.toString())),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }
}
