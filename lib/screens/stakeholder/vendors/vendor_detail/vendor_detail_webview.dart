import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../../../../enums/stakeholders/manufacturer_status.dart';
import '../../permissions/stakeholder_permissions.dart';
import '../vendor_edit/vendor_edit_view.dart';
import 'vendor_detail_cubit.dart';
import 'vendor_detail_state.dart';

class VendorDetailWebView extends StatefulWidget {
  final Manufacturer manufacturer;
  final bool readOnly;

  const VendorDetailWebView({
    super.key,
    required this.manufacturer,
    this.readOnly = false,
  });

  static Widget newInstance({
    required Manufacturer manufacturer,
    bool readOnly = false,
  }) =>
      BlocProvider(
        create: (context) => VendorDetailCubit(manufacturer),
        child: VendorDetailWebView(
          manufacturer: manufacturer,
          readOnly: readOnly,
        ),
      );

  @override
  State<VendorDetailWebView> createState() => _VendorDetailWebViewState();
}

class _VendorDetailWebViewState extends State<VendorDetailWebView> {
  VendorDetailCubit get cubit => context.read<VendorDetailCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorDetailCubit, VendorDetailState>(
      builder: (context, state) {
        return Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.7,
          constraints: const BoxConstraints(
            maxWidth: 800,
            maxHeight: 600,
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
                      Icons.business,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child:
                          GradientText(text: S.of(context).manufacturerDetail),
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
                child: !widget.readOnly &&
                        StakeholderPermissions.canManageVendors()
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final updatedManufacturer =
                                    await VendorEditScreen.showModal(
                                  context,
                                  state.manufacturer,
                                );

                                if (updatedManufacturer != null) {
                                  cubit.updateManufacturer(updatedManufacturer);
                                  Navigator.of(context)
                                      .pop(updatedManufacturer);
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () =>
                                  _handleStatusToggle(context, state),
                              icon: Icon(
                                state.manufacturer.status ==
                                        ManufacturerStatus.active
                                    ? Icons.block
                                    : Icons.check_circle,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                state.manufacturer.status ==
                                        ManufacturerStatus.active
                                    ? S.of(context).deactivate
                                    : S.of(context).activate,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: state.manufacturer.status ==
                                        ManufacturerStatus.active
                                    ? Theme.of(context).colorScheme.error
                                    : Theme.of(context).colorScheme.tertiary,
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

  Widget _buildHeaderSection(BuildContext context, VendorDetailState state) {
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
          const SizedBox(height: 8),
          _buildStatusBadge(state.manufacturer.status),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ManufacturerStatus status) {
    final isActive = status == ManufacturerStatus.active;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          const SizedBox(width: 4),
          Text(
            (status == ManufacturerStatus.active
                    ? S.of(context).active
                    : S.of(context).inactive)
                .toUpperCase(),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, VendorDetailState state) {
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
                  ),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).manufacturerInformation,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                S.of(context).manufacturerName,
                state.manufacturer.manufacturerName,
              ),
              _buildInfoRow(
                S.of(context).status,
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, IconData? icon}) {
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: valueColor),
                  const SizedBox(width: 4),
                ],
                Text(
                  value,
                  style: TextStyle(
                    color:
                        valueColor ?? Theme.of(context).colorScheme.onSurface,
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

  void _handleStatusToggle(BuildContext context, VendorDetailState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(state.manufacturer.status == ManufacturerStatus.active
            ? S.of(context).deactivateManufacturer
            : S.of(context).activateManufacturer),
        content: Text(
          state.manufacturer.status == ManufacturerStatus.active
              ? S.of(context).deactivateManufacturerConfirm
              : S.of(context).activateManufacturerConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await cubit.toggleManufacturerStatus();
                if (mounted) {
                  // Show success snackbar before closing
                  _showSnackBar(
                    title: S.of(context).success,
                    message:
                        state.manufacturer.status == ManufacturerStatus.active
                            ? "Manufacturer deactivated successfully."
                            : "Manufacturer activated successfully.",
                    contentType: ContentType.success,
                  );

                  // Small delay to show snackbar before closing
                  await Future.delayed(const Duration(milliseconds: 100));

                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  _showErrorDialog(
                      "Failed to toggle manufacturer status: ${e.toString()}");
                }
              }
            },
            child: Text(
              state.manufacturer.status == ManufacturerStatus.active
                  ? S.of(context).inactive
                  : S.of(context).activate,
              style: TextStyle(
                color: state.manufacturer.status == ManufacturerStatus.active
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.tertiary,
              ),
            ),
          ),
        ],
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
