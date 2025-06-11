import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:intl/intl.dart';

import '../../../data/database/database.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/category_enum.dart';
import '../../../enums/product_related/cpu_enums/cpu_family.dart';
import '../../../enums/product_related/drive_enums/drive_capacity.dart';
import '../../../enums/product_related/drive_enums/drive_type.dart';
import '../../../enums/product_related/gpu_enums/gpu_bus.dart';
import '../../../enums/product_related/gpu_enums/gpu_capacity.dart';
import '../../../enums/product_related/gpu_enums/gpu_series.dart';
import '../../../enums/product_related/mainboard_enums/mainboard_compatibility.dart';
import '../../../enums/product_related/mainboard_enums/mainboard_form_factor.dart';
import '../../../enums/product_related/mainboard_enums/mainboard_series.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../../enums/product_related/psu_enums/psu_efficiency.dart';
import '../../../enums/product_related/psu_enums/psu_modular.dart';
import '../../../enums/product_related/ram_enums/ram_bus.dart';
import '../../../enums/product_related/ram_enums/ram_capacity_enum.dart';
import '../../../enums/product_related/ram_enums/ram_type.dart';
import '../../../objects/manufacturer.dart';
import '../../../widgets/general/field_with_icon.dart';
import '../../../widgets/general/gradient_dropdown.dart';
import '../../../widgets/general/multi_field_with_icon.dart';
import 'add_product_state.dart';
import 'add_product_cubit.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => AddProductCubit(),
        child: const AddProductScreen(),
      );

  @override
  State<AddProductScreen> createState() => _AddProductState();
}

class _AddProductState extends State<AddProductScreen> {
  AddProductCubit get cubit => context.read<AddProductCubit>();
  late TextEditingController productNameController;
  late TextEditingController importPriceController;
  late TextEditingController sellingPriceController;
  late TextEditingController discountController;
  late TextEditingController stockController;
  late TextEditingController cpuCoreController;
  late TextEditingController cpuThreadController;
  late TextEditingController cpuClockSpeedController;
  late TextEditingController psuWattageController;
  late TextEditingController gpuClockSpeedController;
  late TextEditingController enDescriptionController;
  late TextEditingController viDescriptionController;

  @override
  void initState() {
    super.initState();
    productNameController = TextEditingController();
    importPriceController = TextEditingController();
    sellingPriceController = TextEditingController();
    discountController = TextEditingController();
    stockController = TextEditingController();
    cpuCoreController = TextEditingController();
    cpuThreadController = TextEditingController();
    cpuClockSpeedController = TextEditingController();
    psuWattageController = TextEditingController();
    gpuClockSpeedController = TextEditingController();
    enDescriptionController = TextEditingController();
    viDescriptionController = TextEditingController();
  }

