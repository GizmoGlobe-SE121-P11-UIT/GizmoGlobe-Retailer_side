import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_state.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_view.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:intl/intl.dart';

import '../../../data/database/database.dart';
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
import '../../../objects/product_related/cpu.dart';
import '../../../objects/product_related/drive.dart';
import '../../../objects/product_related/gpu.dart';
import '../../../objects/product_related/mainboard.dart';
import '../../../objects/product_related/product.dart';
import '../../../objects/product_related/psu.dart';
import '../../../objects/product_related/ram.dart';
import '../../../widgets/general/field_with_icon.dart';
import '../../../widgets/general/gradient_dropdown.dart';
import '../../main/main_screen/main_screen_view.dart';
import 'edit_product_state.dart';
import 'edit_product_cubit.dart';


class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({super.key, required this.product});

  static Widget newInstance(Product product) =>
      BlocProvider(
        create: (context) => EditProductCubit(),
        child: EditProductScreen(product: product),
      );


  @override
  State<EditProductScreen> createState() => _EditProductState();
}

class _EditProductState extends State<EditProductScreen> {
  EditProductCubit get cubit => context.read<EditProductCubit>();
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

  @override
  void initState() {
    super.initState();
    cubit.initialize(widget.product);
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
    initTextControllers();
  }

