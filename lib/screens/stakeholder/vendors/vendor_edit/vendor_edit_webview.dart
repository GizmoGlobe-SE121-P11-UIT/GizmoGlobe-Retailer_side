import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../../../../enums/stakeholders/manufacturer_status.dart';

class VendorEditWebView extends StatefulWidget {
  final Manufacturer manufacturer;

  const VendorEditWebView({
    super.key,
    required this.manufacturer,
  });

  static Widget newInstance({
    required Manufacturer manufacturer,
  }) =>
      VendorEditWebView(
        manufacturer: manufacturer,
      );

  @override
  State<VendorEditWebView> createState() => _VendorEditWebViewState();
}

class _VendorEditWebViewState extends State<VendorEditWebView> {
  final _formKey = GlobalKey<FormState>();
  late String manufacturerName;
  late ManufacturerStatus status;

  @override
  void initState() {
    super.initState();
    manufacturerName = widget.manufacturer.manufacturerName;
    status = widget.manufacturer.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      height: MediaQuery.of(context).size.height * 0.4,
      constraints: const BoxConstraints(
        maxWidth: 450,
        maxHeight: 350,
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
                  child: GradientText(text: S.of(context).editManufacturer),
                ),
                IconButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      try {
                        final updatedManufacturer = Manufacturer(
                          manufacturerID: widget.manufacturer.manufacturerID,
                          manufacturerName: manufacturerName,
                          status: status,
                        );

                        // Show success snackbar before closing
                        _showSnackBar(
                          title: S.of(context).success,
                          message: "Manufacturer updated successfully.",
                          contentType: ContentType.success,
                        );

                        // Small delay to show snackbar before closing
                        await Future.delayed(const Duration(milliseconds: 100));

                        if (mounted) {
                          Navigator.of(context).pop(updatedManufacturer);
                        }
                      } catch (e) {
                        if (mounted) {
                          _showErrorDialog(
                              "Failed to update manufacturer: ${e.toString()}");
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
                    // Manufacturer Information Card
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
                                  Icons.business_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  S.of(context).manufacturerInformation,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: manufacturerName,
                              decoration: InputDecoration(
                                labelText: S.of(context).manufacturerName,
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
                                  Icons.business,
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
                              onChanged: (value) {
                                if (mounted) {
                                  manufacturerName = value;
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return S.of(context).pleaseEnterName;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<ManufacturerStatus>(
                              initialValue: status,
                              decoration: InputDecoration(
                                labelText: S.of(context).status,
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
                                  Icons.info_outline,
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
                              dropdownColor: Theme.of(context).cardColor,
                              items: ManufacturerStatus.values.map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status == ManufacturerStatus.active
                                        ? S.of(context).active
                                        : S.of(context).inactive,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                if (newValue != null && mounted) {
                                  setState(() {
                                    status = newValue;
                                  });
                                }
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