  void _showImagePickerMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(S.of(context).chooseFromGallery),
                onTap: () {
                  Navigator.pop(context);
                  cubit.pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(S.of(context).takePhoto),
                onTap: () {
                  Navigator.pop(context);
                  cubit.pickImageFromCamera();
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: Text(S.of(context).enterUrl),
                onTap: () {
                  Navigator.pop(context);
                  _showUrlInputDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUrlInputDialog() {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(S.of(context).enterImageUrl),
          content: TextField(
            controller: urlController,
            decoration: const InputDecoration(
              hintText: 'https://example.com/image.jpg',
            ),
            keyboardType: TextInputType.url,
          ),
          actions: <Widget>[
            TextButton(
              child: Text(S.of(context).cancel),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: Text(S.of(context).confirm),
              onPressed: () {
                if (urlController.text.isNotEmpty) {
                  cubit.pickImageFromUrl(urlController.text);
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GradientIconButton(
          icon: Icons.chevron_left,
          onPressed: () => Navigator.pop(context, ProcessState.idle),
          fillColor: Colors.transparent,
        ),
        title: const GradientText(text: 'Add Product'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: BlocBuilder<AddProductCubit, AddProductState>(
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
                        onPressed: () => cubit.addProduct(),
                        fillColor: Colors.transparent,
                      );
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<AddProductCubit, AddProductState>(
        listener: (context, state) {
          if (state.processState == ProcessState.success) {
            if (state.notifyMessage == NotifyMessage.msg21) {
              enDescriptionController.text = state.productArgument?.enDescription ?? '';
              viDescriptionController.text = state.productArgument?.viDescription ?? '';

              showDialog(
                context: context,
                builder: (context) => InformationDialog(
                  title: state.dialogName.getLocalizedName(context),
                  content: state.notifyMessage.getLocalizedMessage(context),
                  onPressed: () {
                    cubit.toIdle();
                    //Navigator.pop(context);
                  },
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (context) =>
                    InformationDialog(
                      title: state.dialogName.getLocalizedName(context),
                      content: state.notifyMessage.getLocalizedMessage(context),
                      onPressed: () {
                        Navigator.pop(context, state.processState);
                      },
                    ),
              );
            }
          } else if (state.processState == ProcessState.failure) {
            showDialog(
              context: context,
              builder: (context) => InformationDialog(
                title: state.dialogName.getLocalizedName(context),
                content: state.notifyMessage.getLocalizedMessage(context),
                onPressed: () {
                  cubit.toIdle();
                },
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _showImagePickerMenu,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (state.imageUrl != null)
                          Center(
                            child: Image.network(
                              state.imageUrl!,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Center(
                                  child: Icon(
                                    Icons.error_outline,
                                    color: colorScheme.error,
                                    size: 48,
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  S.of(context).addProductImage,
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (state.isUploadingImage)
                          Positioned.fill(
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color.fromRGBO(0, 0, 0, 0.5),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                ),
                              ),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
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
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildInputWidget<String>(
                            S.of(context).productName,
                            productNameController,
                            state.productArgument?.productName,
                            (value) {
                              cubit.updateProductArgument(state.productArgument!
                                  .copyWith(productName: value));
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: buildInputWidget<double>(
                                  S.of(context).importPrice,
                                  importPriceController,
                                  state.productArgument?.importPrice,
                                  (value) {
                                    cubit.updateProductArgument(state
                                        .productArgument!
                                        .copyWith(importPrice: value));
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: buildInputWidget<double>(
                                  S.of(context).sellingPrice,
                                  sellingPriceController,
                                  state.productArgument?.sellingPrice,
                                  (value) {
                                    cubit.updateProductArgument(state
                                        .productArgument!
                                        .copyWith(sellingPrice: value));
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: buildInputWidget<String>(
                                  S.of(context).discount,
                                  discountController,
                                  state.productArgument?.discount?.toString(),
                                  (value) {
                                    double? parsed;
                                    if (value != null && value.isNotEmpty) {
                                      parsed = double.tryParse(value);
                                    }
                                    cubit.updateProductArgument(state
                                        .productArgument!
                                        .copyWith(discount: parsed));
                                  },
                                  null,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: buildInputWidget<int>(
                                  S.of(context).stock,
                                  stockController,
                                  state.productArgument?.stock,
                                  (value) {
                                    final newStatus = value! > 0
                                        ? ProductStatusEnum.active
                                        : ProductStatusEnum.outOfStock;
                                    cubit.updateProductArgument(
                                        state.productArgument!.copyWith(
                                            stock: value, status: newStatus));
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
                            S.of(context).additionalInformation,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildInputWidget<DateTime>(
                            S.of(context).releaseDate,
                            TextEditingController(),
                            state.productArgument?.release ?? DateTime.now(),
                            (value) {
                              cubit.updateProductArgument(state.productArgument!
                                  .copyWith(release: value));
                            },
                          ),
                          const SizedBox(height: 16),
                          buildInputWidget<CategoryEnum>(
                            S.of(context).category,
                            TextEditingController(),
                            state.productArgument?.category,
                            (value) {
                              cubit.updateProductArgument(state.productArgument!
                                  .copyWith(category: value));
                            },
                            CategoryEnum.nonEmptyValues,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              buildInputWidget<Manufacturer>(
                                S.of(context).manufacturer,
                                TextEditingController(),
                                state.productArgument?.manufacturer,
                                (value) {
                                  cubit.updateProductArgument(state
                                      .productArgument!
                                      .copyWith(manufacturer: value));
                                },
                                Database().manufacturerList,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(S.of(context).status,
                                  style: AppTextStyle.smallText),
                              const SizedBox(height: 8),
                              BlocBuilder<AddProductCubit, AddProductState>(
                                builder: (context, state) {
                                  final status =
                                      (state.productArgument?.stock ?? 0) > 0
                                          ? ProductStatusEnum.active
                                          : ProductStatusEnum.outOfStock;

                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: status == ProductStatusEnum.active
                                          ? colorScheme.tertiary
                                              .withValues(alpha: 0.1)
                                          : colorScheme.error
                                              .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color:
                                            status == ProductStatusEnum.active
                                                ? colorScheme.tertiary
                                                : colorScheme.error,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          status == ProductStatusEnum.active
                                              ? Icons.check_circle
                                              : Icons.error,
                                          color:
                                              status == ProductStatusEnum.active
                                                  ? Colors.green
                                                  : Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          status == ProductStatusEnum.active
                                              ? S.of(context).active
                                              : S.of(context).outOfStock,
                                          style: TextStyle(
                                            color: status ==
                                                    ProductStatusEnum.active
                                                ? Colors.green
                                                : Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (state.productArgument?.category != null &&
                    state.productArgument?.category != CategoryEnum.empty)
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
                              '${S.of(context).categorySpecifications} ${state.productArgument?.category.toString()}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 16),
                            buildCategorySpecificInputs(
                              state.productArgument?.category ??
                                  CategoryEnum.empty,
                              state,
                              cubit,
                            ),

                            MultiFieldWithIcon(
                              controller: enDescriptionController,
                              hintText: S.of(context).enterField(S.of(context).enDescription),
                              labelText: S.of(context).enDescription,
                              onChanged: (value) {
                                cubit.updateProductArgument(state
                                    .productArgument!
                                    .copyWith(enDescription: value));
                              },
                              suffixIcon: (state.productArgument!.isEnEmpty && state.productArgument!.isViEmpty)
                                  ? Icons.add_comment
                                  : Icons.g_translate,
                              isEnabled: state.productArgument!.isEnEmpty,
                              onSuffixIconPressed: () {
                                cubit.generateEnDescription();
                              },
                            ),
                            const SizedBox(height: 16),

                            MultiFieldWithIcon(
                              controller: viDescriptionController,
                              hintText: S.of(context).enterField(S.of(context).viDescription),
                              labelText: S.of(context).viDescription,
                              onChanged: (value) {
                                cubit.updateProductArgument(state
                                    .productArgument!
                                    .copyWith(viDescription: value));
                              },
                              suffixIcon: (state.productArgument!.isEnEmpty && state.productArgument!.isViEmpty)
                                  ? Icons.add_comment
                                  : Icons.g_translate,
                              isEnabled: state.productArgument!.isViEmpty,
                              onSuffixIconPressed: () {
                                cubit.generateViDescription();
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildCategorySpecificInputs(
      CategoryEnum category, AddProductState state, AddProductCubit cubit) {
    switch (category) {
      case CategoryEnum.ram:
        return Column(
          children: [
            buildInputWidget<RAMBus>(
              S.of(context).ramBus,
              TextEditingController(),
              state.productArgument?.ramBus,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(ramBus: value));
              },
              RAMBus.values,
            ),
            buildInputWidget<RAMCapacity>(
              S.of(context).ramCapacity,
              TextEditingController(),
              state.productArgument?.ramCapacity,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(ramCapacity: value));
              },
              RAMCapacity.values,
            ),
            buildInputWidget<RAMType>(
              S.of(context).ramType,
              TextEditingController(),
              state.productArgument?.ramType,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(ramType: value));
              },
              RAMType.values,
            ),
          ],
        );
      case CategoryEnum.cpu:
        return Column(
          children: [
            buildInputWidget<CPUFamily>(
              S.of(context).cpuFamily,
              TextEditingController(),
              state.productArgument?.family,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(family: value));
              },
              CPUFamily.values,
            ),
            buildInputWidget<int>(
              S.of(context).cpuCore,
              cpuCoreController,
              state.productArgument?.core,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(core: value));
              },
            ),
            buildInputWidget<int>(
              S.of(context).cpuThread,
              cpuThreadController,
              state.productArgument?.thread,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(thread: value));
              },
            ),
            buildInputWidget<double>(
              S.of(context).cpuClockSpeed,
              cpuClockSpeedController,
              state.productArgument?.cpuClockSpeed,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(cpuClockSpeed: value));
              },
            ),
          ],
        );
      case CategoryEnum.psu:
        return Column(
          children: [
            buildInputWidget<int>(
              S.of(context).psuWattage,
              psuWattageController,
              state.productArgument?.wattage,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(wattage: value));
              },
            ),
            buildInputWidget<PSUEfficiency>(
              S.of(context).psuEfficiency,
              TextEditingController(),
              state.productArgument?.efficiency,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(efficiency: value));
              },
              PSUEfficiency.values,
            ),
            buildInputWidget<PSUModular>(
              S.of(context).psuModular,
              TextEditingController(),
              state.productArgument?.modular,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(modular: value));
              },
              PSUModular.values,
            ),
          ],
        );
      case CategoryEnum.gpu:
        return Column(
          children: [
            buildInputWidget<GPUSeries>(
              S.of(context).gpuSeries,
              TextEditingController(),
              state.productArgument?.gpuSeries,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(gpuSeries: value));
              },
              GPUSeries.values,
            ),
            buildInputWidget<GPUCapacity>(
              S.of(context).gpuCapacity,
              TextEditingController(),
              state.productArgument?.gpuCapacity,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(gpuCapacity: value));
              },
              GPUCapacity.values,
            ),
            buildInputWidget<GPUBus>(
              S.of(context).gpuBus,
              TextEditingController(),
              state.productArgument?.gpuBus,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(gpuBus: value));
              },
              GPUBus.values,
            ),
            buildInputWidget<double>(
              S.of(context).gpuClockSpeed,
              gpuClockSpeedController,
              state.productArgument?.gpuClockSpeed,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(gpuClockSpeed: value));
              },
            ),
          ],
        );
      case CategoryEnum.mainboard:
        return Column(
          children: [
            buildInputWidget<MainboardFormFactor>(
              S.of(context).formFactor,
              TextEditingController(),
              state.productArgument?.formFactor,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(formFactor: value));
              },
              MainboardFormFactor.values,
            ),
            buildInputWidget<MainboardSeries>(
              S.of(context).series,
              TextEditingController(),
              state.productArgument?.mainboardSeries,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(mainboardSeries: value));
              },
              MainboardSeries.values,
            ),
            buildInputWidget<MainboardCompatibility>(
              S.of(context).compatibility,
              TextEditingController(),
              state.productArgument?.compatibility,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(compatibility: value));
              },
              MainboardCompatibility.values,
            ),
          ],
        );
      case CategoryEnum.drive:
        return Column(
          children: [
            buildInputWidget<DriveType>(
              S.of(context).driveType,
              TextEditingController(),
              state.productArgument?.driveType,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(driveType: value));
              },
              DriveType.values,
            ),
            buildInputWidget<DriveCapacity>(
              S.of(context).driveCapacity,
              TextEditingController(),
              state.productArgument?.driveCapacity,
              (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(driveCapacity: value));
              },
              DriveCapacity.values,
            ),
          ],
        );
      default:
        return Container();
    }
  }

  void setProductName(String value) {
    productNameController.text = value;
  }

  void setImportPrice(double value) {
    importPriceController.text = value.toString();
  }

  void setSellingPrice(double value) {
    sellingPriceController.text = value.toString();
  }

  void setDiscount(double value) {
    discountController.text = value.toString();
  }

  void setStock(int value) {
    stockController.text = value.toString();
  }

  void setCpuCore(int value) {
    cpuCoreController.text = value.toString();
  }

  void setCpuThread(int value) {
    cpuThreadController.text = value.toString();
  }

  void setCpuClockSpeed(double value) {
    cpuClockSpeedController.text = value.toString();
  }

  void setPsuWattage(int value) {
    psuWattageController.text = value.toString();
  }

  void setGpuClockSpeed(double value) {
    gpuClockSpeedController.text = value.toString();
  }
}

