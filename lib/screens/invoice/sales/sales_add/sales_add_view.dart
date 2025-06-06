import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';

import '../../../../objects/customer.dart';
import '../../../../objects/product_related/product.dart';
import 'sales_add_cubit.dart';
import 'sales_add_state.dart';

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
      showDialog(
        context: context,
        builder: (context) => InformationDialog(
          title: S.of(context).success,
          content: S.of(context).createInvoice,
          buttonText: 'OK',
          onPressed: () {
            Navigator.pop(context);
            Navigator.pop(context, invoice);
          },
        ),
      );
    } else if (mounted) {
      showDialog(
        context: context,
        builder: (context) => InformationDialog(
          title: S.of(context).errorOccurred,
          content: state.error ?? S.of(context).errorOccurred,
          buttonText: 'OK',
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
              title: Text(
                S.of(context).addProduct,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<Product>(
                      value: state.selectedModalProduct,
                      onChanged: (product) {
                        context
                            .read<SalesAddCubit>()
                            .updateSelectedModalProduct(product);
                      },
                      decoration: InputDecoration(
                        labelText: S.of(context).product,
                        hintText: S.of(context).selectProduct,
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      hint: Text(
                        S.of(context).selectProduct,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
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
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '(\$${product.sellingPrice.toStringAsFixed(2)})',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '[${product.stock}]',
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      isExpanded: true,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Enter quantity',
                        labelStyle: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        hintStyle: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context
                        .read<SalesAddCubit>()
                        .updateSelectedModalProduct(null);
                    Navigator.pop(context);
                  },
                  child: Text(
                    S.of(context).cancel,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (state.selectedModalProduct == null) {
                      showDialog(
                        context: context,
                        builder: (context) => InformationDialog(
                          title: S.of(context).errorOccurred,
                          content: S.of(context).pleaseSelectProduct,
                          buttonText: 'OK',
                        ),
                      );
                      return;
                    }

                    final quantity = int.tryParse(quantityController.text) ?? 0;
                    if (quantity <= 0) {
                      showDialog(
                        context: context,
                        builder: (context) => InformationDialog(
                          title: S.of(context).errorOccurred,
                          content: S.of(context).quantityGreaterThanZero,
                          buttonText: 'OK',
                        ),
                      );
                      return;
                    }

                    if (quantity > state.selectedModalProduct!.stock) {
                      showDialog(
                        context: context,
                        builder: (context) => InformationDialog(
                          title: S.of(context).errorOccurred,
                          content: S.of(context).notEnoughStock,
                          buttonText: 'OK',
                        ),
                      );
                      return;
                    }

                    context.read<SalesAddCubit>().addInvoiceDetail(
                          state.selectedModalProduct!,
                          quantity,
                        );
                    context
                        .read<SalesAddCubit>()
                        .updateSelectedModalProduct(null);
                    Navigator.pop(context);
                  },
                  child: Text(
                    S.of(context).add,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAddressBottomSheet(
      BuildContext context, SalesAddState state) async {
    try {
      if (state.selectedCustomer == null) {
        showDialog(
          context: context,
          builder: (context) => InformationDialog(
            title: S.of(context).errorOccurred,
            content: S.of(context).pleaseSelectCustomerFirst,
            buttonText: 'OK',
          ),
        );
        return;
      }

      final addresses = await Firebase()
          .getCustomerAddresses(state.selectedCustomer!.customerID!);

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
                  Text(
                    S.of(context).enterAddress,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (addresses.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    S.of(context).noAddressFound,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context)
                          .colorScheme
                          .surface
                          .withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.1),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          address.receiverName,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          address.toString(),
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
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
        showDialog(
          context: context,
          builder: (context) => InformationDialog(
            title: S.of(context).errorOccurred,
            content: 'Error: $e',
            buttonText: 'OK',
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
            title: GradientText(text: S.of(context).newInvoice),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: state.isLoading
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
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
                            Text(
                              S.of(context).customerInformation,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<Customer>(
                              value: state.selectedCustomer,
                              hint: Text(
                                S.of(context).selectCustomer,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                              ),
                              decoration: InputDecoration(
                                labelText: S.of(context).customer,
                                labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.8),
                                ),
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              dropdownColor:
                                  Theme.of(context).colorScheme.surface,
                              icon: Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.7),
                              ),
                              iconEnabledColor:
                                  Theme.of(context).colorScheme.onSurface,
                              iconDisabledColor: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.5),
                              items: state.customers.map((customer) {
                                return DropdownMenuItem(
                                  value: customer,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.account_circle,
                                        size: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        customer.customerName,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface,
                                        ),
                                      ),
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
                                  return S.of(context).pleaseSelectCustomer;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _addressController,
                              readOnly: true,
                              onTap: () =>
                                  _showAddressBottomSheet(context, state),
                              decoration: InputDecoration(
                                labelText: S.of(context).address,
                                labelStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.8),
                                ),
                                prefixIcon: Icon(
                                  Icons.location_on_outlined,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                filled: true,
                                fillColor:
                                    Theme.of(context).colorScheme.surface,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.7),
                                  ),
                                  onPressed: () =>
                                      _showAddressBottomSheet(context, state),
                                ),
                              ),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 3,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return S.of(context).pleaseSelectAddress;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
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
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        S.of(context).paymentStatus,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.8),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        S.of(context).salesStatus,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.8),
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
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                                .withValues(alpha: 0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            Icons.attach_money,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            size: 24,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          S.of(context).totalAmount,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      '\$${state.totalPrice.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                                Text(
                                  S.of(context).products,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () =>
                                      _showAddProductDialog(context),
                                  icon: Icon(
                                    Icons.add,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  label: Text(
                                    S.of(context).addProduct,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.primary,
                                    foregroundColor:
                                        Theme.of(context).colorScheme.onPrimary,
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
                                    S.of(context).noProductsAddedYet,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.7),
                                    ),
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  detail.productName ?? '',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
                                                ),
                                                onPressed: () =>
                                                    cubit.removeDetail(index),
                                                padding: EdgeInsets.zero,
                                                constraints:
                                                    const BoxConstraints(),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Wrap(
                                            spacing: 16,
                                            runSpacing: 8,
                                            crossAxisAlignment:
                                                WrapCrossAlignment.center,
                                            children: [
                                              Text(
                                                '${S.of(context).price}: \$${detail.sellingPrice.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface
                                                      .withValues(alpha: 0.8),
                                                ),
                                              ),
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons
                                                          .remove_circle_outline,
                                                      color: detail.quantity > 1
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                  alpha: 0.3),
                                                    ),
                                                    onPressed: detail.quantity >
                                                            1
                                                        ? () => cubit
                                                            .updateDetailQuantity(
                                                                index,
                                                                detail.quantity -
                                                                    1)
                                                        : null,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  ),
                                                  Container(
                                                    constraints:
                                                        const BoxConstraints(
                                                            minWidth: 40),
                                                    child: Text(
                                                      '${detail.quantity}',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      Icons.add_circle_outline,
                                                      color: detail.quantity <
                                                              product.stock
                                                          ? Theme.of(context)
                                                              .colorScheme
                                                              .primary
                                                          : Theme.of(context)
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(
                                                                  alpha: 0.3),
                                                    ),
                                                    onPressed: detail.quantity <
                                                            product.stock
                                                        ? () => cubit
                                                            .updateDetailQuantity(
                                                                index,
                                                                detail.quantity +
                                                                    1)
                                                        : null,
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '\$${detail.subtotal.toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              '${S.of(context).availableStock}: ${product.stock}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            // if (state.invoiceDetails.isNotEmpty) ...[
                            //   const Divider(height: 32),
                            //   Row(
                            //     mainAxisAlignment: MainAxisAlignment.end,
                            //     children: [
                            //       Column(
                            //         crossAxisAlignment: CrossAxisAlignment.end,
                            //         children: [
                            //           Text(
                            //             S.of(context).totalAmount,
                            //             style: TextStyle(
                            //               fontSize: 16,
                            //               color: Theme.of(context)
                            //                   .colorScheme
                            //                   .onSurface
                            //                   .withValues(alpha: 0.8),
                            //             ),
                            //           ),
                            //           const SizedBox(height: 4),
                            //           Text(
                            //             '\$${state.totalPrice.toStringAsFixed(2)}',
                            //             style: TextStyle(
                            //               fontSize: 24,
                            //               fontWeight: FontWeight.bold,
                            //               color: Theme.of(context)
                            //                   .colorScheme
                            //                   .onSurface,
                            //             ),
                            //           ),
                            //         ],
                            //       ),
                            //     ],
                            //   ),
                            // ],
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
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        dropdownColor: Theme.of(context).colorScheme.surface,
        underline: const SizedBox(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        items: items.map((T item) {
          String displayText;
          if (item is PaymentStatus) {
            displayText = item.getLocalizedName(context);
          } else if (item is SalesStatus) {
            displayText = item.getLocalizedName(context);
          } else {
            displayText = item.toString().split('.').last;
          }
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              displayText,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
