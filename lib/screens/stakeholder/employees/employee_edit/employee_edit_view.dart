import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:gizmoglobe_client/objects/employee.dart';

import '../../../../widgets/general/gradient_icon_button.dart';
import '../../../../widgets/general/gradient_text.dart';

class EmployeeEditScreen extends StatefulWidget {
  final Employee employee;

  const EmployeeEditScreen({super.key, required this.employee});

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
        elevation: 2,
        automaticallyImplyLeading: false,
        leading: GradientIconButton(
          icon: Icons.chevron_left,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
                  initialValue: employeeName,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: const TextStyle(color: Colors.white),
                    floatingLabelStyle: MaterialStateTextStyle.resolveWith(
                      (states) => TextStyle(
                        color: states.contains(MaterialState.focused)
                            ? Theme.of(context).primaryColor
                            : Colors.white,
                      ),
                    ),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => employeeName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              ),              
              const SizedBox(height: 16),
              Container(
                  margin: const EdgeInsets.only(bottom: 20),
                child: TextFormField(
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
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => phoneNumber = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a phone number';
                    }
                    return null;
                  },
                ),
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
                  border: OutlineInputBorder(),
                ),
                items: RoleEnum.values.where((role) => role != RoleEnum.owner).map((RoleEnum roleEnum) {
                  return DropdownMenuItem<RoleEnum>(
                    value: roleEnum,
                    child: Text(
                      roleEnum.toString().split('.').last,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (RoleEnum? newValue) {
                  if (newValue != null) {
                    setState(() {
                      role = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a role';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 