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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 500;
    
    return Container(
      width: isMobile
          ? screenWidth - 16
          : MediaQuery.of(context).size.width * 0.35,
      height: isMobile
          ? MediaQuery.of(context).size.height * 0.7
          : MediaQuery.of(context).size.height * 0.4,
      constraints: BoxConstraints(
        maxWidth: isMobile ? screenWidth - 16 : 450,
        maxHeight: isMobile ? MediaQuery.of(context).size.height * 0.8 : 350,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
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
            padding: EdgeInsets.all(isMobile ? 6 : 8),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(isMobile ? 12 : 16),
                topRight: Radius.circular(isMobile ? 12 : 16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: Theme.of(context).colorScheme.primary,
                  size: isMobile ? 16 : 24,
                ),
                SizedBox(width: isMobile ? 4 : 8),
                Expanded(
                  child: GradientText(
                    text: S.of(context).editManufacturer,
                    fontSize: isMobile ? 12 : 16,
                  ),
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
                  icon: Icon(Icons.check, size: isMobile ? 16 : 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.all(isMobile ? 2 : 8),
                    minimumSize: Size(isMobile ? 28 : 48, isMobile ? 28 : 48),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                  ),
                ),
                SizedBox(width: isMobile ? 0 : 4),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(null),
                  icon: Icon(Icons.close, size: isMobile ? 16 : 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    padding: EdgeInsets.all(isMobile ? 2 : 8),
                    minimumSize: Size(isMobile ? 28 : 48, isMobile ? 28 : 48),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: isMobile ? VisualDensity.compact : VisualDensity.standard,
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Manufacturer Information Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isMobile ? 10 : 12),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isMobile ? 10 : 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.business_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: isMobile ? 18 : 20,
                                ),
                                SizedBox(width: isMobile ? 6 : 8),
                                Flexible(
                                  child: Text(
                                    S.of(context).manufacturerInformation,
                                    style: TextStyle(
                                      fontSize: isMobile ? 14 : 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isMobile ? 6 : 8),
                            TextFormField(
                              initialValue: manufacturerName,
                              decoration: InputDecoration(
                                labelText: S.of(context).manufacturerName,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                                floatingLabelStyle:
                                    WidgetStateTextStyle.resolveWith(
                                  (states) => TextStyle(
                                    color: states.contains(WidgetState.focused)
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontSize: isMobile ? 14 : 16,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.business,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: isMobile ? 20 : 24,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 16,
                                  vertical: isMobile ? 12 : 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                              style: TextStyle(fontSize: isMobile ? 14 : 16),
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
                            SizedBox(height: isMobile ? 6 : 8),
                            DropdownButtonFormField<ManufacturerStatus>(
                              initialValue: status,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: S.of(context).status,
                                labelStyle: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  fontSize: isMobile ? 14 : 16,
                                ),
                                floatingLabelStyle:
                                    WidgetStateTextStyle.resolveWith(
                                  (states) => TextStyle(
                                    color: states.contains(WidgetState.focused)
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                    fontSize: isMobile ? 14 : 16,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.info_outline,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                  size: isMobile ? 20 : 24,
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 16,
                                  vertical: isMobile ? 12 : 16,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
                                  borderSide: BorderSide(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(isMobile ? 6 : 8),
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
                                      fontSize: isMobile ? 14 : 16,
                                    ),
                                    overflow: TextOverflow.ellipsis,
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
