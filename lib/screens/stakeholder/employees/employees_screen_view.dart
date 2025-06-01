import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';

import 'employee_detail/employee_detail_view.dart';
import 'employee_edit/employee_edit_view.dart';
import 'employees_screen_cubit.dart';
import 'employees_screen_state.dart';
import 'permissions/employee_permissions.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => EmployeesScreenCubit(),
        child: const EmployeesScreen(),
      );

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final TextEditingController searchController = TextEditingController();
  EmployeesScreenCubit get cubit => context.read<EmployeesScreenCubit>();

  void _showAddEmployeeDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    // final passwordController = TextEditingController();
    RoleEnum selectedRole = RoleEnum.employee;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_add,
                            color: Theme.of(context).colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            S.of(context).addNewEmployee,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).pleaseEnterName;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: S.of(context).name,
                          hintText: S.of(context).fullName,
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: Theme.of(context).primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade600),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade600),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.8),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          floatingLabelStyle: WidgetStateTextStyle.resolveWith(
                            (states) => TextStyle(
                              color: states.contains(WidgetState.focused)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                            ),
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.white70,
                          ),
                          errorStyle: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: emailController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return S.of(context).pleaseEnterEmail;
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: S.of(context).email,
                          hintText: S.of(context).email,
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade600),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade600),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.8),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          floatingLabelStyle: WidgetStateTextStyle.resolveWith(
                            (states) => TextStyle(
                              color: states.contains(WidgetState.focused)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                            ),
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.white70,
                          ),
                          errorStyle: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: S.of(context).phoneNumber,
                          hintText: S.of(context).enterPhoneNumber,
                          prefixIcon: Icon(
                            Icons.phone_outlined,
                            color: Theme.of(context).primaryColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade600),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade600),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          filled: true,
                          fillColor: Theme.of(context)
                              .colorScheme
                              .surface
                              .withValues(alpha: 0.8),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                          ),
                          floatingLabelStyle: WidgetStateTextStyle.resolveWith(
                            (states) => TextStyle(
                              color: states.contains(WidgetState.focused)
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.white,
                            ),
                          ),
                          hintStyle: const TextStyle(
                            color: Colors.white70,
                          ),
                          errorStyle: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      StatefulBuilder(
                        builder: (context, setState) {
                          return DropdownButtonFormField<RoleEnum>(
                            value: selectedRole,
                            decoration: InputDecoration(
                              labelText: S.of(context).role,
                              prefixIcon: Icon(
                                Icons.work_outline,
                                color: Theme.of(context).primaryColor,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade600),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade600),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              filled: true,
                              fillColor: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.8),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                              ),
                              floatingLabelStyle:
                                  WidgetStateTextStyle.resolveWith(
                                (states) => TextStyle(
                                  color: states.contains(WidgetState.focused)
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.white,
                                ),
                              ),
                            ),
                            items: RoleEnum.values
                                .where((role) => role != RoleEnum.owner)
                                .map((role) {
                              return DropdownMenuItem(
                                value: role,
                                child: Text(
                                  role.toString().split('.').last,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (RoleEnum? value) {
                              if (value != null) {
                                setState(() => selectedRole = value);
                              }
                            },
                            dropdownColor:
                                Theme.of(context).colorScheme.surface,
                            icon: const Icon(Icons.arrow_drop_down,
                                color: Colors.white),
                            style: const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              S.of(context).cancel,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState?.validate() ?? false) {
                                final error = await cubit.createEmployee(
                                  nameController.text,
                                  emailController.text,
                                  phoneController.text,
                                  selectedRole,
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
                                      SnackBar(
                                        content: Text(S
                                            .of(context)
                                            .employeeAddedSuccessfully),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Add Employee',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        S.of(context).filterByRole,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...RoleEnum.values.map((role) => ListTile(
                        title: Text(
                          role.toString().split('.').last,
                          style: const TextStyle(color: Colors.white),
                        ),
                        leading: Icon(
                          Icons.work_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        onTap: () {
                          cubit.filterByRole(role);
                          Navigator.pop(context);
                        },
                      )),
                  ListTile(
                    title: Text(
                      S.of(context).clearFilter,
                      style: const TextStyle(color: Colors.white),
                    ),
                    leading: Icon(
                      Icons.clear,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () {
                      cubit.filterByRole(null);
                      Navigator.pop(context);
                    },
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
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeesScreenCubit, EmployeesScreenState>(
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
                        hintText: S.of(context).findEmployees,
                        fillColor: Theme.of(context).colorScheme.surface,
                        onChanged: (value) {
                          cubit.searchEmployees(value);
                        },
                        prefixIcon: Icon(Icons.search,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.filter_list,
                      iconSize: 32,
                      onPressed: _showFilterDialog,
                    ),
                    if (EmployeePermissions.canAddEmployees(
                        state.userRole)) ...[
                      const SizedBox(width: 8),
                      GradientIconButton(
                        icon: Icons.person_add,
                        iconSize: 32,
                        onPressed: _showAddEmployeeDialog,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child:
                      BlocBuilder<EmployeesScreenCubit, EmployeesScreenState>(
                    builder: (context, state) {
                      if (state.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state.employees.isEmpty) {
                        return Center(
                          child: Text(
                            S.of(context).noEmployeesFound,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.employees.length,
                        itemBuilder: (context, index) {
                          final employee = state.employees[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmployeeDetailScreen(
                                    employee: employee,
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
                                            title: Text(
                                              S.of(context).view,
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            onTap: () {
                                              Navigator.pop(context);
                                              cubit.setSelectedIndex(null);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      EmployeeDetailScreen(
                                                    employee: employee,
                                                    readOnly:
                                                        !EmployeePermissions
                                                            .canEditEmployee(
                                                                state.userRole,
                                                                employee),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          if (EmployeePermissions
                                              .canEditEmployee(state.userRole,
                                                  employee)) ...[
                                            ListTile(
                                              dense: true,
                                              leading: const Icon(
                                                Icons.edit_outlined,
                                                size: 20,
                                                color: Colors.white,
                                              ),
                                              title: Text(
                                                S.of(context).edit,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              onTap: () async {
                                                Navigator.pop(context);
                                                cubit.setSelectedIndex(null);
                                                final updatedEmployee =
                                                    await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EmployeeEditScreen(
                                                      employee: employee,
                                                      userRole: state.userRole,
                                                    ),
                                                  ),
                                                );

                                                if (updatedEmployee != null) {
                                                  await cubit.updateEmployee(
                                                      updatedEmployee);
                                                }
                                              },
                                            ),
                                          ],
                                          if (EmployeePermissions
                                              .canDeleteEmployee(state.userRole,
                                                  employee)) ...[
                                            ListTile(
                                              dense: true,
                                              leading: Icon(
                                                Icons.delete_outlined,
                                                size: 20,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                              ),
                                              title: Text(
                                                S.of(context).delete,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error,
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
                                                      title: Text(
                                                        S
                                                            .of(context)
                                                            .deleteEmployee,
                                                      ),
                                                      content: Text(
                                                        S
                                                            .of(context)
                                                            .areYouSureDeleteEmployee,
                                                      ),
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
                                                            Navigator.pop(
                                                                context);
                                                            await cubit
                                                                .deleteEmployee(
                                                                    employee
                                                                        .employeeID!);
                                                          },
                                                          child: Text(
                                                            S
                                                                .of(context)
                                                                .delete,
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .error,
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
                                          Icons.person,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          employee.employeeName,
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
