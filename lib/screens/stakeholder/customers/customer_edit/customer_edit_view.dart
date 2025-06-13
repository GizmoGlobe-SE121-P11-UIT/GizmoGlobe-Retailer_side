import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (_isFormDirty && !didPop) {
          final shouldPop = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(S.of(context).discardChanges),
              content: Text(S.of(context).unsavedChangesDiscard),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(S.of(context).cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(S.of(context).discard),
                ),
              ],
            ),
          );
          if (shouldPop == true) {
            Navigator.of(context).maybePop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: GradientText(text: S.of(context).editCustomer),
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
                          Text(
                            S.of(context).customerInformation,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            focusNode: _nameFocusNode,
                            initialValue: customerName,
                            decoration: InputDecoration(
                              labelText: S.of(context).fullName,
                              labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              floatingLabelStyle:
                                  WidgetStateTextStyle.resolveWith(
                                (states) => TextStyle(
                                  color: states.contains(WidgetState.focused)
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              prefixIcon: Icon(Icons.person,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) => setState(() {
                              customerName = value;
                              _isFormDirty = true;
                            }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).nameIsRequired;
                              }
                              if (value.length < 2) {
                                return S.of(context).nameMin2Chars;
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
                                      Theme.of(context).colorScheme.onSurface),
                              floatingLabelStyle:
                                  WidgetStateTextStyle.resolveWith(
                                (states) => TextStyle(
                                  color: states.contains(WidgetState.focused)
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              prefixIcon: Icon(Icons.phone,
                                  color:
                                      Theme.of(context).colorScheme.onSurface),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              hintText: '+84 xxx xxx xxx',
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[\d\s+-]')),
                            ],
                            onChanged: (value) => setState(() {
                              phoneNumber = value;
                              _isFormDirty = true;
                            }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return S.of(context).phoneNumberIsRequired;
                              }
                              if (!isValidPhone(value)) {
                                return S
                                    .of(context)
                                    .pleaseEnterValidPhoneNumber;
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
