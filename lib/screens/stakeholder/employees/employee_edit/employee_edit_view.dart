import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:gizmoglobe_client/objects/employee.dart';

import '../../../../widgets/general/gradient_icon_button.dart';
import '../../../../widgets/general/gradient_text.dart';
import '../../../../screens/stakeholder/employees/permissions/employee_permissions.dart';

class EmployeeEditScreen extends StatefulWidget {
  final Employee employee;
  final String? userRole;

  const EmployeeEditScreen({
    super.key, 
    required this.employee,
    required this.userRole,
  });

  @override
  State<EmployeeEditScreen> createState() => _EmployeeEditScreenState();
}

class _EmployeeEditScreenState extends State<EmployeeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late String employeeName;
  late String phoneNumber;
  late RoleEnum role;

  @override
  void initState() {
    super.initState();
    employeeName = widget.employee.employeeName;
    phoneNumber = widget.employee.phoneNumber;
    role = widget.employee.role as RoleEnum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GradientText(text: 'Edit Employee'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: GradientIconButton(
          icon: Icons.chevron_left,
          onPressed: () => Navigator.pop(context),
          fillColor: Colors.transparent,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GradientIconButton(
              icon: Icons.check,
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final updatedEmployee = widget.employee.copyWith(
                    employeeName: employeeName,
                    phoneNumber: phoneNumber,
                    role: role,
                  );
                  Navigator.pop(context, updatedEmployee);
                }
              },
              fillColor: Colors.transparent,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Employee Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          initialValue: employeeName,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: const TextStyle(color: Colors.white),
                            floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                              (states) => TextStyle(
                                color: states.contains(MaterialState.focused)
                                    ? Theme.of(context).primaryColor
                                    : Colors.white,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.person, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                          ),
                          onChanged: (value) => employeeName = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: phoneNumber,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: const TextStyle(color: Colors.white),
                            floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                              (states) => TextStyle(
                                color: states.contains(MaterialState.focused)
                                    ? Theme.of(context).primaryColor
                                    : Colors.white,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.phone, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            hintText: '+84 xxx xxx xxx',
                          ),
                          onChanged: (value) => phoneNumber = value,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<RoleEnum>(
                          value: role,
                          decoration: InputDecoration(
                            labelText: 'Role',
                            labelStyle: const TextStyle(color: Colors.white),
                            floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                              (states) => TextStyle(
                                color: states.contains(MaterialState.focused)
                                    ? Theme.of(context).primaryColor
                                    : Colors.white,
                              ),
                            ),
                            prefixIcon: const Icon(Icons.work, color: Colors.white),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Theme.of(context).primaryColor),
                            ),
                            enabled: EmployeePermissions.canEditEmployeeRole(widget.userRole, widget.employee),
                          ),
                          dropdownColor: Theme.of(context).cardColor,
                          items: RoleEnum.values.where((role) => role != RoleEnum.owner).map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(
                                role.toString().split('.').last,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontStyle: EmployeePermissions.canEditEmployeeRole(widget.userRole, widget.employee)
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: EmployeePermissions.canEditEmployeeRole(widget.userRole, widget.employee)
                              ? (RoleEnum? value) {
                                  if (value != null) {
                                    setState(() => role = value);
                                  }
                                }
                              : null,
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a role';
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
    );
  }
} 