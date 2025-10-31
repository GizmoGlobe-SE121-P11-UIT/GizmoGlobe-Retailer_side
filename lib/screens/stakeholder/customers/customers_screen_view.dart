import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/snackbar/snackbar_service.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';

import 'customer_add/customer_add_view.dart';
import 'customer_detail/customer_detail_view.dart';
import 'customer_edit/customer_edit_view.dart';
import 'customers_screen_cubit.dart';
import 'customers_screen_state.dart';
import 'permissions/customer_permissions.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => CustomersScreenCubit(),
        child: const CustomersScreen(),
      );

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController searchController = TextEditingController();

  CustomersScreenCubit get cubit => context.read<CustomersScreenCubit>();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomersScreenCubit, CustomersScreenState>(
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
                        hintText: S.of(context).findCustomers,
                        fillColor: Theme.of(context).colorScheme.surface,
                        onChanged: (value) {
                          cubit.searchCustomers(value);
                        },
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context).colorScheme.primary),
                      ),
                    ),
                    if (CustomerPermissions.canAddCustomers(
                        state.userRole)) ...[
                      const SizedBox(width: 8),
                      GradientIconButton(
                        icon: Icons.person_add,
                        iconSize: 32,
                        onPressed: () async {
                          final result =
                              await CustomerAddScreen.showModal(context);
                          if (result == true && mounted) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (!mounted) return;
                              SnackbarService.showSuccess(
                                context,
                                S.of(context).success,
                                S.of(context).customerAddedSuccessfully,
                              );
                              cubit.loadCustomers();
                            });
                          }
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      BlocBuilder<CustomersScreenCubit, CustomersScreenState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.customers.isEmpty) {
                        return Center(
                          child: Text(S.of(context).noMatchingCustomersFound),
                        );
                      }

                      return ListView.builder(
                        itemCount: state.customers.length,
                        itemBuilder: (context, index) {
                          final customer = state.customers[index];
                          // final isSelected = state.selectedIndex == index;

                          return GestureDetector(
                            onTap: () async {
                              final result =
                                  await CustomerDetailScreen.showModal(
                                context,
                                customer,
                                readOnly: !CustomerPermissions.canEditCustomers(
                                    state.userRole),
                              );
                              if (result == true && mounted) {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  if (!mounted) return;
                                  SnackbarService.showSuccess(
                                    context,
                                    S.of(context).success,
                                    S.of(context).updateProfileSuccess,
                                  );
                                });
                              }
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
                                            title: Text(S.of(context).view),
                                            onTap: () async {
                                              Navigator.pop(context);
                                              cubit.setSelectedIndex(null);
                                              await CustomerDetailScreen
                                                  .showModal(
                                                context,
                                                customer,
                                                readOnly: !CustomerPermissions
                                                    .canEditCustomers(
                                                        state.userRole),
                                              );
                                            },
                                          ),
                                          if (CustomerPermissions
                                              .canEditCustomers(
                                                  state.userRole)) ...[
                                            ListTile(
                                              dense: true,
                                              leading: const Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                              title: Text(S.of(context).edit),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                cubit.setSelectedIndex(null);
                                                final updatedCustomer =
                                                    await CustomerEditScreen
                                                        .showModal(
                                                  context,
                                                  customer,
                                                );

                                                if (updatedCustomer != null) {
                                                  try {
                                                    await cubit.updateCustomer(
                                                        updatedCustomer);
                                                    if (mounted) {
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        if (!mounted) return;
                                                        SnackbarService
                                                            .showSuccess(
                                                          context,
                                                          S.of(context).success,
                                                          S
                                                              .of(context)
                                                              .updateProfileSuccess,
                                                        );
                                                      });
                                                    }
                                                  } catch (e) {
                                                    if (mounted) {
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) =>
                                                            InformationDialog(
                                                          title: S
                                                              .of(context)
                                                              .failure,
                                                          content: e.toString(),
                                                          buttonText: 'OK',
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              },
                                            )
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
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.1)
                                      : Theme.of(context).colorScheme.surface,
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
                                          Icons.person,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          customer.customerName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
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
