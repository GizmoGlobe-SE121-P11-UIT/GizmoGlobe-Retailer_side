import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gizmoglobe_client/objects/customer.dart';

import '../../../../widgets/general/gradient_icon_button.dart';
import '../../../../widgets/general/gradient_text.dart';

class CustomerEditScreen extends StatefulWidget {
  final Customer customer;

  const CustomerEditScreen({super.key, required this.customer});

  @override
  State<CustomerEditScreen> createState() => _CustomerEditScreenState();
}

class _CustomerEditScreenState extends State<CustomerEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  late String customerName;
  late String phoneNumber;
  bool _isFormDirty = false;

  @override
  void initState() {
    super.initState();
    customerName = widget.customer.customerName;
    phoneNumber = widget.customer.phoneNumber;
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^\+?[\d\s-]{10,}$').hasMatch(phone);
  }

  Future<bool> _onWillPop() async {
    if (!_isFormDirty) return true;

    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Do you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DISCARD'),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: GradientText(text: 'Edit Customer'),
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
                    final updatedCustomer = widget.customer.copyWith(
                      customerName: customerName.trim(),
                      phoneNumber: phoneNumber.trim(),
                    );
                    Navigator.pop(context, updatedCustomer);
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
              onChanged: () => setState(() => _isFormDirty = true),
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
                            'Customer Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            focusNode: _nameFocusNode,
                            initialValue: customerName,
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
                            textInputAction: TextInputAction.next,
                            onChanged: (value) => setState(() {
                              customerName = value;
                              _isFormDirty = true;
                            }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name is required';
                              }
                              if (value.length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            focusNode: _phoneFocusNode,
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
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[\d\s+-]')),
                            ],
                            onChanged: (value) => setState(() {
                              phoneNumber = value;
                              _isFormDirty = true;
                            }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Phone number is required';
                              }
                              if (!isValidPhone(value)) {
                                return 'Please enter a valid phone number';
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
      ),
    );
  }
}