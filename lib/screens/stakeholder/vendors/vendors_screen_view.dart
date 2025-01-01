import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'vendors_screen_cubit.dart';
import 'vendors_screen_state.dart';
import 'package:gizmoglobe_client/screens/stakeholder/vendors/vendor_detail/vendor_detail_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/vendors/vendor_edit/vendor_edit_view.dart';
import '../../../enums/stakeholders/manufacturer_status.dart';
import 'package:gizmoglobe_client/widgets/general/status_badge.dart';

class VendorsScreen extends StatefulWidget {
  const VendorsScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => VendorsScreenCubit(),
        child: const VendorsScreen(),
      );

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  ManufacturerStatus selectedStatus = ManufacturerStatus.active;
  
  VendorsScreenCubit get cubit => context.read<VendorsScreenCubit>();

  void _showAddManufacturerModal() {
    // Reset controllers and status
    nameController.clear();
    selectedStatus = ManufacturerStatus.active;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.business_center,
                          color: Theme.of(context).primaryColor,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        const Flexible(
                          child: Text(
                            'Add New Manufacturer',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Manufacturer Name',
                        prefixIcon: Icon(
                          Icons.business_center,
                          color: Theme.of(context).primaryColor,
                        ),
                        labelStyle: const TextStyle(color: Colors.white),
                        floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                          (states) => TextStyle(
                            color: states.contains(MaterialState.focused)
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ManufacturerStatus>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Status',
                        prefixIcon: Icon(
                          Icons.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        labelStyle: const TextStyle(color: Colors.white),
                        floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                          (states) => TextStyle(
                            color: states.contains(MaterialState.focused)
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                      items: ManufacturerStatus.values.map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(
                            status.getName(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedStatus = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (nameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter manufacturer name'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final error = await cubit.createManufacturer(
                                nameController.text,
                                selectedStatus,
                              );

                              if (error != null) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(error),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Manufacturer added successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Add Manufacturer',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorsScreenCubit, VendorsScreenState>(
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
                        hintText: 'Find manufacturers...',
                        fillColor: Theme.of(context).colorScheme.surface,
                        onChanged: (value) {
                          cubit.searchManufacturers(value);
                        },
                        prefixIcon: Icon(Icons.search, color: Theme.of(context).primaryColor),
                      ),
                    ),
                    if (state.userRole == 'admin') ...[
                      const SizedBox(width: 8),
                      GradientIconButton(
                        icon: Icons.add,
                        iconSize: 32,
                        onPressed: _showAddManufacturerModal,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: BlocBuilder<VendorsScreenCubit, VendorsScreenState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.manufacturers.isEmpty) {
                        return const Center(
                          child: Text('No matching manufacturers found'),
                        );
                      }

                      return ListView.builder(
                        itemCount: state.manufacturers.length,
                        itemBuilder: (context, index) {
                          final manufacturer = state.manufacturers[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VendorDetailScreen(
                                    manufacturer: manufacturer,
                                  ),
                                ),
                              );
                            },
                            onLongPress: () {
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
                                            title: const Text('View'),
                                            onTap: () {
                                              Navigator.pop(context);
                                              cubit.setSelectedIndex(null);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => VendorDetailScreen(
                                                    manufacturer: manufacturer,
                                                    readOnly: state.userRole != 'admin',
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          if (state.userRole == 'admin') ...[
                                            ListTile(
                                              dense: true,
                                              leading: const Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                              title: const Text('Edit'),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                cubit.setSelectedIndex(null);
                                                final updatedManufacturer = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => VendorEditScreen(
                                                      manufacturer: manufacturer,
                                                    ),
                                                  ),
                                                );
                                                
                                                if (updatedManufacturer != null) {
                                                  await cubit.updateManufacturer(updatedManufacturer);
                                                }
                                              },
                                            ),
                                            ListTile(
                                              dense: true,
                                              leading: Icon(
                                                manufacturer.status == ManufacturerStatus.active 
                                                  ? Icons.block_outlined 
                                                  : Icons.check_circle_outline,
                                                size: 20,
                                                color: manufacturer.status == ManufacturerStatus.active
                                                  ? Theme.of(context).colorScheme.error
                                                  : Colors.green,
                                              ),
                                              title: Text(
                                                manufacturer.status == ManufacturerStatus.active 
                                                  ? 'Deactivate' 
                                                  : 'Activate',
                                                style: TextStyle(
                                                  color: manufacturer.status == ManufacturerStatus.active
                                                    ? Theme.of(context).colorScheme.error
                                                    : Colors.green,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                                cubit.setSelectedIndex(null);
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(
                                                        manufacturer.status == ManufacturerStatus.active 
                                                          ? 'Deactivate Manufacturer' 
                                                          : 'Activate Manufacturer'
                                                      ),
                                                      content: Text(
                                                        'Are you sure you want to ${manufacturer.status == ManufacturerStatus.active ? "deactivate" : "activate"} ${manufacturer.manufacturerName}?'
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(context),
                                                          child: const Text('Cancel'),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            Navigator.pop(context);
                                                            await cubit.toggleManufacturerStatus(manufacturer);
                                                          },
                                                          child: Text(
                                                            manufacturer.status == ManufacturerStatus.active 
                                                              ? 'Deactivate' 
                                                              : 'Activate',
                                                            style: TextStyle(
                                                              color: manufacturer.status == ManufacturerStatus.active
                                                                ? Theme.of(context).colorScheme.error
                                                                : Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ],
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
                              opacity: state.selectedIndex == null || state.selectedIndex == index ? 1.0 : 0.3,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: state.selectedIndex == index 
                                      ? Theme.of(context).primaryColor.withOpacity(0.1) 
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
                                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                        child: Icon(
                                          Icons.business_center,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          manufacturer.manufacturerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      StatusBadge(status: manufacturer.status.getName(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
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
}