Widget buildInputWidget<T>(
    String propertyName,
    TextEditingController controller,
    T? propertyValue,
    void Function(T?) onChanged,
    [List<T>? enumValues]) {
  return Builder(builder: (BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (T == DateTime) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(propertyName, style: AppTextStyle.smallText),
          GestureDetector(
            onTap: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: propertyValue as DateTime? ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: colorScheme.primary,
                        onPrimary: colorScheme.onPrimary,
                        onSurface: colorScheme.onSurface,
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (picked != null) {
                onChanged(picked as T?);
              }
            },
            child: AbsorbPointer(
              child: FieldWithIcon(
                controller: TextEditingController(
                  text: (propertyValue as DateTime?) != null &&
                          propertyValue != null
                      ? DateFormat('dd/MM/yyyy')
                          .format(propertyValue as DateTime)
                      : '',
                ),
                readOnly: true,
                hintText: propertyName,
                fillColor: colorScheme.surface,
                suffixIcon: Icon(Icons.calendar_today,
                    color: colorScheme.onSurfaceVariant),
              ),
            ),
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
            compareFn: (T? d1, T? d2) {
              if (d1 is Manufacturer && d2 is Manufacturer) {
                return d1.manufacturerID == d2.manufacturerID;
              }
              return d1 == d2;
            },
            itemAsString: (T d) =>
                d is Manufacturer ? d.manufacturerName : d.toString(),
            onChanged: (value) {
              if (value is Manufacturer) {
                final selected = (enumValues as List<Manufacturer>).firstWhere(
                  (m) => m.manufacturerID == value.manufacturerID,
                  orElse: () => value as Manufacturer,
                );
                onChanged(selected as T?);
              } else {
                onChanged(value);
              }
            },
            selectedItem: propertyValue,
            hintText: propertyName,
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
                if (value != null && value > 1) {
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
            hintText: propertyName,
            onChanged: (value) {
              if (value.isEmpty) {
                onChanged(null);
              } else if (T == int) {
                final parsed = int.tryParse(value);
                if (parsed != null) {
                  onChanged(parsed as T?);
                }
              } else if (T == double) {
                if (value == '.' || value.endsWith('.')) return;
                final parsed = double.tryParse(value);
                if (parsed != null) {
                  if (propertyName == "Discount" && parsed > 1) {
                    controller.text = "0";
                    onChanged(1.0 as T?);
                  } else {
                    onChanged(parsed as T?);
                  }
                }
              } else {
                onChanged(value as T?);
              }
            },
            fillColor: colorScheme.surfaceVariant,
            keyboardType: keyboardType,
            inputFormatters: inputFormatters,
          ),
        ],
      );
    }
  });
}
