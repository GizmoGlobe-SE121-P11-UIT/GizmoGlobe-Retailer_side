import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/stakeholders/manufacturer_status.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../vendors_screen_cubit.dart';
import '../vendors_screen_state.dart';

class VendorAddWebView extends StatefulWidget {
  const VendorAddWebView({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => VendorsScreenCubit(),
        child: const VendorAddWebView(),
      );

  @override
  State<VendorAddWebView> createState() => _VendorAddWebViewState();
}

class _VendorAddWebViewState extends State<VendorAddWebView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  ManufacturerStatus selectedStatus = ManufacturerStatus.active;

  VendorsScreenCubit get cubit => context.read<VendorsScreenCubit>();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorsScreenCubit, VendorsScreenState>(
      builder: (context, state) {
        final screenWidth = MediaQuery.of(context).size.width;
        final isMobile = screenWidth < 600;
        final containerWidth = isMobile
            ? screenWidth - 16 // 8px margin on each side
            : screenWidth * 0.3;

        return Container(
          width: isMobile ? containerWidth : containerWidth.clamp(320.0, 450.0),
          constraints: BoxConstraints(
            maxWidth: isMobile ? screenWidth : 450,
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
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.business_center,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child:
                          GradientText(text: S.of(context).addNewManufacturer),
                    ),
                    IconButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _addManufacturer();
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
                              TextFormField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  labelText: S.of(context).manufacturerName,
                                  labelStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  floatingLabelStyle:
                                      WidgetStateTextStyle.resolveWith(
                                    (states) => TextStyle(
                                      color:
                                          states.contains(WidgetState.focused)
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return S.of(context).pleaseEnterName;
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<ManufacturerStatus>(
                                initialValue: selectedStatus,
                                decoration: InputDecoration(
                                  labelText: S.of(context).status,
                                  labelStyle: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  floatingLabelStyle:
                                      WidgetStateTextStyle.resolveWith(
                                    (states) => TextStyle(
                                      color:
                                          states.contains(WidgetState.focused)
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
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
                                isExpanded: true,
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
                                      selectedStatus = newValue;
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
            ],
          ),
        );
      },
    );
  }

  Future<void> _addManufacturer() async {
    final error = await cubit.createManufacturer(
      _nameController.text,
      selectedStatus,
    );

    if (error != null) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => InformationDialog(
            title: S.of(context).errorOccurred,
            content: error,
            buttonText: S.of(context).confirm,
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }
}
