import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../../../../widgets/general/address_picker.dart';
import '../../../../widgets/general/field_with_icon.dart';
import 'customer_detail_cubit.dart';
import 'customer_detail_state.dart';
import '../customer_edit/customer_edit_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/customers/permissions/customer_permissions.dart';

class CustomerDetailScreen extends StatefulWidget {
  final Customer customer;
  final bool readOnly;

  static Widget newInstance({
    required Customer customer,
    bool readOnly = false,
  }) => BlocProvider(
        create: (context) => CustomerDetailCubit(customer),
        child: CustomerDetailScreen(
          customer: customer,
          readOnly: readOnly,
        ),
      );

  const CustomerDetailScreen({
    super.key,
    required this.customer,
    this.readOnly = false,
  });

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  CustomerDetailCubit get cubit => context.read<CustomerDetailCubit>();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverPhoneController = TextEditingController();
  final TextEditingController streetController = TextEditingController();
  bool isDefault = false;

  void _showAddAddressDialog(BuildContext context) {
    receiverNameController.clear();
    receiverPhoneController.clear();
    streetController.clear();
    isDefault = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Add New Address', //Thêm địa chỉ mới
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Receiver Name Field
                  Text(
                    'Receiver Name', //Tên người nhận
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FieldWithIcon(
                    controller: receiverNameController,
                    hintText: 'Enter receiver name', //Nhập tên người nhận
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.white70,),
                    onChanged: (value) {
                      cubit.updateNewAddress(
                        receiverName: value,
                      );
                    },
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  const SizedBox(height: 16),

                  // Receiver Phone Field
                  Text(
                    'Receiver Phone', //Số điện thoại người nhận
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FieldWithIcon(
                    controller: receiverPhoneController,
                    hintText: 'Enter phone number', //Nhập số điện thoại
                    prefixIcon: const Icon(Icons.phone_outlined, color: Colors.white70,),
                    onChanged: (value) {
                      cubit.updateNewAddress(
                        receiverPhone: value,
                      );
                    },
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.phone,
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  const SizedBox(height: 16),

                  // Address Picker
                  Text(
                    'Location', //Địa chỉ
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AddressPicker(
                    onAddressChanged: (province, district, ward) {
                      cubit.updateNewAddress(
                        province: province,
                        district: district,
                        ward: ward,
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Street Field
                  Text(
                    'Street Address', //Địa chỉ cụ thể
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FieldWithIcon(
                    controller: streetController,
                    hintText: 'Street name, building, house no.', //Địa chỉ cụ thể
                    prefixIcon: const Icon(Icons.home_outlined, color: Colors.white70,),
                    onChanged: (value) {
                      cubit.updateNewAddress(
                        street: value,
                      );
                    },
                    fillColor: Theme.of(context).colorScheme.surface,
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        child: Text(
                          'Cancel', //Hủy
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          if (receiverNameController.text.isEmpty ||
                              receiverPhoneController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all required fields'), //Vui lòng điền tất cả các trường bắt buộc
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          await cubit.addAddress();
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_location, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Add Address', //Thêm địa chỉ
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    streetController.dispose();
    isDefault = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomerDetailCubit(widget.customer),
      child: BlocBuilder<CustomerDetailCubit, CustomerDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: GradientIconButton(
                icon: Icons.chevron_left,
                onPressed: () {
                  Navigator.pop(context);
                },
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              title: const GradientText(text: 'Customer Detail'), //Chi tiết khách hàng
            ),
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(context, state),
                          const SizedBox(height: 24),
                          _buildInfoSection(context, state),
                          const SizedBox(height: 24),
                          _buildAddressesSection(context, state),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2), 
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: CustomerPermissions.canEditCustomers(state.userRole)
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final updatedCustomer = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CustomerEditScreen(
                                      customer: state.customer,
                                    ),
                                  ),
                                );

                                if (updatedCustomer != null) {
                                  // Update the customer in Firebase
                                  cubit.updateCustomer(updatedCustomer);
                                }
                              },
                              icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                              ),
                              label: const Text(
                                  'Edit', //Chỉnh sửa
                                  style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      )
                    : null,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, CustomerDetailState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8), 
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: 'customer_avatar_${state.customer.customerID}',
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.customer.customerName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, CustomerDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Customer Information', //Thông tin khách hàng
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Name', state.customer.customerName), //Tên khách hàng
              _buildInfoRow('Email', state.customer.email), //Email
              _buildInfoRow('Phone', state.customer.phoneNumber), //Số điện thoại
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressesSection(BuildContext context, CustomerDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Addresses', //Địa chỉ
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => _showAddAddressDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...state.customer.addresses!.map((address) {
                return GestureDetector(
                  onTap: () {
                    // Address press logic here
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address.toString(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}