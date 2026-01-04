import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/processing/notify_message_enum.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:gizmoglobe_client/widgets/general/multi_field_with_icon.dart';
import 'package:intl/intl.dart';
import 'package:gizmoglobe_client/widgets/snackbar/snackbar_service.dart';

import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/voucher_related/distribution_type.dart';
import '../../../objects/voucher_related/voucher_argument.dart';
import '../../../widgets/general/field_with_icon.dart';
import '../../../widgets/general/gradient_dropdown.dart';
import 'edit_voucher_cubit.dart';
import 'edit_voucher_state.dart';
import '../../../objects/voucher_related/voucher.dart';
import '../../../objects/voucher_related/limited_interface.dart';
import '../../../objects/voucher_related/percentage_interface.dart';

class EditVoucherWebView extends StatefulWidget {
  final Voucher voucher;

  const EditVoucherWebView({super.key, required this.voucher});

  static Widget newInstance(Voucher voucher) => BlocProvider(
        create: (context) => EditVoucherCubit(),
        child: EditVoucherWebView(voucher: voucher),
      );

  @override
  State<EditVoucherWebView> createState() => _EditVoucherWebViewState();
}

class _EditVoucherWebViewState extends State<EditVoucherWebView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController voucherNameController;
  late TextEditingController discountValueController;
  late TextEditingController minimumPurchaseController;
  late TextEditingController maxUsagePerPersonController;
  late TextEditingController enDescriptionController;
  late TextEditingController viDescriptionController;
  late TextEditingController maximumUsageController;
  late TextEditingController maximumDiscountValueController;
  late TextEditingController usageLeftController;

  EditVoucherCubit get cubit => context.read<EditVoucherCubit>();

  @override
  void initState() {
    super.initState();
    cubit.initialize(widget.voucher);
    voucherNameController = TextEditingController();
    discountValueController = TextEditingController();
    minimumPurchaseController = TextEditingController();
    maxUsagePerPersonController = TextEditingController();
    enDescriptionController = TextEditingController();
    viDescriptionController = TextEditingController();
    maximumUsageController = TextEditingController();
    maximumDiscountValueController = TextEditingController();
    usageLeftController = TextEditingController();
    initTextControllers();
  }

  void initTextControllers() {
    final voucher = widget.voucher;
    voucherNameController.text = voucher.voucherName;
    discountValueController.text = voucher.discountValue.toString();
    minimumPurchaseController.text = voucher.minimumPurchase.toString();
    maxUsagePerPersonController.text = voucher.maxUsagePerPerson.toString();
    enDescriptionController.text = voucher.enDescription ?? '';
    viDescriptionController.text = voucher.viDescription ?? '';

    if (voucher is PercentageInterface) {
      maximumDiscountValueController.text =
          (voucher as PercentageInterface).maximumDiscountValue.toString();
    }

    if (voucher is LimitedInterface) {
      maximumUsageController.text =
          (voucher as LimitedInterface).maximumUsage.toString();
      usageLeftController.text =
          (voucher as LimitedInterface).usageLeft.toString();
    }
  }

  @override
  void dispose() {
    voucherNameController.dispose();
    discountValueController.dispose();
    minimumPurchaseController.dispose();
    maxUsagePerPersonController.dispose();
    enDescriptionController.dispose();
    viDescriptionController.dispose();
    maximumUsageController.dispose();
    maximumDiscountValueController.dispose();
    usageLeftController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditVoucherCubit, EditVoucherState>(
      listener: (context, state) {
        if (!mounted) return;

        if (state.processState == ProcessState.success) {
          if (state.notifyMessage == NotifyMessage.msg21) {
            if (mounted) {
              enDescriptionController.text =
                  state.voucherArgument?.enDescription ?? '';
              viDescriptionController.text =
                  state.voucherArgument?.viDescription ?? '';
              SnackbarService.showSuccess(
                context,
                state.dialogName.getLocalizedName(context),
                state.notifyMessage.getLocalizedMessage(context),
              );
              cubit.toIdle();
            }
          } else {
            if (mounted) {
              SnackbarService.showSuccess(
                context,
                state.dialogName.getLocalizedName(context),
                state.notifyMessage.getLocalizedMessage(context),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  Navigator.pop(
                      context, state.processState == ProcessState.success);
                }
              });
            }
          }
        } else if (state.processState == ProcessState.failure) {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => InformationDialog(
                title: state.dialogName.getLocalizedName(context),
                content: state.notifyMessage.getLocalizedMessage(context),
                onPressed: () {
                  if (mounted) {
                    cubit.toIdle();
                  }
                },
              ),
            );
          }
        }
      },
      builder: (context, state) {
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final isMobile = screenWidth < 600;
        final containerWidth = isMobile ? screenWidth * 0.98 : screenWidth * 0.8;
        final containerHeight = isMobile ? screenHeight * 0.95 : screenHeight * 0.9;

        return Container(
          width: containerWidth,
          height: containerHeight,
          constraints: BoxConstraints(
            maxWidth: isMobile ? screenWidth * 0.98 : 1200,
            maxHeight: isMobile ? screenHeight * 0.95 : 800,
            minWidth: 300,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(isMobile ? 0 : 16),
            boxShadow: isMobile
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Column(
            children: [
              _buildHeader(state),
              Expanded(
                child: state.processState == ProcessState.loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : _buildContent(state),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(EditVoucherState state) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Container(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.card_giftcard,
            color: Theme.of(context).colorScheme.primary,
            size: isMobile ? 24 : 28,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: GradientText(
              text: S.of(context).edit,
            ),
          ),
          if (state.processState == ProcessState.loading)
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          else
            IconButton(
              onPressed: () {
                if (mounted && _formKey.currentState!.validate()) {
                  cubit.editVoucher();
                }
              },
              icon: const Icon(Icons.check),
              style: IconButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              if (mounted) {
                Navigator.of(context).pop(null);
              }
            },
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(EditVoucherState state) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Padding(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInformationSection(state),
              SizedBox(height: isMobile ? 16 : 24),
              _buildVoucherSettingsSection(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInformationSection(EditVoucherState state) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).basicInformation,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202046),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            buildInputWidget<String>(
              S.of(context).voucherName,
              voucherNameController,
              state.voucherArgument?.voucherName,
              (value) {
                cubit.updateVoucherArgument(
                    state.voucherArgument!.copyWith(voucherName: value));
              },
            ),
            SizedBox(height: isMobile ? 12 : 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 400;
                if (isNarrow) {
                  // Stack vertically on narrow screens
                  return Column(
                    children: [
                      buildInputWidget<int>(
                        S.of(context).discountValue,
                        discountValueController,
                        state.voucherArgument?.discountValue,
                        (value) {
                          cubit.updateVoucherArgument(state.voucherArgument!
                              .copyWith(discountValue: value));
                        },
                      ),
                      SizedBox(height: isMobile ? 12 : 16),
                      buildInputWidget<double>(
                        S.of(context).minimumPurchase,
                        minimumPurchaseController,
                        state.voucherArgument?.minimumPurchase?.toDouble(),
                        (value) {
                          cubit.updateVoucherArgument(state.voucherArgument!
                              .copyWith(minimumPurchase: value?.toInt()));
                        },
                      ),
                    ],
                  );
                } else {
                  // Use row layout for wider screens
                  return Row(
                    children: [
                      Expanded(
                        child: buildInputWidget<int>(
                          S.of(context).discountValue,
                          discountValueController,
                          state.voucherArgument?.discountValue,
                          (value) {
                            cubit.updateVoucherArgument(state.voucherArgument!
                                .copyWith(discountValue: value));
                          },
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 16),
                      Expanded(
                        child: buildInputWidget<double>(
                          S.of(context).minimumPurchase,
                          minimumPurchaseController,
                          state.voucherArgument?.minimumPurchase?.toDouble(),
                          (value) {
                            cubit.updateVoucherArgument(state.voucherArgument!
                                .copyWith(minimumPurchase: value?.toInt()));
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            SizedBox(height: isMobile ? 12 : 16),
            buildInputWidget<DateTime>(
              S.of(context).startTime,
              TextEditingController(),
              state.voucherArgument?.startTime ?? DateTime.now(),
              (value) {
                cubit.updateVoucherArgument(
                    state.voucherArgument!.copyWith(startTime: value));
              },
            ),
            SizedBox(height: isMobile ? 12 : 16),
            buildInputWidget<int>(
              S.of(context).maxUsagePerPerson,
              maxUsagePerPersonController,
              state.voucherArgument?.maxUsagePerPerson,
              (value) {
                cubit.updateVoucherArgument(
                    state.voucherArgument!.copyWith(maxUsagePerPerson: value));
              },
            ),
            SizedBox(height: isMobile ? 12 : 16),
            MultiFieldWithIcon(
              controller: enDescriptionController,
              hintText: S.of(context).enterField(S.of(context).enDescription),
              labelText: S.of(context).enDescription,
              onChanged: (value) {
                cubit.updateVoucherArgument(
                    state.voucherArgument!.copyWith(enDescription: value));
              },
              suffixIcon: (state.voucherArgument!.isEnEmpty &&
                      state.voucherArgument!.isViEmpty)
                  ? Icons.add_comment
                  : Icons.g_translate,
              onSuffixIconPressed: () {
                cubit.generateEnDescription();
              },
            ),
            SizedBox(height: isMobile ? 12 : 16),
            MultiFieldWithIcon(
              controller: viDescriptionController,
              hintText: S.of(context).enterField(S.of(context).viDescription),
              labelText: S.of(context).viDescription,
              onChanged: (value) {
                cubit.updateVoucherArgument(
                    state.voucherArgument!.copyWith(viDescription: value));
              },
              suffixIcon: (state.voucherArgument!.isEnEmpty &&
                      state.voucherArgument!.isViEmpty)
                  ? Icons.add_comment
                  : Icons.g_translate,
              onSuffixIconPressed: () {
                cubit.generateViDescription();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherSettingsSection(EditVoucherState state) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  S.of(context).voucherSettings,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202046),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            // Discount Type Toggle
            buildToggleSwitch(
              label: S.of(context).discountType,
              value: state.voucherArgument?.isPercentage ?? false,
              leftLabel: S.of(context).fixedAmount,
              rightLabel: S.of(context).percentage,
              onChanged: (value) {
                cubit.updateVoucherArgument(
                    state.voucherArgument!.copyWith(isPercentage: value));
              },
            ),

            // Show maximum discount value field if percentage is selected
            if (state.voucherArgument?.isPercentage == true)
              Padding(
                padding: EdgeInsets.only(top: isMobile ? 12.0 : 16.0),
                child: buildInputWidget<double>(
                  S.of(context).maximumDiscountValue,
                  maximumDiscountValueController,
                  state.voucherArgument?.maximumDiscountValue?.toDouble(),
                  (value) {
                    cubit.updateVoucherArgument(state.voucherArgument!
                        .copyWith(maximumDiscountValue: value?.toInt()));
                  },
                ),
              ),

            SizedBox(height: isMobile ? 16 : 24),
            // Usage Limit Toggle
            buildToggleSwitch(
              label: S.of(context).usageLimit,
              value: state.voucherArgument?.isLimited ?? false,
              leftLabel: S.of(context).unlimited,
              rightLabel: S.of(context).limited,
              onChanged: (value) {
                cubit.updateVoucherArgument(
                    state.voucherArgument!.copyWith(isLimited: value));
              },
            ),

            // Show maximum usage field if limited is selected
            if (state.voucherArgument?.isLimited == true)
              Padding(
                padding: EdgeInsets.only(top: isMobile ? 12.0 : 16.0),
                child: buildInputWidget<double>(
                  S.of(context).maximumUsage,
                  maximumUsageController,
                  state.voucherArgument?.maximumUsage?.toDouble(),
                  (value) {
                    cubit.updateVoucherArgument(state.voucherArgument!.copyWith(
                        maximumUsage: value?.toInt(),
                        usageLeft: value?.toInt()));
                  },
                ),
              ),

            SizedBox(height: isMobile ? 16 : 24),
            // Time Limit Toggle
            buildToggleSwitch(
              label: S.of(context).timeLimit,
              value: state.voucherArgument?.hasEndTime ?? false,
              leftLabel: S.of(context).noEndTime,
              rightLabel: S.of(context).hasEndTime,
              onChanged: (value) {
                cubit.updateVoucherArgument(
                  state.voucherArgument?.copyWith(
                        hasEndTime: value,
                        endTime: value ? state.voucherArgument?.endTime : null,
                      ) ??
                      VoucherArgument(
                          hasEndTime: value, endTime: value ? null : null),
                );
              },
            ),

            // Show end time picker if time limit is selected
            if (state.voucherArgument?.hasEndTime == true)
              Padding(
                padding: EdgeInsets.only(top: isMobile ? 12.0 : 16.0),
                child: buildInputWidget<DateTime>(
                  S.of(context).endTime,
                  TextEditingController(),
                  state.voucherArgument?.endTime ??
                      DateTime.now().add(const Duration(days: 7)),
                  (value) {
                    cubit.updateVoucherArgument(
                        state.voucherArgument!.copyWith(endTime: value));
                  },
                ),
              )
            else
              Padding(
                padding: EdgeInsets.only(top: isMobile ? 12.0 : 16.0),
                child: Text(
                  S.of(context).voucherWillNotExpire,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ),

            SizedBox(height: isMobile ? 16 : 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 500;
                if (isNarrow) {
                  // Stack vertically on narrow screens
                  return Column(
                    children: [
                      buildInputWidget<DistributionType>(
                        S.of(context).visibility,
                        TextEditingController(),
                        state.voucherArgument?.distributionType ?? DistributionType.public,
                        (value) {
                          if (value != null) {
                            cubit.updateVoucherArgument(state.voucherArgument!.copyWith(distributionType: value));
                          }
                        },
                        DistributionType.values,
                        null,
                      ),
                      SizedBox(height: isMobile ? 16 : 24),
                      buildToggleSwitch(
                        label: S.of(context).status,
                        value: state.voucherArgument?.isEnabled ?? true,
                        leftLabel: S.of(context).disabled,
                        rightLabel: S.of(context).enabled,
                        onChanged: (value) {
                          cubit.updateVoucherArgument(
                              state.voucherArgument!.copyWith(isEnabled: value));
                        },
                      ),
                    ],
                  );
                } else {
                  // Use row layout for wider screens
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: buildInputWidget<DistributionType>(
                          S.of(context).visibility,
                          TextEditingController(),
                          state.voucherArgument?.distributionType ?? DistributionType.public,
                          (value) {
                            if (value != null) {
                              cubit.updateVoucherArgument(state.voucherArgument!.copyWith(distributionType: value));
                            }
                          },
                          DistributionType.values,
                          null,
                        ),
                      ),
                      SizedBox(width: isMobile ? 8 : 16),
                      Expanded(
                        child: buildToggleSwitch(
                          label: S.of(context).status,
                          value: state.voucherArgument?.isEnabled ?? true,
                          leftLabel: S.of(context).disabled,
                          rightLabel: S.of(context).enabled,
                          onChanged: (value) {
                            cubit.updateVoucherArgument(
                                state.voucherArgument!.copyWith(isEnabled: value));
                          },
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Toggle switch for boolean values
  Widget buildToggleSwitch({
    required String label,
    required bool value,
    required String leftLabel,
    required String rightLabel,
    required Function(bool) onChanged,
  }) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.smallText),
        SizedBox(height: isMobile ? 6 : 8),
        Container(
          constraints: const BoxConstraints(
            minHeight: 44,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 10 : 12,
                      horizontal: isMobile ? 4 : 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(10)),
                      color: !value
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),
                    child: Text(
                      leftLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 12 : 14,
                        color: !value
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: isMobile ? 10 : 12,
                      horizontal: isMobile ? 4 : 8,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(10)),
                      color: value
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                    ),
                    child: Text(
                      rightLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: isMobile ? 12 : 14,
                        color: value
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildInputWidget<T>(
    String propertyName,
    TextEditingController controller,
    T? propertyValue,
    void Function(T?) onChanged, [
    List<T>? enumValues,
    Map<T, String>? enumLabels,
  ]) {
    return Builder(
      builder: (BuildContext context) {
        // Handle DateTime fields
        if (T == DateTime) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(propertyName, style: AppTextStyle.smallText),
              GestureDetector(
                onTap: () async {
                  final BuildContext currentContext = context;
                  final DateTime? pickedDate = await showDatePicker(
                    context: currentContext,
                    initialDate: propertyValue as DateTime? ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Theme.of(context).colorScheme.primary,
                            onPrimary: Theme.of(context).colorScheme.onPrimary,
                            onSurface: Theme.of(context).colorScheme.onSurface,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: currentContext,
                      initialTime: TimeOfDay.fromDateTime(
                          propertyValue as DateTime? ?? DateTime.now()),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Theme.of(context).colorScheme.primary,
                              onPrimary:
                                  Theme.of(context).colorScheme.onPrimary,
                              onSurface:
                                  Theme.of(context).colorScheme.onSurface,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );

                    if (pickedTime != null) {
                      final DateTime combinedDateTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      onChanged(combinedDateTime as T?);
                    }
                  }
                },
                child: AbsorbPointer(
                  child: FieldWithIcon(
                    controller: TextEditingController(
                      text: (propertyValue as DateTime?) != null
                          ? DateFormat('dd/MM/yyyy HH:mm')
                              .format(propertyValue as DateTime)
                          : '',
                    ),
                    readOnly: true,
                    hintText: S.of(context).selectField(propertyName),
                    fillColor: Theme.of(context).colorScheme.surface,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ],
          );
        }
        // Handle enum fields with boolean type
        else if (enumValues != null && T == bool) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(propertyName, style: AppTextStyle.smallText),
              GradientDropdown<T>(
                items: (String filter, dynamic infiniteScrollProps) =>
                    enumValues,
                compareFn: (T? d1, T? d2) => d1 == d2,
                itemAsString: (T d) => enumLabels?[d] ?? d.toString(),
                onChanged: onChanged,
                selectedItem: propertyValue,
                hintText: S.of(context).selectField(propertyName),
              ),
            ],
          );
        }
        // Handle other enum fields
        else if (enumValues != null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(propertyName, style: AppTextStyle.smallText),
              GradientDropdown<T>(
                items: (String filter, dynamic infiniteScrollProps) =>
                    enumValues,
                compareFn: (T? d1, T? d2) => d1 == d2,
                itemAsString: (T d) {
                  // Handle DistributionType with proper localization
                  if (d is DistributionType) {
                    return d.getLocalizedName(context);
                  }
                  return d.toString();
                },
                onChanged: onChanged,
                selectedItem: propertyValue,
                hintText: S.of(context).selectField(propertyName),
              ),
            ],
          );
        } else {
          // Handle text fields based on type
          TextInputType keyboardType;
          List<TextInputFormatter> inputFormatters = [];

          // Configure input type and formatters based on field type and name
          if (T == double) {
            keyboardType = const TextInputType.numberWithOptions(decimal: true);
            inputFormatters = [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ];
          } else if (T == int) {
            keyboardType = TextInputType.number;
            inputFormatters = [FilteringTextInputFormatter.digitsOnly];
          } else {
            keyboardType = TextInputType.text;
            inputFormatters = [
              FilteringTextInputFormatter.allow(RegExp(r'.*'))
            ];
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(propertyName, style: AppTextStyle.smallText),
              FieldWithIcon(
                controller: controller,
                hintText: S.of(context).enterField(propertyName),
                onChanged: (value) {
                  if (value.isEmpty) {
                    if (T == String) {
                      onChanged('' as T?);
                    } else {
                      onChanged(null);
                    }
                  } else if (T == int) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      onChanged(parsed as T?);
                    }
                  } else if (T == double) {
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      onChanged(parsed as T?);
                    } else if (value == '.' || value.endsWith('.')) {
                      controller.text = value;
                      controller.selection = TextSelection.fromPosition(
                        TextPosition(offset: controller.text.length),
                      );
                    }
                  } else {
                    onChanged(value as T?);
                  }
                },
                fillColor: Theme.of(context).colorScheme.surface,
                textColor: Theme.of(context).colorScheme.onSurface,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
              ),
            ],
          );
        }
      },
    );
  }

  // Snackbar handled by SnackbarService
}
