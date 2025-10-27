import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/employee.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../permissions/employee_permissions.dart';

class EmployeeEditWebView extends StatefulWidget {
  final Employee employee;
  final String? userRole;

  const EmployeeEditWebView({
    super.key,
    required this.employee,
    required this.userRole,
  });

  static Widget newInstance({
    required Employee employee,
    required String? userRole,
  }) =>
      EmployeeEditWebView(
        employee: employee,
        userRole: userRole,
      );

  @override
  State<EmployeeEditWebView> createState() => _EmployeeEditWebViewState();
}

class _EmployeeEditWebViewState extends State<EmployeeEditWebView> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  late String employeeName;
  late String phoneNumber;
  late RoleEnum role;

  @override
  void initState() {
    super.initState();
    employeeName = widget.employee.employeeName;
    phoneNumber = widget.employee.phoneNumber;
    role = widget.employee.role;
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.35,
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
          // Header with close and save buttons
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GradientText(text: S.of(context).editEmployee),
                ),
                IconButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final updatedEmployee = widget.employee.copyWith(
                          employeeName: employeeName.trim(),
                          phoneNumber: phoneNumber.trim(),
                          role: role,
                        );

                        // Show success snackbar before closing
                        _showSnackBar(
                          title: S.of(context).success,
                          message: "Employee updated successfully.",
                          contentType: ContentType.success,
                        );

                        // Small delay to show snackbar before closing
                        await Future.delayed(const Duration(milliseconds: 100));

                        if (mounted) {
                          Navigator.of(context).pop(updatedEmployee);
                        }
                      } catch (e) {
                        if (mounted) {
                          _showErrorDialog(
                              "Failed to update employee: ${e.toString()}");
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.check),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 4),
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
              padding: const EdgeInsets.all(8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Employee Information Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              focusNode: _nameFocusNode,
                              initialValue: employeeName,
                              decoration: InputDecoration(
                                labelText: S.of(context).fullName,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                floatingLabelStyle:
                                    WidgetStateTextStyle.resolveWith(
                                  (states) => TextStyle(
                                    color: states.contains(WidgetState.focused)
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              textInputAction: TextInputAction.next,
                              onChanged: (value) {
                                if (mounted) {
                                  setState(() {
                                    employeeName = value;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return S.of(context).pleaseEnterName;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              focusNode: _phoneFocusNode,
                              initialValue: phoneNumber,
                              decoration: InputDecoration(
                                labelText: S.of(context).phoneNumber,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                floatingLabelStyle:
                                    WidgetStateTextStyle.resolveWith(
                                  (states) => TextStyle(
                                    color: states.contains(WidgetState.focused)
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.phone,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                hintText: '+84 xxx xxx xxx',
                              ),
                              keyboardType: TextInputType.phone,
                              onChanged: (value) {
                                if (mounted) {
                                  setState(() {
                                    phoneNumber = value;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return S.of(context).pleaseEnterPhoneNumber;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<RoleEnum>(
                              value: role,
                              decoration: InputDecoration(
                                labelText: S.of(context).role,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                floatingLabelStyle:
                                    WidgetStateTextStyle.resolveWith(
                                  (states) => TextStyle(
                                    color: states.contains(WidgetState.focused)
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.work,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                enabled:
                                    EmployeePermissions.canEditEmployeeRole(
                                        widget.userRole, widget.employee),
                              ),
                              dropdownColor: Theme.of(context).cardColor,
                              items: RoleEnum.values
                                  .where((role) => role != RoleEnum.owner)
                                  .map((role) {
                                return DropdownMenuItem(
                                  value: role,
                                  child: Text(
                                    role.localizedName(context),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontStyle: EmployeePermissions
                                              .canEditEmployeeRole(
                                                  widget.userRole,
                                                  widget.employee)
                                          ? FontStyle.normal
                                          : FontStyle.italic,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged:
                                  EmployeePermissions.canEditEmployeeRole(
                                          widget.userRole, widget.employee)
                                      ? (RoleEnum? value) {
                                          if (value != null && mounted) {
                                            setState(() => role = value);
                                          }
                                        }
                                      : null,
                              validator: (value) {
                                if (value == null) {
                                  return S.of(context).pleaseSelectRole;
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
      builder: (context) => InformationDialog(
        title: S.of(context).errorOccurred,
        content: errorMessage,
        buttonText: S.of(context).confirm,
      ),
    );
  }
}