  void initTextControllers() {
    setProductName(widget.product.productName);
    setImportPrice(widget.product.importPrice);
    setSellingPrice(widget.product.sellingPrice);
    setDiscount(widget.product.discount);
    setStock(widget.product.stock);
    switch (widget.product.category) {
      case CategoryEnum.cpu:
        setCpuCore((widget.product as CPU).core);
        setCpuThread((widget.product as CPU).thread);
        setCpuClockSpeed((widget.product as CPU).clockSpeed);
        break;
      case CategoryEnum.psu:
        setPsuWattage((widget.product as PSU).wattage);
        break;
      case CategoryEnum.gpu:
        setGpuClockSpeed((widget.product as GPU).clockSpeed);
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: GradientIconButton(
          icon: Icons.chevron_left,
          onPressed: () => Navigator.pop(context),
          fillColor: Colors.transparent,
        ),
        title: const GradientText(text: 'Edit Product'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                cubit.editProduct();
              },
              icon: const Icon(Icons.save_outlined, size: 20),
              label: const Text('Save'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF202046),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<EditProductCubit, EditProductState>(
        listener: (context, state) {
          if (state.processState == ProcessState.success) {
            showDialog(
              context: context,
              builder:  (context) =>
                  InformationDialog(
                    title: state.dialogName.toString(),
                    content: state.notifyMessage.toString(),
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(),
                        ),
                            (Route<dynamic> route) => false,
                      ).then((_) {
                        MainScreen().setIndex(1);
                      });
                    },
                  ),
            );
          } else {
            if (state.processState == ProcessState.failure) {
              showDialog(
                context: context,
                builder:  (context) =>
                    InformationDialog(
                      title: state.dialogName.toString(),
                      content: state.notifyMessage.toString(),
                      onPressed: () {},
                    ),
              );
            }
          }
          cubit.toIdle();
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image Section - smaller size
                Container(
                  height: MediaQuery.of(context).size.height * 0.25,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Image.network(
                      'https://ramleather.vn/wp-content/uploads/2022/07/woocommerce-placeholder-200x200-1.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // Product Input Section
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
                          const Text(
                            'Basic Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF202046),
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildInputWidget<String>(
                            'Product Name',
                            productNameController,
                            state.productArgument?.productName,
                                (value) {
                              cubit.updateProductArgument(state.productArgument!.copyWith(productName: value));
                            },
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: buildInputWidget<double>(
                                  'Import Price',
                                  importPriceController,
                                  state.productArgument?.importPrice,
                                      (value) {
                                    cubit.updateProductArgument(state.productArgument!.copyWith(importPrice: value));
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: buildInputWidget<double>(
                                  'Selling Price',
                                  sellingPriceController,
                                  state.productArgument?.sellingPrice,
                                      (value) {
                                    cubit.updateProductArgument(state.productArgument!.copyWith(sellingPrice: value));
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: buildInputWidget<double>(
                                  'Discount',
                                  discountController,
                                  state.productArgument?.discount,
                                      (value) {
                                    cubit.updateProductArgument(state.productArgument!.copyWith(discount: value));
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: buildInputWidget<int>(
                                  'Stock',
                                  stockController,
                                  state.productArgument?.stock,
                                      (value) {
                                    final newStatus = value! > 0 ? ProductStatusEnum.active : ProductStatusEnum.outOfStock;
                                    cubit.updateProductArgument(state.productArgument!.copyWith(stock: value, status: newStatus));
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

                // Additional Information Section
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
                          const Text(
                            'Additional Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF202046),
                            ),
                          ),
                          const SizedBox(height: 16),
                          buildInputWidget<DateTime>(
                            'Release Date',
                            TextEditingController(),
                            state.productArgument?.release ?? DateTime.now(),
                                (value) {
                              cubit.updateProductArgument(state.productArgument!.copyWith(release: value));
                            },
                          ),
                          const SizedBox(height: 16),
                          buildInputWidget<CategoryEnum>(
                            'Category',
                            TextEditingController(),
                            state.productArgument?.category,
                                (value) {
                              cubit.updateProductArgument(state.productArgument!.copyWith(category: value));
                            },
                            CategoryEnum.nonEmptyValues,
                          ),
                          const SizedBox(height: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text('Manufacturer', style: AppTextStyle.smallText),
                              const SizedBox(height: 8),
                              DropdownSearch<Manufacturer>(
                                items: (String filter, dynamic infiniteScrollProps) => Database().manufacturerList,
                                compareFn: (Manufacturer? m1, Manufacturer? m2) => m1?.manufacturerID == m2?.manufacturerID,
                                itemAsString: (Manufacturer m) => m.manufacturerName,
                                onChanged: (value) {
                                  cubit.updateProductArgument(state.productArgument!.copyWith(manufacturer: value));
                                },
                                selectedItem: state.productArgument?.manufacturer,
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    hintText: 'Select Manufacturer',
                                    hintStyle: const TextStyle(color: Colors.grey),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: Colors.blue, width: 2),
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFF202046),
                                  ),
                                ),
                                popupProps: PopupProps.menu(
                                  showSearchBox: true,
                                  searchFieldProps: TextFieldProps(
                                    decoration: InputDecoration(
                                      hintText: 'Search manufacturer...',
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Text('Status', style: AppTextStyle.smallText),
                              const SizedBox(height: 8),
                              BlocBuilder<EditProductCubit, EditProductState>(
                                builder: (context, state) {
                                  final status = (state.productArgument?.stock ?? 0) > 0
                                      ? ProductStatusEnum.active
                                      : ProductStatusEnum.outOfStock;

                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: status == ProductStatusEnum.active ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: status == ProductStatusEnum.active ? Colors.green : Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          status == ProductStatusEnum.active ? Icons.check_circle : Icons.error,
                                          color: status == ProductStatusEnum.active ? Colors.green : Colors.red,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          status == ProductStatusEnum.active ? 'Active' : 'Out of Stock',
                                          style: TextStyle(
                                            color: status == ProductStatusEnum.active ? Colors.green : Colors.red,
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

                // Category Specific Section
                if (state.productArgument?.category != null && state.productArgument?.category != CategoryEnum.empty)
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
                              '${state.productArgument?.category.toString()} Specifications',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF202046),
                              ),
                            ),
                            const SizedBox(height: 16),
                            buildCategorySpecificInputs(
                              state.productArgument?.category ?? CategoryEnum.empty,
                              state,
                              cubit,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 32), // Bottom padding
              ],
            ),
          );
        },
      ),
    );
  }

  Widget buildCategorySpecificInputs(CategoryEnum category, EditProductState state, EditProductCubit cubit) {
    switch (category) {
      case CategoryEnum.ram:
        return Column(
          children: [
            buildInputWidget<RAMBus>(
              'RAM Bus',
              TextEditingController(),
              state.productArgument?.ramBus,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(ramBus: value));
              },
              RAMBus.values,
            ),
            buildInputWidget<RAMCapacity>(
              'RAM Capacity',
              TextEditingController(),
              state.productArgument?.ramCapacity,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(ramCapacity: value));
              },
              RAMCapacity.values,
            ),
            buildInputWidget<RAMType>(
              'RAM Type',
              TextEditingController(),
              state.productArgument?.ramType,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(ramType: value));
              },
              RAMType.values,
            ),
          ],
        );
      case CategoryEnum.cpu:
        return Column(
          children: [
            buildInputWidget<CPUFamily>(
              'CPU Family',
              TextEditingController(),
              state.productArgument?.family,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(family: value));
              },
              CPUFamily.values,
            ),
            buildInputWidget<int>(
              'CPU Core',
              cpuCoreController,
              state.productArgument?.core,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(core: value));
              },
            ),
            buildInputWidget<int>(
              'CPU Thread',
              cpuThreadController,
              state.productArgument?.thread,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(thread: value));
              },
            ),
            buildInputWidget<double>(
              'CPU Clock Speed',
              cpuClockSpeedController,
              state.productArgument?.cpuClockSpeed,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(cpuClockSpeed: value));
              },
            ),
          ],
        );
      case CategoryEnum.psu:
        return Column(
          children: [
            buildInputWidget<int>(
              'PSU Wattage',
              psuWattageController,
              state.productArgument?.wattage,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(wattage: value));
              },
            ),
            buildInputWidget<PSUEfficiency>(
              'PSU Efficiency',
              TextEditingController(),
              state.productArgument?.efficiency,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(efficiency: value));
              },
              PSUEfficiency.values,
            ),
            buildInputWidget<PSUModular>(
              'PSU Modular',
              TextEditingController(),
              state.productArgument?.modular,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(modular: value));
              },
              PSUModular.values,
            ),
          ],
        );
      case CategoryEnum.gpu:
        return Column(
          children: [
            buildInputWidget<GPUSeries>(
              'GPU Series',
              TextEditingController(),
              state.productArgument?.gpuSeries,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(gpuSeries: value));
              },
              GPUSeries.values,
            ),
            buildInputWidget<GPUCapacity>(
              'GPU Capacity',
              TextEditingController(),
              state.productArgument?.gpuCapacity,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(gpuCapacity: value));
              },
              GPUCapacity.values,
            ),
            buildInputWidget<GPUBus>(
              'GPU Bus',
              TextEditingController(),
              state.productArgument?.gpuBus,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(gpuBus: value));
              },
              GPUBus.values,
            ),
            buildInputWidget<double>(
              'GPU Clock Speed',
              gpuClockSpeedController,
              state.productArgument?.gpuClockSpeed,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(gpuClockSpeed: value));
              },
            ),
          ],
        );
      case CategoryEnum.mainboard:
        return Column(
          children: [
            buildInputWidget<MainboardFormFactor>(
              'Form Factor',
              TextEditingController(),
              state.productArgument?.formFactor,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(formFactor: value));
              },
              MainboardFormFactor.values,
            ),
            buildInputWidget<MainboardSeries>(
              'Series',
              TextEditingController(),
              state.productArgument?.mainboardSeries,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(mainboardSeries: value));
              },
              MainboardSeries.values,
            ),
            buildInputWidget<MainboardCompatibility>(
              'Compatibility',
              TextEditingController(),
              state.productArgument?.compatibility,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(compatibility: value));
              },
              MainboardCompatibility.values,
            ),
          ],
        );
      case CategoryEnum.drive:
        return Column(
          children: [
            buildInputWidget<DriveType>(
              'Drive Type',
              TextEditingController(),
              state.productArgument?.driveType,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(driveType: value));
              },
              DriveType.values,
            ),
            buildInputWidget<DriveCapacity>(
              'Drive Capacity',
              TextEditingController(),
              state.productArgument?.driveCapacity,
                  (value) {
                cubit.updateProductArgument(state.productArgument!.copyWith(driveCapacity: value));
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
    [List<T>? enumValues]
    ) {
  return Builder(
      builder: (BuildContext context) {
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
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF202046),    // header background color
                            onPrimary: Colors.white,       // header text color
                            onSurface: Colors.black,       // body text color
                          ),
                          textButtonTheme: TextButtonThemeData(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF202046), // button text color
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
                      text: (propertyValue as DateTime?)?.toString().split(' ')[0] ?? '',
                    ),
                    readOnly: true,
                    hintText: 'Select $propertyName',
                    fillColor: const Color(0xFF202046),
                    suffixIcon: const Icon(Icons.calendar_today),
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
                compareFn: (T? d1, T? d2) => d1 == d2,
                itemAsString: (T d) => d.toString(),
                onChanged: onChanged,
                selectedItem: propertyValue,
                hintText: 'Select $propertyName',
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
            inputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))];
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
                hintText: 'Enter $propertyName',
                onSubmitted: (value) {
                  if (value.isEmpty) {
                    onChanged(null);
                  } else if (T == int) {
                    onChanged(int.tryParse(value) as T?);
                  } else if (T == double) {
                    onChanged(double.tryParse(value) as T?);
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
      }
  );
}

