import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:intl/intl.dart';
import '../../../../objects/product_related/product.dart';
import 'sales_add_cubit.dart';
import 'sales_add_state.dart';

import '../../../../objects/customer.dart';

class SalesAddScreen extends StatelessWidget {
  const SalesAddScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SalesAddCubit(),
      child: const _SalesAddView(),
    );
  }
}

class _SalesAddView extends StatefulWidget {
  const _SalesAddView();

  @override
  State<_SalesAddView> createState() => _SalesAddViewState();
}

class _SalesAddViewState extends State<_SalesAddView> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();

  SalesAddCubit get cubit => context.read<SalesAddCubit>();

  Future<void> _saveInvoice(SalesAddState state) async {
    if (!_formKey.currentState!.validate()) return;

    final invoice = await cubit.createInvoice();
    if (invoice != null && mounted) {
      Navigator.pop(context, invoice);
    }
  }

  void _showAddProductDialog(BuildContext dialogContext) {
    final _quantityController = TextEditingController(text: '1');
    Product? selectedProduct;

    showDialog(
      context: dialogContext,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<SalesAddCubit>(dialogContext),
        child: StatefulBuilder(
          builder: (context, setState) {
            return BlocBuilder<SalesAddCubit, SalesAddState>(
              builder: (context, state) {
                return AlertDialog(
                  title: const Text('Add Product'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<Product>(
                        decoration: const InputDecoration(
                          labelText: 'Product',
                          hintText: 'Select product',
                        ),
                        value: selectedProduct,
                        items: state.products
                            .where((product) => product.stock > 0)
                            .map((product) {
                          return DropdownMenuItem(
                            value: product,
                            child: Text(
                              '${product.productName} (\$${product.sellingPrice.toStringAsFixed(2)}) - Stock: ${product.stock}',
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedProduct = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _quantityController,
                        decoration: const InputDecoration(
                          labelText: 'Quantity',
                          hintText: 'Enter quantity',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (selectedProduct == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select a product')),
                          );
                          return;
                        }

                        final quantity = int.tryParse(_quantityController.text) ?? 0;
                        if (quantity <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Quantity must be greater than 0')),
                          );
                          return;
                        }

                        if (quantity > selectedProduct!.stock) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Not enough stock')),
                          );
                          return;
                        }

                        context.read<SalesAddCubit>().addInvoiceDetail(
                          selectedProduct!,
                          quantity,
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesAddCubit, SalesAddState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GradientIconButton(
              icon: Icons.chevron_left,
              onPressed: () => Navigator.pop(context),
              fillColor: Theme.of(context).colorScheme.surface,
            ),
            title: const Text('New Invoice'),
            actions: [
              TextButton(
                onPressed: state.isLoading ? null : () => _saveInvoice(state),
                child: state.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<Customer>(
                      value: state.selectedCustomer,
                      decoration: const InputDecoration(
                        labelText: 'Customer',
                        hintText: 'Select customer',
                      ),
                      items: state.customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer,
                          child: Text(customer.customerName),
                        );
                      }).toList(),
                      onChanged: (customer) {
                        if (customer != null) {
                          cubit.updateCustomer(customer);
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a customer';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Address',
                        hintText: 'Enter delivery address',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter delivery address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Payment Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusDropdown<PaymentStatus>(
                      value: state.paymentStatus,
                      items: PaymentStatus.values,
                      onChanged: (status) {
                        if (status != null) {
                          cubit.updatePaymentStatus(status);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Sales Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildStatusDropdown<SalesStatus>(
                      value: state.salesStatus,
                      items: SalesStatus.values,
                      onChanged: (status) {
                        if (status != null) {
                          cubit.updateSalesStatus(status);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: DateFormat('dd/MM/yyyy').format(state.selectedDate),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: state.selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          cubit.updateDate(date);
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.invoiceDetails.length,
                      itemBuilder: (context, index) {
                        final detail = state.invoiceDetails[index];
                        return ListTile(
                          title: Text(detail.productName ?? ''),
                          subtitle: Text('\$${detail.sellingPrice} x ${detail.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$${detail.subtotal}'),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => cubit.removeDetail(index),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () => _showAddProductDialog(context),
                      child: const Text('Add Product'),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Total: \$${state.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusDropdown<T extends Enum>({
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        dropdownColor: Theme.of(context).cardColor,
        underline: const SizedBox(),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }
}