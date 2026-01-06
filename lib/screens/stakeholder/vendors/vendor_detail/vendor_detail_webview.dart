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
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final containerWidth = isMobile
            ? screenWidth - 16 // 8px margin on each side
            : screenWidth * 0.6;

        return Container(
          width: isMobile ? containerWidth : containerWidth.clamp(400.0, 800.0),
          constraints: BoxConstraints(
            maxWidth: isMobile ? screenWidth : 800,
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
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 16),
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
                      size: isMobile ? 20 : 28,
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    Expanded(
                      child:
                          GradientText(text: S.of(context).manufacturerDetail),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      icon: Icon(Icons.close, size: isMobile ? 20 : 24),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.all(isMobile ? 8 : 12),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Flexible(
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
                    ? Builder(
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
                                          await VendorEditScreen.showModal(
                                        context,
                                        state.manufacturer,
                                      );

                                      if (updatedManufacturer != null) {
                                        cubit.updateManufacturer(
                                            updatedManufacturer);
                                        Navigator.of(context)
                                            .pop(updatedManufacturer);
                                      }
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    label: Text(S.of(context).edit,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        )),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .tertiary,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _handleStatusToggle(context, state),
                                    icon: Icon(
                                      state.manufacturer.status ==
                                              ManufacturerStatus.active
                                          ? Icons.block
                                          : Icons.check_circle,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    label: Text(
                                      state.manufacturer.status ==
                                              ManufacturerStatus.active
                                          ? S.of(context).deactivate
                                          : S.of(context).activate,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: state
                                                  .manufacturer.status ==
                                              ManufacturerStatus.active
                                          ? Theme.of(context).colorScheme.error
                                          : Theme.of(context)
                                              .colorScheme
                                              .tertiary,
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
                                        await VendorEditScreen.showModal(
                                      context,
                                      state.manufacturer,
                                    );

                                    if (updatedManufacturer != null) {
                                      cubit.updateManufacturer(
                                          updatedManufacturer);
                                      Navigator.of(context)
                                          .pop(updatedManufacturer);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  label: Text(S.of(context).edit,
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      )),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.tertiary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
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
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  label: Text(
                                    state.manufacturer.status ==
                                            ManufacturerStatus.active
                                        ? S.of(context).deactivate
                                        : S.of(context).activate,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: state
                                                .manufacturer.status ==
                                            ManufacturerStatus.active
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context)
                                            .colorScheme
                                            .tertiary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
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
    final isMobile = MediaQuery.of(context).size.width < 500;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 12 : 16),
      margin: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 12),
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
              color: Colors.white,
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
        horizontal: isMobile ? 10 : 12,
        vertical: isMobile ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            size: isMobile ? 14 : 16,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          SizedBox(width: isMobile ? 4 : 6),
          Flexible(
            child: Text(
              (status == ManufacturerStatus.active
                      ? S.of(context).active
                      : S.of(context).inactive)
                  .toUpperCase(),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: isMobile ? 10 : 12,
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
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        ),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 10 : 12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: isMobile ? 18 : 24,
                  ),
                  SizedBox(width: isMobile ? 6 : 8),
                  Flexible(
                    child: Text(
                      S.of(context).manufacturerInformation,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 18,
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
                S.of(context).manufacturerName,
                state.manufacturer.manufacturerName,
                isMobile: isMobile,
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
                color: Theme.of(context).colorScheme.secondary,
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
                    textAlign: TextAlign.end,
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
                            ? S.of(context).manufacturerDeactivatedSuccessfully
                            : S.of(context).manufacturerActivatedSuccessfully,
                    contentType: ContentType.success,
                  );

                  // Small delay to show snackbar before closing
                  await Future.delayed(const Duration(milliseconds: 100));

                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  _showErrorDialog(S
                      .of(context)
                      .failedToToggleManufacturerStatus(e.toString()));
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
