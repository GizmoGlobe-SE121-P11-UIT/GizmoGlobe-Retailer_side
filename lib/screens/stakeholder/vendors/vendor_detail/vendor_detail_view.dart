import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import '../../../../enums/stakeholders/manufacturer_status.dart';
import 'vendor_detail_cubit.dart';
import 'vendor_detail_state.dart';
import '../vendor_edit/vendor_edit_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/vendors/permissions/vendor_permissions.dart';

class VendorDetailScreen extends StatefulWidget {
  final Manufacturer manufacturer;
  final bool readOnly;

  const VendorDetailScreen({
    super.key,
    required this.manufacturer,
    this.readOnly = false,
  });

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VendorDetailCubit(widget.manufacturer),
      child: BlocBuilder<VendorDetailCubit, VendorDetailState>(
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
              title: const GradientText(text: 'Manufacturer Detail'), // Chi tiết nhà cung cấp
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
                          _buildInfoSection(context, state),
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
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: (widget.readOnly || !VendorPermissions.canManageVendors(state.userRole)) 
                    ? null 
                    : Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final updatedManufacturer = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VendorEditScreen(
                                    manufacturer: state.manufacturer,
                                  ),
                                ),
                              );

                              if (updatedManufacturer != null) {
                                final cubit = context.read<VendorDetailCubit>();
                                cubit.updateManufacturer(updatedManufacturer);
                              }
                            },
                            icon: const Icon(Icons.edit, color: Colors.white),
                            label: const Text('Edit', style: TextStyle(color: Colors.white)), // Chỉnh sửa
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final cubit = context.read<VendorDetailCubit>();
                              showDialog(
                                context: context,
                                builder: (dialogContext) => AlertDialog(
                                  title: Text(
                                    state.manufacturer.status == ManufacturerStatus.active 
                                      ? 'Deactivate Manufacturer'
                                      : 'Activate Manufacturer'
                                  ),
                                  content: Text(
                                    'Are you sure you want to ${state.manufacturer.status == ManufacturerStatus.active ? "deactivate" : "activate"} this manufacturer?', // Bạn có chắc chắn muốn ${state.manufacturer.status == ManufacturerStatus.active ? "vô hiệu hóa" : "kích hoạt"} nhà cung cấp này?
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(dialogContext),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(dialogContext);
                                        await cubit.toggleManufacturerStatus();
                                        if (mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                      child: Text(
                                        state.manufacturer.status == ManufacturerStatus.active 
                                          ? 'Inactive'
                                          : 'Activate',
                                        style: TextStyle(
                                          color: state.manufacturer.status == ManufacturerStatus.active
                                            ? Colors.red
                                            : Colors.green,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: Icon(
                              state.manufacturer.status == ManufacturerStatus.active 
                                ? Icons.block 
                                : Icons.check_circle,
                              color: Colors.white
                            ),
                            label: Text(
                              state.manufacturer.status == ManufacturerStatus.active 
                                ? 'Deactivate' 
                                : 'Activate',
                              style: const TextStyle(color: Colors.white)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.manufacturer.status == ManufacturerStatus.active 
                                ? Colors.red 
                                : Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, VendorDetailState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
            Theme.of(context).colorScheme.primary.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            tag: 'vendor_avatar_${state.manufacturer.manufacturerID}',
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.business,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.manufacturer.manufacturerName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          _buildStatusBadge(state.manufacturer.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ManufacturerStatus status) {
    final isActive = status == ManufacturerStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.green.shade100 : Colors.red.shade100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 20,
            color: isActive ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            status.getName().toUpperCase(),
            style: TextStyle(
              color: isActive ? Colors.green.shade800 : Colors.red.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, VendorDetailState state) {
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
                    'Manufacturer Information', //Thông tin nhà cung cấp
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow('Name', //Tên nhà cung cấp
                  state.manufacturer.manufacturerName,
                valueColor: Colors.white,
              ),
              _buildInfoRow(
                'Status', // Trạng thái
                state.manufacturer.status.getName(),
                valueColor: state.manufacturer.status == ManufacturerStatus.active 
                    ? Colors.green.shade400 
                    : Colors.red.shade400,
                icon: state.manufacturer.status == ManufacturerStatus.active
                    ? Icons.check_circle
                    : Icons.cancel,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor, IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: valueColor),
                  const SizedBox(width: 4),
                ],
                Text(
                  value,
                  style: TextStyle(
                    color: valueColor ?? Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 