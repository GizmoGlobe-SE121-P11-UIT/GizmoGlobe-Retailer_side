import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/screens/voucher/add_voucher/add_voucher_cubit.dart';
import 'package:gizmoglobe_client/screens/voucher/add_voucher/add_voucher_state.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:intl/intl.dart';

import '../../../enums/processing/process_state_enum.dart';
import '../../../objects/voucher_related/voucher_argument.dart';
import '../../../widgets/general/field_with_icon.dart';
import '../../../widgets/general/gradient_dropdown.dart';

class AddVoucherScreen extends StatefulWidget {
  const AddVoucherScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => AddVoucherCubit(),
        child: const AddVoucherScreen(),
      );

  @override
  State<AddVoucherScreen> createState() => _AddVoucherScreen();
}

class _AddVoucherScreen extends State<AddVoucherScreen> {
  AddVoucherCubit get cubit => context.read<AddVoucherCubit>();

  late TextEditingController voucherNameController;
  late TextEditingController discountValueController;
  late TextEditingController minimumPurchaseController;
  late TextEditingController maxUsagePerPersonController;
  late TextEditingController descriptionController;
  late TextEditingController maximumUsageController;
  late TextEditingController maximumDiscountValueController;

  @override
  void initState() {
    super.initState();
    voucherNameController = TextEditingController();
    discountValueController = TextEditingController();
    minimumPurchaseController = TextEditingController();
    maxUsagePerPersonController = TextEditingController();
    descriptionController = TextEditingController();
    maximumUsageController = TextEditingController();
    maximumDiscountValueController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GradientIconButton(
          icon: Icons.chevron_left,
          onPressed: () => Navigator.pop(context, ProcessState.idle),
          fillColor: Colors.transparent,
        ),
        title: GradientText(text: S.of(context).addVoucher),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: BlocBuilder<AddVoucherCubit, AddVoucherState>(
              buildWhen: (previous, current) =>
                  previous.processState != current.processState,
              builder: (context, state) {
                return state.processState == ProcessState.loading
                    ? const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : GradientIconButton(
                        icon: Icons.check,
                        onPressed: () => cubit.addVoucher(),
                        fillColor: Colors.transparent,
                      );
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<AddVoucherCubit, AddVoucherState>(
        listener: (context, state) {
          if (state.processState == ProcessState.success) {
            showDialog(
              context: context,
              builder: (context) => InformationDialog(
                title: state.dialogName.toString(),
                content: state.notifyMessage.toString(),
                onPressed: () {
                  Navigator.pop(context, state.processState);
                },
              ),
            );
          } else if (state.processState == ProcessState.failure) {
            showDialog(
              context: context,
              builder: (context) => InformationDialog(
                title: state.dialogName.toString(),
                content: state.notifyMessage.toString(),
                onPressed: () {
                  cubit.toIdle();
                },
              ),
            );
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).basicInformation,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF202046),
                                  ),
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
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildInputWidget<double>(
                                        S.of(context).discountValue,
                                        discountValueController,
                                        state.voucherArgument?.discountValue,
                                        (value) {
                                          cubit.updateVoucherArgument(
                                            state.voucherArgument!.copyWith(discountValue: value));
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: buildInputWidget<double>(
                                        S.of(context).minimumPurchase,
                                        minimumPurchaseController,
                                        state.voucherArgument?.minimumPurchase,
                                        (value) {
                                          cubit.updateVoucherArgument(
                                            state.voucherArgument!.copyWith(minimumPurchase: value));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                buildInputWidget<DateTime>(
                                  S.of(context).startTime,
                                  TextEditingController(),
                                  state.voucherArgument?.startTime ?? DateTime.now(),
                                      (value) {
                                    cubit.updateVoucherArgument(state.voucherArgument!.copyWith(startTime: value));
                                  },
                                ),
                                const SizedBox(height: 16),
                                buildInputWidget<int>(
                                  S.of(context).maxUsagePerPerson,
                                  maxUsagePerPersonController,
                                  state.voucherArgument?.maxUsagePerPerson,
                                  (value) {
                                    cubit.updateVoucherArgument(
                                      state.voucherArgument!.copyWith(maxUsagePerPerson: value));
                                  },
                                ),
                                const SizedBox(height: 16),
                                buildInputWidget<String>(
                                  S.of(context).description,
                                  descriptionController,
                                  state.voucherArgument?.description,
                                  (value) {
                                    cubit.updateVoucherArgument(
                                      state.voucherArgument!.copyWith(description: value));
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Voucher Type Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(context).voucherSettings,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF202046),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                // Discount Type Toggle
                                buildToggleSwitch(
                                  label: S.of(context).discountType,
                                  value: state.voucherArgument?.isPercentage ??
                                      false,
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
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: buildInputWidget<double>(
                                      S.of(context).maximumDiscountValue,
                                      maximumDiscountValueController,
                                      state.voucherArgument
                                          ?.maximumDiscountValue,
                                      (value) {
                                        cubit.updateVoucherArgument(
                                          state.voucherArgument!.copyWith(maximumDiscountValue: value));
                                      },
                                    ),
                                  ),

                                const SizedBox(height: 24),
                                // Usage Limit Toggle
                                buildToggleSwitch(
                                  label: S.of(context).usageLimit,
                                  value:
                                      state.voucherArgument?.isLimited ?? false,
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
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: buildInputWidget<int>(
                                      S.of(context).maximumUsage,
                                      maximumUsageController,
                                      state.voucherArgument?.maximumUsage,
                                          (value) {
                                        cubit.updateVoucherArgument(state.voucherArgument!.copyWith(maximumUsage: value, usageLeft: value));
                                      },
                                    ),
                                  ),

                                const SizedBox(height: 24),
                                // Time Limit Toggle
                                buildToggleSwitch(
                                  label: S.of(context).timeLimit,
                                  value: state.voucherArgument?.hasEndTime ??
                                      false,
                                  leftLabel: S.of(context).noEndTime,
                                  rightLabel: S.of(context).hasEndTime,
                                  onChanged: (value) {
                                    cubit.updateVoucherArgument(
                                      state.voucherArgument!.copyWith(hasEndTime: value));
                                  },
                                ),

                                // Show end time picker if time limit is selected
                                if (state.voucherArgument?.hasEndTime == true)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: buildInputWidget<DateTime>(
                                      S.of(context).endTime,
                                      TextEditingController(),
                                      state.voucherArgument?.endTime ??
                                          DateTime.now()
                                              .add(const Duration(days: 7)),
                                      (value) {
                                        cubit.updateVoucherArgument(
                                          state.voucherArgument!.copyWith(endTime: value));
                                      },
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16.0),
                                    child: Text(
                                      S.of(context).voucherWillNotExpire,
                                      style: const TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: buildToggleSwitch(
                                        label: S.of(context).visibility,
                                        value:
                                            state.voucherArgument?.isVisible ??
                                                true,
                                        leftLabel: S.of(context).hidden,
                                        rightLabel: S.of(context).visible,
                                        onChanged: (value) {
                                          cubit.updateVoucherArgument(
                                            state.voucherArgument!.copyWith(isVisible: value));
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: buildToggleSwitch(
                                        label: S.of(context).status,
                                        value:
                                            state.voucherArgument?.isEnabled ??
                                                true,
                                        leftLabel: S.of(context).disabled,
                                        rightLabel: S.of(context).enabled,
                                        onChanged: (value) {
                                          cubit.updateVoucherArgument(
                                            state.voucherArgument!.copyWith(isEnabled: value));
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyle.smallText),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.withValues(alpha: 0.2),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(10)),
                      color:
                          !value ? const Color(0xFF202046) : Colors.transparent,
                      gradient: !value
                          ? const LinearGradient(
                              colors: [Color(0xFF6E74BC), Color(0xFF373C9A)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                    ),
                    child: Text(
                      leftLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: !value ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(10)),
                      color:
                          value ? const Color(0xFF202046) : Colors.transparent,
                      gradient: value
                          ? const LinearGradient(
                              colors: [Color(0xFF373C9A), Color(0xFF6E74BC)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            )
                          : null,
                    ),
                    child: Text(
                      rightLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: value ? Colors.white : Colors.black,
                      ),
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
        if (T == DateTime) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(propertyName, style: AppTextStyle.smallText),
              GestureDetector(
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: propertyValue as DateTime? ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF202046),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF202046),
                            ),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );

                  if (pickedDate != null) {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(
                          propertyValue as DateTime? ?? DateTime.now()),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color(0xFF202046),
                              onPrimary: Colors.white,
                              onSurface: Colors.black,
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF202046),
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
                    fillColor: const Color(0xFF202046),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ],
          );
        } else if (enumValues != null && T == bool) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
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
        } else if (enumValues != null) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(propertyName, style: AppTextStyle.smallText),
              GradientDropdown<T>(
                items: (String filter, dynamic infiniteScrollProps) => enumValues,
                compareFn: (T? d1, T? d2) => d1 == d2,
                itemAsString: (T d) => d.toString(),
                onChanged: onChanged,
                selectedItem: propertyValue,
                hintText: S.of(context).selectField(propertyName),
              ),
            ],
          );
        } else {
          TextInputType keyboardType;
          List<TextInputFormatter> inputFormatters;

          if (T == int) {
            keyboardType = TextInputType.number;
            inputFormatters = [FilteringTextInputFormatter.digitsOnly];
          } else if (T == double) {
            keyboardType = const TextInputType.numberWithOptions(decimal: true);
            inputFormatters = [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              if (propertyName == "Discount")
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) return newValue;
                  try {
                    final double? value = double.tryParse(newValue.text);
                    if (value != null && value > 100) {
                      return oldValue;
                    }
                  } catch (_) {}
                  return newValue;
                }),
            ];
          } else {
            keyboardType = TextInputType.text;
            inputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'.*'))];
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(propertyName, style: AppTextStyle.smallText),
              FieldWithIcon(
                controller: controller,
                hintText: S.of(context).enterField(propertyName),
                onChanged: (value) {
                  if (value.isEmpty) {
                    onChanged(null);
                  } else if (T == int) {
                    final parsed = int.tryParse(value);
                    if (parsed != null) {
                      if (propertyName == "Discount" && parsed > 100) {
                        controller.text = "0";
                        onChanged(1.0 as T?);
                      } else {
                        onChanged(parsed as T?);
                      }
                    }
                  } else if (T == double) {
                    if (value == '.' || value.endsWith('.')) return; // Allow typing decimals
                    final parsed = double.tryParse(value);
                    if (parsed != null) {
                      onChanged(parsed as T?);
                    }
                  } else {
                    onChanged(value as T?);
                  }
                },
                fillColor: const Color(0xFF202046),
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
              ),
            ],
          );
        }
      },
    );
  }
}
