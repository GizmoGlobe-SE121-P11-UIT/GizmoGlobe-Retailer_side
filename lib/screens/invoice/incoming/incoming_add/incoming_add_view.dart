import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/invoice_related/incoming_invoice_detail.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import '../../../../enums/invoice_related/payment_status.dart';
import '../../../../widgets/general/gradient_icon_button.dart';
import 'incoming_add_cubit.dart';
import 'incoming_add_state.dart';

class IncomingAddScreen extends StatefulWidget {
  const IncomingAddScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => IncomingAddCubit(),
        child: const IncomingAddScreen(),
      );

  @override
  State<IncomingAddScreen> createState() => _IncomingAddScreenState();
}

class _IncomingAddScreenState extends State<IncomingAddScreen> {
  IncomingAddCubit get cubit => context.read<IncomingAddCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<IncomingAddCubit, IncomingAddState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
          cubit.clearError();
        }
      },
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
            title: GradientText(text: 'New Incoming Invoice'),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildManufacturerDropdown(state),
                      const SizedBox(height: 16),
                      if (state.selectedManufacturer != null) ...[
                        _buildProductsList(state),
                        const SizedBox(height: 16),
                        _buildDetailsList(state),
                        const SizedBox(height: 16),
                        _buildTotalPrice(state),
                        const SizedBox(height: 16),
                        _buildPaymentStatusDropdown(state),
                        const SizedBox(height: 24),
                        _buildSubmitButton(state),
                      ],
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildManufacturerDropdown(IncomingAddState state) {
    return DropdownButtonFormField<Manufacturer>(
      decoration: InputDecoration(
        labelText: 'Select Manufacturer',
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      ),
      value: state.selectedManufacturer,
      items: state.manufacturers.map((manufacturer) {
        return DropdownMenuItem(
          value: manufacturer,
          child: Text(manufacturer.manufacturerName),
        );
      }).toList(),
      onChanged: (manufacturer) {
        if (manufacturer != null) {
          cubit.selectManufacturer(manufacturer);
        }
      },
    );
  }

  Widget _buildProductsList(IncomingAddState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Products',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _showAddProductDialog(context),
          icon: const Icon(Icons.add, color: Colors.white,),
          label: const Text('Add Product'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsList(IncomingAddState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Invoice Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.details.length,
          itemBuilder: (context, index) {
            final detail = state.details[index];
            final product = state.products.firstWhere(
              (p) => p.productID == detail.productID,
            );
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.white,
                          onPressed: () => _showEditDetailDialog(
                            context,
                            index,
                            product,
                            detail,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () => cubit.removeDetail(index),
                          constraints: const BoxConstraints(
                            minWidth: 40,
                            minHeight: 40,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Import Price: \$${detail.importPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 120),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 32,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.remove_circle_outline,
                                      color: detail.quantity > 1
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                      size: 20,
                                    ),
                                    onPressed: detail.quantity > 1
                                        ? () => cubit.updateDetailQuantity(index, detail.quantity - 1)
                                        : null,
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                                SizedBox(
                                  width: 48,
                                  child: Text(
                                    '${detail.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 32,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.add_circle_outline,
                                      color: Colors.blue,
                                      size: 20,
                                    ),
                                    onPressed: () => cubit.updateDetailQuantity(
                                      index,
                                      detail.quantity + 1,
                                    ),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '\$${detail.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                          ),
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
    );
  }

  Widget _buildTotalPrice(IncomingAddState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Text(
          'Total Price: ',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '\$${state.totalPrice.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentStatusDropdown(IncomingAddState state) {
    return DropdownButtonFormField<PaymentStatus>(
      decoration: InputDecoration(
        labelText: 'Payment Status',
        border: const OutlineInputBorder(),
        labelStyle: TextStyle(
          color: Colors.white.withOpacity(0.8),
        ),
        floatingLabelStyle: TextStyle(
          color: Theme.of(context).primaryColor,
        ),
      ),
      value: state.paymentStatus,
      items: PaymentStatus.values.map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status.toString()),
        );
      }).toList(),
      onChanged: (status) {
        if (status != null) {
          cubit.updatePaymentStatus(status);
        }
      },
    );
  }

  Widget _buildSubmitButton(IncomingAddState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.isSubmitting
            ? null
            : () async {
                final success = await cubit.submitInvoice();
                if (success && mounted) {
                  Navigator.pop(context, true);
                }
              },
        child: state.isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Create Invoice'),
      ),
    );
  }

  Future<void> _showAddProductDialog(BuildContext context) async {
    Product? selectedProduct;
    final quantityController = TextEditingController();
    final importPriceController = TextEditingController();

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
      floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      hintStyle: TextStyle(color: Colors.grey[400]),
      fillColor: Theme.of(context).cardColor,
      filled: true,
    );

    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: GradientText(text: 'Add Product'),
          content: BlocBuilder<IncomingAddCubit, IncomingAddState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Product>(
                      value: selectedProduct,
                      decoration: inputDecoration.copyWith(labelText: 'Select Product'),
                      dropdownColor: Theme.of(context).cardColor,
                      style: const TextStyle(color: Colors.white),
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
                          importPriceController.text = product.importPrice.toString();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: importPriceController,
                      decoration: inputDecoration.copyWith(labelText: 'Import Price'),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      decoration: inputDecoration.copyWith(labelText: 'Quantity'),
                      style: const TextStyle(color: Colors.white),
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
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                if (selectedProduct != null) {
                  final importPrice = double.tryParse(importPriceController.text);
                  final quantity = int.tryParse(quantityController.text);

                  if (importPrice != null && quantity != null) {
                    cubit.addDetail(selectedProduct!, importPrice, quantity);
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: Text(
                'Add',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditQuantityDialog(
    BuildContext context,
    int index,
    int currentQuantity,
  ) async {
    final controller = TextEditingController(text: currentQuantity.toString());

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Quantity'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New Quantity',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newQuantity = int.tryParse(controller.text);
              if (newQuantity != null) {
                cubit.updateDetailQuantity(index, newQuantity);
                Navigator.pop(context);
              }
            },
            child: const Text('Update'),
          ),
        ],
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
    final quantityController = TextEditingController(text: detail.quantity.toString());
    final importPriceController = TextEditingController(text: detail.importPrice.toString());

    final inputDecoration = InputDecoration(
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white.withOpacity(0.7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Theme.of(context).primaryColor),
      ),
      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
      floatingLabelStyle: TextStyle(color: Theme.of(context).primaryColor),
      hintStyle: TextStyle(color: Colors.grey[400]),
      fillColor: Theme.of(context).cardColor,
      filled: true,
    );

    return showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: cubit,
        child: AlertDialog(
          title: const Text('Edit Product Detail'),
          content: BlocBuilder<IncomingAddCubit, IncomingAddState>(
            builder: (context, state) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Product>(
                      value: selectedProduct,
                      decoration: inputDecoration.copyWith(labelText: 'Select Product'),
                      dropdownColor: Theme.of(context).cardColor,
                      style: const TextStyle(color: Colors.white),
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
                          importPriceController.text = product.importPrice.toString();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: importPriceController,
                      decoration: inputDecoration.copyWith(labelText: 'Import Price'),
                      style: const TextStyle(color: Colors.white),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      decoration: inputDecoration.copyWith(labelText: 'Quantity'),
                      style: const TextStyle(color: Colors.white),
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
                'Cancel',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            TextButton(
              onPressed: () {
                if (selectedProduct != null) {
                  final importPrice = double.tryParse(importPriceController.text);
                  final quantity = int.tryParse(quantityController.text);

                  if (importPrice != null && quantity != null) {
                    cubit.removeDetail(index);
                    cubit.addDetail(selectedProduct!, importPrice, quantity);
                    Navigator.pop(dialogContext);
                  }
                }
              },
              child: Text(
                'Update',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 