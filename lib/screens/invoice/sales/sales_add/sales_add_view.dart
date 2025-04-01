import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoice created successfully.'), // Tạo hóa đơn thành công
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, invoice);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error ?? 'Error occurred'), // Có lỗi xảy ra
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddProductDialog(BuildContext dialogContext) {
    final quantityController = TextEditingController(text: '1');

    showDialog(
      context: dialogContext,
      builder: (_) => BlocProvider.value(
        value: BlocProvider.of<SalesAddCubit>(dialogContext),
        child: BlocBuilder<SalesAddCubit, SalesAddState>(
          builder: (context, state) {
            return AlertDialog(
              title: const Text('Add Product'), // Thêm sản phẩm
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Product>(
                      value: state.selectedModalProduct,
                      onChanged: (product) {
                        context.read<SalesAddCubit>().updateSelectedModalProduct(product);
                      },
                      decoration: InputDecoration(
                        labelText: 'Product', // Sản phẩm
                        hintText: 'Select product', // Chọn sản phẩm
                        labelStyle: const TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      hint: Text(
                        'Select product', // Chọn sản phẩm
                        style: TextStyle(color: Colors.white.withOpacity(0.7)),
                      ),
                      items: state.products
                          .where((product) => product.stock > 0)
                          .map((product) {
                        return DropdownMenuItem<Product>(
                          value: product,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.6,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product.productName,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(\$${product.sellingPrice.toStringAsFixed(2)})',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '[${product.stock}]',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: const TextStyle(color: Colors.white),
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity', // Số lượng
                        hintText: 'Enter quantity', // Nhập số lượng
                        labelStyle: const TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.read<SalesAddCubit>().updateSelectedModalProduct(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'), // Hủy
                ),
                TextButton(
                  onPressed: () {
                    if (state.selectedModalProduct == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a product')), // Vui lòng chọn sản phẩm
                      );
                      return;
                    }

                    final quantity = int.tryParse(quantityController.text) ?? 0;
                    if (quantity <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quantity must be greater than 0')), // Số lượng phải lớn hơn 0
                      );
                      return;
                    }

                    if (quantity > state.selectedModalProduct!.stock) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Not enough stock')), // Không đủ hàng tồn
                      );
                      return;
                    }

                    context.read<SalesAddCubit>().addInvoiceDetail(
                      state.selectedModalProduct!,
                      quantity,
                    );
                    context.read<SalesAddCubit>().updateSelectedModalProduct(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Add'), // Thêm
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddressBottomSheet(BuildContext context, SalesAddState state) async {
    try {
      if (state.selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a customer first'), // Vui lòng chọn khách hàng trước
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final addresses = await Firebase().getCustomerAddresses(state.selectedCustomer!.customerID!);

      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                  const Text(
                    'Enter Address', // Nhập địa chỉ
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (addresses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No address found'), // Không tìm thấy địa chỉ
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          address.receiverName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          address.toString(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                        trailing: address.hidden
                            ? Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () {
                          _addressController.text = address.toString();
                          cubit.updateAddress(address);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'), // Lỗi
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
              fillColor: Colors.transparent,
            ),
            title: const GradientText(text: 'New Invoice'), // Hóa đơn mới
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            const Text(
                              'Customer Information', // Thông tin khách hàng
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<Customer>(
                              value: state.selectedCustomer,
                              hint: Text(
                                'Select customer', // Chọn khách hàng
                                style: TextStyle(color: Colors.white.withOpacity(0.7)),
                              ),
                              decoration: InputDecoration(
                                labelText: 'Customer', // Khách hàng
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                                prefixIcon: Icon(Icons.person_outline, color: Colors.white.withOpacity(0.7)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                              ),
                              style: const TextStyle(color: Colors.white),
                              dropdownColor: Theme.of(context).colorScheme.surface,
                              icon: Icon(Icons.arrow_drop_down, color: Colors.white.withOpacity(0.7)),
                              iconEnabledColor: Colors.white,
                              iconDisabledColor: Colors.white.withOpacity(0.5),
                              items: state.customers.map((customer) {
                                return DropdownMenuItem(
                                  value: customer,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.account_circle, size: 20, color: Colors.white,),
                                      const SizedBox(width: 8),
                                      Text(customer.customerName),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (customer) {
                                if (customer != null) {
                                  cubit.updateCustomer(customer);
                                  _addressController.clear();
                                }
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a customer'; // Vui lòng chọn khách hàng
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              readOnly: true,
                              onTap: () => _showAddressBottomSheet(context, state),
                              decoration: InputDecoration(
                                labelText: 'Address', // Địa chỉ
                                labelStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
                                prefixIcon: Icon(
                                  Icons.location_on_outlined,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: Colors.white),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                                ),
                                filled: true,
                                fillColor: Theme.of(context).colorScheme.surface,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  onPressed: () => _showAddressBottomSheet(context, state),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select an address'; // Vui lòng chọn địa chỉ
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                            const Text(
                              'Invoice Details', // Chi tiết hóa đơn
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Payment Status', // Trạng thái thanh toán
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
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
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Sales Status', // Trạng thái bán hàng
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.8),
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
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).primaryColor.withOpacity(0.8),
                                      Theme.of(context).primaryColor,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.attach_money,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Total Amount', // Tổng số tiền
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '\$${state.totalPrice.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Products', // Sản phẩm
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _showAddProductDialog(context),
                                  icon: const Icon(Icons.add, color: Colors.white,),
                                  label: const Text('Add Product'), // Thêm sản phẩm
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (state.invoiceDetails.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'No products added yet', // Chưa thêm sản phẩm nào
                                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: state.invoiceDetails.length,
                                itemBuilder: (context, index) {
                                  final detail = state.invoiceDetails[index];
                                  final product = state.products.firstWhere(
                                    (p) => p.productID == detail.productID,
                                  );
                                  
                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  detail.productName ?? '',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete),
                                                onPressed: () => cubit.removeDetail(index),
                                                color: Colors.red,
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 16,
                                            runSpacing: 8,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                'Price: \$${detail.sellingPrice.toStringAsFixed(2)}', // Giá:
                                                style: TextStyle(
                                                  color: Colors.white.withOpacity(0.8),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.remove_circle_outline,
                                                      color: detail.quantity > 1 
                                                          ? Theme.of(context).colorScheme.primary
                                                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                                    ),
                                                    onPressed: detail.quantity > 1
                                                        ? () => cubit.updateDetailQuantity(index, detail.quantity - 1)
                                                        : null,
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                  ),
                                                  Container(
                                                    constraints: const BoxConstraints(minWidth: 40),
                                                    child: Text(
                                                      '${detail.quantity}',
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: 16,
                                                      ),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.add_circle_outline,
                                                      color: detail.quantity < product.stock
                                                          ? Theme.of(context).colorScheme.primary
                                                          : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                                    ),
                                                    onPressed: detail.quantity < product.stock
                                                        ? () => cubit.updateDetailQuantity(index, detail.quantity + 1)
                                                        : null,
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '\$${detail.subtotal.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            'Available stock: ${product.stock}', // Hàng tồn kho:
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            if (state.invoiceDetails.isNotEmpty) ...[
                              const Divider(height: 32),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        'Total Amount', // Tổng số tiền
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${state.totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
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
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        dropdownColor: Theme.of(context).colorScheme.surface,
        underline: const SizedBox(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        items: items.map((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              item.toString().split('.').last,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}