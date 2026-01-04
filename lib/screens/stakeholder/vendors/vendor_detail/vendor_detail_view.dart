import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../../../../enums/stakeholders/manufacturer_status.dart';
import '../../permissions/stakeholder_permissions.dart';
import '../vendor_edit/vendor_edit_view.dart';
import 'vendor_detail_cubit.dart';
import 'vendor_detail_state.dart';
import 'vendor_detail_webview.dart';

class VendorDetailScreen extends StatefulWidget {
  final Manufacturer manufacturer;
  final bool readOnly;

  const VendorDetailScreen({
    super.key,
    required this.manufacturer,
    this.readOnly = false,
  });

  static Future<Manufacturer?> showModal(
    BuildContext context,
    Manufacturer manufacturer, {
    bool readOnly = false,
  }) async {
    if (kIsWeb) {
      return await showDialog<Manufacturer>(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: VendorDetailWebView.newInstance(
            manufacturer: manufacturer,
            readOnly: readOnly,
          ),
        ),
      );
    } else {
      return await Navigator.push<Manufacturer>(
        context,
        MaterialPageRoute(
          builder: (context) => VendorDetailScreen(
            manufacturer: manufacturer,
            readOnly: readOnly,
          ),
        ),
      );
    }
  }

  @override
  State<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends State<VendorDetailScreen> {
  @override
  Widget build(BuildContext context) {
    // For web, return minimal widget since modal is handled by showModal
    if (kIsWeb) {
      return const SizedBox.shrink();
    }

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
              title: GradientText(
                  text: S.of(context).manufacturerDetail), // Localized
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
                        color: Theme.of(context).colorScheme.shadow,
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: (widget.readOnly ||
                          !StakeholderPermissions.canManageVendors())
                      ? null
                      : Builder(
                          builder: (context) {
                            final isMobile =
                                MediaQuery.of(context).size.width < 500;
                            if (isMobile) {
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final updatedManufacturer =
                                            await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                VendorEditScreen(
                                              manufacturer: state.manufacturer,
                                            ),
                                          ),
                                        );

                                        if (updatedManufacturer != null) {
                                          final cubit =
                                              context.read<VendorDetailCubit>();
                                          cubit.updateManufacturer(
                                              updatedManufacturer);
                                        }
                                      },
                                      icon: const Icon(Icons.edit,
                                          color: Colors.white),
                                      label: Text(S.of(context).edit,
                                          style: const TextStyle(
                                              color:
                                                  Colors.white)), // Localized
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () {
                                        final cubit =
                                            context.read<VendorDetailCubit>();
                                        showDialog(
                                          context: context,
                                          builder: (dialogContext) =>
                                              AlertDialog(
                                            title: Text(state
                                                        .manufacturer.status ==
                                                    ManufacturerStatus.active
                                                ? S
                                                    .of(context)
                                                    .deactivateManufacturer
                                                : S
                                                    .of(context)
                                                    .activateManufacturer),
                                            content: Text(
                                              state.manufacturer.status ==
                                                      ManufacturerStatus.active
                                                  ? S
                                                      .of(context)
                                                      .deactivateManufacturerConfirm
                                                  : S
                                                      .of(context)
                                                      .activateManufacturerConfirm,
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    dialogContext),
                                                child:
                                                    Text(S.of(context).cancel),
                                              ),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(dialogContext);
                                                  await cubit
                                                      .toggleManufacturerStatus();
                                                  if (mounted) {
                                                    Navigator.pop(context);
                                                  }
                                                },
                                                child: Text(
                                                  state.manufacturer.status ==
                                                          ManufacturerStatus
                                                              .active
                                                      ? S.of(context).inactive
                                                      : S.of(context).activate,
                                                  style: TextStyle(
                                                    color: state.manufacturer
                                                                .status ==
                                                            ManufacturerStatus
                                                                .active
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
                                          state.manufacturer.status ==
                                                  ManufacturerStatus.active
                                              ? Icons.block
                                              : Icons.check_circle,
                                          color: Colors.white),
                                      label: Text(
                                          state.manufacturer.status ==
                                                  ManufacturerStatus.active
                                              ? S.of(context).deactivate
                                              : S.of(context).activate,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            state.manufacturer.status ==
                                                    ManufacturerStatus.active
                                                ? Colors.red
                                                : Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () async {
                                      final updatedManufacturer =
                                          await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              VendorEditScreen(
                                            manufacturer: state.manufacturer,
                                          ),
                                        ),
                                      );

                                      if (updatedManufacturer != null) {
                                        final cubit =
                                            context.read<VendorDetailCubit>();
                                        cubit.updateManufacturer(
                                            updatedManufacturer);
                                      }
                                    },
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    label: Text(S.of(context).edit,
                                        style: const TextStyle(
                                            color: Colors.white)), // Localized
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final cubit =
                                          context.read<VendorDetailCubit>();
                                      showDialog(
                                        context: context,
                                        builder: (dialogContext) => AlertDialog(
                                          title: Text(
                                              state.manufacturer.status ==
                                                      ManufacturerStatus.active
                                                  ? S
                                                      .of(context)
                                                      .deactivateManufacturer
                                                  : S
                                                      .of(context)
                                                      .activateManufacturer),
                                          content: Text(
                                            state.manufacturer.status ==
                                                    ManufacturerStatus.active
                                                ? S
                                                    .of(context)
                                                    .deactivateManufacturerConfirm
                                                : S
                                                    .of(context)
                                                    .activateManufacturerConfirm,
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(dialogContext),
                                              child: Text(S.of(context).cancel),
                                            ),
                                            TextButton(
                                              onPressed: () async {
                                                Navigator.pop(dialogContext);
                                                await cubit
                                                    .toggleManufacturerStatus();
                                                if (mounted) {
                                                  Navigator.pop(context);
                                                }
                                              },
                                              child: Text(
                                                state.manufacturer.status ==
                                                        ManufacturerStatus
                                                            .active
                                                    ? S.of(context).inactive
                                                    : S.of(context).activate,
                                                style: TextStyle(
                                                  color: state.manufacturer
                                                              .status ==
                                                          ManufacturerStatus
                                                              .active
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
                                        state.manufacturer.status ==
                                                ManufacturerStatus.active
                                            ? Icons.block
                                            : Icons.check_circle,
                                        color: Colors.white),
                                    label: Text(
                                        state.manufacturer.status ==
                                                ManufacturerStatus.active
                                            ? S.of(context).deactivate
                                            : S.of(context).activate,
                                        style: const TextStyle(
                                            color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          state.manufacturer.status ==
                                                  ManufacturerStatus.active
                                              ? Colors.red
                                              : Colors.green,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
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
    final isMobile = MediaQuery.of(context).size.width < 500;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.all(Radius.circular(isMobile ? 20 : 30)),
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
            tag: 'vendor_avatar_${state.manufacturer.manufacturerID}',
            child: CircleAvatar(
              radius: isMobile ? 40 : 60,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.business,
                size: isMobile ? 40 : 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            state.manufacturer.manufacturerName,
            style: TextStyle(
              fontSize: isMobile ? 20 : 28,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: isMobile ? 8 : 12),
          _buildStatusBadge(state.manufacturer.status, isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ManufacturerStatus status, {bool isMobile = false}) {
    final isActive = status == ManufacturerStatus.active;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.tertiary
            : Theme.of(context).colorScheme.error,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: isActive
              ? Theme.of(context).colorScheme.tertiary
              : Theme.of(context).colorScheme.error,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: isMobile ? 16 : 20,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Flexible(
            child: Text(
              (status == ManufacturerStatus.active
                      ? S.of(context).active
                      : S.of(context).inactive)
                  .toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 12 : 14,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, VendorDetailState state) {
    final isMobile = MediaQuery.of(context).size.width < 500;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12 : 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: isMobile ? 20 : 24,
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  Flexible(
                    child: Text(
                      S.of(context).manufacturerInformation, // Localized
                      style: TextStyle(
                        fontSize: isMobile ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildInfoRow(
                S.of(context).manufacturerName, // Localized
                state.manufacturer.manufacturerName,
                valueColor: Theme.of(context).colorScheme.onSurface,
                isMobile: isMobile,
              ),
              _buildInfoRow(
                S.of(context).status, // Localized
                state.manufacturer.status == ManufacturerStatus.active
                    ? S.of(context).active
                    : S.of(context).inactive,
                valueColor:
                    state.manufacturer.status == ManufacturerStatus.active
                        ? Theme.of(context).colorScheme.tertiary
                        : Theme.of(context).colorScheme.error,
                icon: state.manufacturer.status == ManufacturerStatus.active
                    ? Icons.check_circle
                    : Icons.cancel,
                isMobile: isMobile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, IconData? icon, bool isMobile = false}) {
    if (isMobile) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: valueColor),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      color:
                          valueColor ?? Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      color:
                          valueColor ?? Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    textAlign: TextAlign.center,
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
