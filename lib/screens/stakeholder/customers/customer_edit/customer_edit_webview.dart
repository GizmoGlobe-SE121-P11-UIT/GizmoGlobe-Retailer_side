import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

class CustomerEditWebView extends StatefulWidget {
  final Customer customer;

  const CustomerEditWebView({
    super.key,
    required this.customer,
  });

  static Widget newInstance(Customer customer) => CustomerEditWebView(
        customer: customer,
      );

  @override
  State<CustomerEditWebView> createState() => _CustomerEditWebViewState();
}

class _CustomerEditWebViewState extends State<CustomerEditWebView> {
  final _formKey = GlobalKey<FormState>();
  final _nameFocusNode = FocusNode();
  final _phoneFocusNode = FocusNode();

  late String customerName;
  late String phoneNumber;

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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final containerWidth = isMobile ? screenWidth * 0.95 : screenWidth * 0.35;

    return Container(
      width: containerWidth.clamp(320.0, 450.0),
      constraints: const BoxConstraints(
        maxWidth: 500,
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
                  child: GradientText(text: S.of(context).editCustomer),
                ),
                IconButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final updatedCustomer = widget.customer.copyWith(
                          customerName: customerName.trim(),
                          phoneNumber: phoneNumber.trim(),
                        );

                        // Show success snackbar before closing
                        _showSnackBar(
                          title: S.of(context).success,
                          message: S.of(context).updateProfileSuccess,
                          contentType: ContentType.success,
                        );

                        // Small delay to show snackbar before closing
                        await Future.delayed(const Duration(milliseconds: 100));

                        if (mounted) {
                          Navigator.of(context).pop(updatedCustomer);
                        }
                      } catch (e) {
                        if (mounted) {
                          _showErrorDialog(
                              S.of(context).failedToUpdateCustomer(e.toString()));
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
          SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer Information Card
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
                          Row(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  S.of(context).customerInformation,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            focusNode: _nameFocusNode,
                            initialValue: customerName,
                            decoration: InputDecoration(
                              labelText: S.of(context).fullName,
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              floatingLabelStyle:
                                  WidgetStateTextStyle.resolveWith(
                                (states) => TextStyle(
                                  color: states.contains(WidgetState.focused)
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.person,
                                color: Theme.of(context).colorScheme.onSurface,
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
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  customerName = value;
                                });
                              }
                            },
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
                          const SizedBox(height: 8),
                          TextFormField(
                            focusNode: _phoneFocusNode,
                            initialValue: phoneNumber,
                            decoration: InputDecoration(
                              labelText: S.of(context).phoneNumber,
                              labelStyle: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              floatingLabelStyle:
                                  WidgetStateTextStyle.resolveWith(
                                (states) => TextStyle(
                                  color: states.contains(WidgetState.focused)
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.phone,
                                color: Theme.of(context).colorScheme.onSurface,
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
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              hintText: '+84 xxx xxx xxx',
                            ),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[\d\s+-]'),
                              ),
                            ],
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  phoneNumber = value;
                                });
                              }
                            },
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
