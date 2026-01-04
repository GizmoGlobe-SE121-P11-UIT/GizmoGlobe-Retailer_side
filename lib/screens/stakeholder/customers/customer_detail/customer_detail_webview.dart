import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import '../../permissions/stakeholder_permissions.dart';
import 'package:gizmoglobe_client/widgets/dialog/confirmation_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../../../../enums/processing/process_state_enum.dart' show ProcessState;
import '../../../../objects/address_related/address.dart';
import '../../../../widgets/general/address_picker.dart';
import '../../../../widgets/general/field_with_icon.dart';
import '../../../../widgets/voucher/voucher_card.dart';
import '../customer_edit/customer_edit_view.dart';
import 'customer_detail_cubit.dart';
import 'customer_detail_state.dart';
import '../../../../widgets/dialog/information_dialog.dart';

class CustomerDetailWebView extends StatefulWidget {
  final Customer customer;
  final bool readOnly;

  const CustomerDetailWebView({
    super.key,
    required this.customer,
    this.readOnly = false,
  });

  static Widget newInstance({
    required Customer customer,
    bool readOnly = false,
  }) =>
      BlocProvider(
        create: (context) => CustomerDetailCubit(customer),
        child: CustomerDetailWebView(
          customer: customer,
          readOnly: readOnly,
        ),
      );

  @override
  State<CustomerDetailWebView> createState() => _CustomerDetailWebViewState();
}

