import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/screens/stakeholder/vendors/vendor_add/vendor_add_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/vendors/vendor_detail/vendor_detail_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/vendors/vendor_edit/vendor_edit_view.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/status_badge.dart';
import 'package:gizmoglobe_client/widgets/snackbar/snackbar_service.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';

import '../../../enums/stakeholders/manufacturer_status.dart';
import 'vendors_screen_cubit.dart';
import 'vendors_screen_state.dart';

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

  VendorsScreenCubit get cubit => context.read<VendorsScreenCubit>();

  void _showAddManufacturerModal() async {
    final result = await VendorAddScreen.showModal(context);
    if (result == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SnackbarService.showSuccess(
          context,
          S.of(context).success,
          S.of(context).manufacturerAddedSuccessfully(""),
        );
        cubit.loadManufacturers();
      });
    }
  }

  @override
  void dispose() {
    searchController.dispose();
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
                        hintText: S.of(context).findManufacturers,
                        fillColor: Theme.of(context).colorScheme.surface,
                        onChanged: (value) {
                          cubit.searchManufacturers(value);
                        },
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context).colorScheme.primary),
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
                        return Center(
                          child:
                              Text(S.of(context).noMatchingManufacturersFound),
                        );
                      }

                      return ListView.builder(
                        itemCount: state.manufacturers.length,
                        itemBuilder: (context, index) {
                          final manufacturer = state.manufacturers[index];
                          return GestureDetector(
                            onTap: () {
                              VendorDetailScreen.showModal(
                                context,
                                manufacturer,
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
                                            leading: Icon(
                                              Icons.visibility_outlined,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                            title: Text(
                                              S.of(context).view,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              cubit.setSelectedIndex(null);
                                              VendorDetailScreen.showModal(
                                                context,
                                                manufacturer,
                                                readOnly:
                                                    state.userRole != 'admin',
                                              );
                                            },
                                          ),
                                          if (state.userRole == 'admin') ...[
                                            ListTile(
                                              dense: true,
                                              leading: Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                              ),
                                              title: Text(
                                                S.of(context).edit,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                cubit.setSelectedIndex(null);
                                                final updatedManufacturer =
                                                    await VendorEditScreen
                                                        .showModal(
                                                  context,
                                                  manufacturer,
                                                );

                                                if (updatedManufacturer != null) {
                                                  try {
                                                    await cubit.updateManufacturer(updatedManufacturer);
                                                    if (mounted) {
                                                      WidgetsBinding.instance.addPostFrameCallback((_) {
                                                        if (!mounted) return;
                                                        SnackbarService.showSuccess(
                                                          context,
                                                        S.of(context).success,
                                                        "Manufacturer updated successfully.",
                                                        );
                                                      });
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) => InformationDialog(
                                                          title: S.of(context).failure,
                                                          content: e.toString(),
                                                          buttonText: 'OK',
                                                        ),
                                                  );
                                                    }
                                                  }
                                                }
                                              },
                                            ),
                                            ListTile(
                                              dense: true,
                                              leading: Icon(
                                                manufacturer.status ==
                                                        ManufacturerStatus
                                                            .active
                                                    ? Icons.cancel_outlined
                                                    : Icons
                                                        .check_circle_outline,
                                                size: 20,
                                                color: manufacturer.status ==
                                                        ManufacturerStatus
                                                            .active
                                                    ? Theme.of(context)
                                                        .colorScheme
                                                        .error
                                                    : Colors.green,
                                              ),
                                              title: Text(
                                                manufacturer.status ==
                                                        ManufacturerStatus
                                                            .active
                                                    ? S.of(context).deactivate
                                                    : S.of(context).activate,
                                                style: TextStyle(
                                                  color: manufacturer.status ==
                                                          ManufacturerStatus
                                                              .active
                                                      ? Theme.of(context)
                                                          .colorScheme
                                                          .error
                                                      : Colors.green,
                                                ),
                                              ),
                                              onTap: () {
                                                Navigator.pop(context);
                                                cubit.setSelectedIndex(null);
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: Text(manufacturer
                                                                  .status ==
                                                              ManufacturerStatus
                                                                  .active
                                                          ? S
                                                              .of(context)
                                                              .deactivateManufacturer
                                                          : S
                                                              .of(context)
                                                              .activateManufacturer),
                                                      content: Text(manufacturer
                                                                  .status ==
                                                              ManufacturerStatus
                                                                  .active
                                                          ? S
                                                              .of(context)
                                                              .deactivateManufacturerConfirmName(
                                                                  manufacturer
                                                                      .manufacturerName)
                                                          : S
                                                              .of(context)
                                                              .activateManufacturerConfirmName(
                                                                  manufacturer
                                                                      .manufacturerName)),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  context),
                                                          child: Text(
                                                            S
                                                                .of(context)
                                                                .cancel,
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () async {
                                                            Navigator.pop(context);
                                                            try {
                                                              await cubit.toggleManufacturerStatus(manufacturer);
                                                              if (mounted) {
                                                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                                                  if (!mounted) return;
                                                                  SnackbarService.showSuccess(
                                                                    context,
                                                                    S.of(context).success,
                                                                    manufacturer.status == ManufacturerStatus.active
                                                                        ? S.of(context).deactivate
                                                                        : S.of(context).activate,
                                                                  );
                                                                });
                                                              }
                                                            } catch (e) {
                                                              if (mounted) {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (context) => InformationDialog(
                                                                    title: S.of(context).failure,
                                                                    content: e.toString(),
                                                                    buttonText: 'OK',
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          child: Text(
                                                            manufacturer.status ==
                                                                    ManufacturerStatus
                                                                        .active
                                                                ? S
                                                                    .of(context)
                                                                    .deactivate
                                                                : S
                                                                    .of(context)
                                                                    .activate,
                                                            style: TextStyle(
                                                              color: manufacturer
                                                                          .status ==
                                                                      ManufacturerStatus
                                                                          .active
                                                                  ? Theme.of(
                                                                          context)
                                                                      .colorScheme
                                                                      .error
                                                                  : Colors
                                                                      .green,
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
                              opacity: state.selectedIndex == null ||
                                      state.selectedIndex == index
                                  ? 1.0
                                  : 0.3,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: state.selectedIndex == index
                                      ? Theme.of(context)
                                          .primaryColor
                                          .withValues(alpha: 0.1)
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
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        child: Icon(
                                          Icons.business_center,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
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
                                      StatusBadge(
                                        status: manufacturer.status ==
                                                ManufacturerStatus.active
                                            ? S.of(context).active
                                            : S.of(context).inactive,
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

  // Removed custom snackbar in favor of SnackbarService
}