class _CustomerDetailWebViewState extends State<CustomerDetailWebView> {
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
              padding: const EdgeInsets.all(16),
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
                        S.of(context).addNewAddress,
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
                    S.of(context).receiverName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FieldWithIcon(
                    controller: receiverNameController,
                    hintText: S.of(context).enterReceiverName,
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: Colors.white70,
                    ),
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
                    S.of(context).receiverPhone,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FieldWithIcon(
                    controller: receiverPhoneController,
                    hintText: S.of(context).enterPhoneNumber,
                    prefixIcon: const Icon(
                      Icons.phone_outlined,
                      color: Colors.white70,
                    ),
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
                    S.of(context).location,
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
                    S.of(context).streetAddress,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FieldWithIcon(
                    controller: streetController,
                    hintText: S.of(context).streetNameBuildingHouseNo,
                    prefixIcon: const Icon(
                      Icons.home_outlined,
                      color: Colors.white70,
                    ),
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
                          S.of(context).cancel,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (receiverNameController.text.isEmpty ||
                                receiverPhoneController.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => InformationDialog(
                                  title: S.of(context).errorOccurred,
                                  content: S
                                      .of(context)
                                      .pleaseFillInAllRequiredFields,
                                  buttonText: S.of(context).confirm,
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
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add_location,
                                  color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                S.of(context).addAddress,
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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

  void _showEditAddressDialog(BuildContext context, Address address) {
    cubit.startEditingAddress(address);
    receiverNameController.text = address.receiverName;
    receiverPhoneController.text = address.receiverPhone;
    streetController.text = address.street ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.edit_location_alt,
                        color: Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        S.of(context).editAddress,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(S.of(context).receiverName,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  FieldWithIcon(
                    controller: receiverNameController,
                    hintText: S.of(context).enterReceiverName,
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.white70),
                    fillColor: Theme.of(context).colorScheme.surface,
                    onChanged: (value) {
                      cubit.updateNewAddress(receiverName: value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(S.of(context).receiverPhone,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  FieldWithIcon(
                    controller: receiverPhoneController,
                    hintText: S.of(context).enterPhoneNumber,
                    prefixIcon:
                        const Icon(Icons.phone_outlined, color: Colors.white70),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    keyboardType: TextInputType.phone,
                    fillColor: Theme.of(context).colorScheme.surface,
                    onChanged: (value) {
                      cubit.updateNewAddress(receiverPhone: value);
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(S.of(context).location,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  AddressPicker(
                    initialProvince: address.province,
                    initialDistrict: address.district,
                    initialWard: address.ward,
                    onAddressChanged: (province, district, ward) {
                      cubit.updateNewAddress(
                        province: province,
                        district: district,
                        ward: ward,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(S.of(context).streetAddress,
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface)),
                  const SizedBox(height: 8),
                  FieldWithIcon(
                    controller: streetController,
                    hintText: S.of(context).streetNameBuildingHouseNo,
                    prefixIcon:
                        const Icon(Icons.home_outlined, color: Colors.white70),
                    fillColor: Theme.of(context).colorScheme.surface,
                    onChanged: (value) {
                      cubit.updateNewAddress(street: value);
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          cubit.clearNewAddress();
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: Text(S.of(context).cancel,
                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (receiverNameController.text.isEmpty ||
                                receiverPhoneController.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (context) => InformationDialog(
                                  title: S.of(context).errorOccurred,
                                  content: S
                                      .of(context)
                                      .pleaseFillInAllRequiredFields,
                                  buttonText: S.of(context).confirm,
                                ),
                              );
                              return;
                            }
                            await cubit.editAddress();
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.save, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(S.of(context).saveAddress,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
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
    return BlocConsumer<CustomerDetailCubit, CustomerDetailState>(
      listener: (context, state) {
        if (state.processState == ProcessState.success) {
          showDialog(
            context: context,
            builder: (context) => InformationDialog(
              title: state.dialogName.getLocalizedName(context),
              content: state.notifyMessage.getLocalizedMessage(context),
              onPressed: () {
                cubit.toIdle();
              },
            ),
          );
        } else if (state.processState == ProcessState.failure) {
          showDialog(
            context: context,
            builder: (context) => InformationDialog(
              title: state.dialogName.getLocalizedName(context),
              content: state.notifyMessage.getLocalizedMessage(context),
              onPressed: () {
                cubit.toIdle();
              },
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.processState == ProcessState.loading) {
          return Container(
            width: 600,
            height: 500,
            constraints: const BoxConstraints(
              maxWidth: 800,
              maxHeight: 600,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final containerWidth =
            isMobile ? screenWidth * 0.95 : screenWidth * 0.6;

        return Container(
          width: containerWidth,
          height: MediaQuery.of(context).size.height * 0.85,
          constraints: BoxConstraints(
            maxWidth: 800,
            maxHeight: isMobile ? double.infinity : 700,
            minWidth: 300,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientText(text: S.of(context).customerDetail),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(context, state),
                        const SizedBox(height: 16),
                        _buildInfoSection(context, state),
                        const SizedBox(height: 16),
                        _buildAddressesSection(context, state),
                        const SizedBox(height: 16),
                        _buildVouchersSection(context, state),
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: StakeholderPermissions.canEditCustomers()
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final updatedCustomer =
                                      await CustomerEditScreen.showModal(
                                    context,
                                    state.customer,
                                  );

                                  if (updatedCustomer != null) {
                                    // Update the customer in Firebase
                                    cubit.updateCustomer(updatedCustomer);

                                    // Show success snackbar before closing
                                    _showSnackBar(
                                      title: S.of(context).success,
                                      message: "Customer updated successfully.",
                                      contentType: ContentType.success,
                                    );

                                    // Small delay to show snackbar before closing
                                    await Future.delayed(
                                        const Duration(milliseconds: 100));

                                    if (mounted) {
                                      Navigator.of(context).pop(true);
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    _showErrorDialog(
                                        "Failed to update customer: ${e.toString()}");
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(S.of(context).edit,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.tertiary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
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
    );
  }

  Widget _buildHeaderSection(BuildContext context, CustomerDetailState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
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
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, CustomerDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      S.of(context).customerInformation,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(S.of(context).name, state.customer.customerName),
              _buildInfoRow(S.of(context).email, state.customer.email),
              _buildInfoRow(S.of(context).phone, state.customer.phoneNumber),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressesSection(
      BuildContext context, CustomerDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
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
                        S.of(context).addresses,
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
                  onTap: () => _showEditAddressDialog(context, address),
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: Card(
                      elevation: 10,
                      shadowColor: Theme.of(context).colorScheme.shadow,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          address.toString(),
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
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
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVouchersSection(
      BuildContext context, CustomerDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.card_giftcard,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      S.of(context).giftVouchers,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.vouchers.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      S.of(context).noVouchersAvailable,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
              else
                ...state.vouchers.map((voucher) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: GestureDetector(
                      onTap: () async {
                        showDialog(
                          context: context,
                          builder: (context) => ConfirmationDialog(
                            title: S.of(context).confirmation,
                            content: S.of(context).confirmGiftVoucher,
                            confirmText: S.of(context).confirm,
                            cancelText: S.of(context).cancel,
                            onConfirm: () async {
                              cubit.toLoading();
                              await cubit.giftVoucher(voucher);
                            },
                          ),
                        );
                      },
                      child: VoucherCard(
                        voucher: voucher,
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

  void _showSnackBar({
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    if (!mounted) return;

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showErrorDialog(String errorMessage) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).errorOccurred),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).confirm),
          ),
        ],
      ),
    );
  }
}
