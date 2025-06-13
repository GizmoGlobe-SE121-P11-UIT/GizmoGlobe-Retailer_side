import 'package:flutter/foundation.dart';

import '../../../objects/product_related/ram.dart';
import '../../../objects/product_related/cpu.dart';
import '../../../objects/product_related/psu.dart';
import '../../../objects/product_related/gpu.dart';
import '../../../objects/product_related/mainboard.dart';
import '../../../objects/product_related/drive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_tab/product_tab_cubit.dart';
import 'package:intl/intl.dart';

import '../../../data/firebase/firebase.dart';
import '../../../objects/product_related/product_factory.dart';
import '../../../data/database/database.dart'; // Import the Database class

class AddEditProductDialog extends StatefulWidget {
  final Product? product;

  const AddEditProductDialog({super.key, this.product});

  @override
  State<AddEditProductDialog> createState() => _AddEditProductDialogState();
}

class _AddEditProductDialogState extends State<AddEditProductDialog> {
  final Database _database = Database();
  late CategoryEnum _selectedCategory;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController productNameController;
  late TextEditingController importPriceController;
  late TextEditingController sellingPriceController;
  late TextEditingController discountController;
  late TextEditingController releaseDateController;
  late TextEditingController stockController;

  // Category specific controllers
  // RAM
  TextEditingController? ramBusController;
  TextEditingController? ramCapacityController;
  TextEditingController? ramTypeController;
  // CPU
  TextEditingController? cpuFamilyController;
  TextEditingController? cpuCoreController;
  TextEditingController? cpuThreadController;
  TextEditingController? cpuClockSpeedController;
  // PSU
  TextEditingController? psuWattageController;
  TextEditingController? psuEfficiencyController;
  TextEditingController? psuModularController;
  // GPU
  TextEditingController? gpuSeriesController;
  TextEditingController? gpuCapacityController;
  TextEditingController? gpuBusWidthController;
  TextEditingController? gpuClockSpeedController;
  // Mainboard
  TextEditingController? mainboardFormFactorController;
  TextEditingController? mainboardSeriesController;
  TextEditingController? mainboardCompatibilityController;
  // Drive
  TextEditingController? driveTypeController;
  TextEditingController? driveCapacityController;

  @override
  void initState() {
    super.initState();
    productNameController = TextEditingController(text: widget.product?.productName);
    importPriceController = TextEditingController(text: widget.product?.importPrice.toString());
    sellingPriceController = TextEditingController(text: widget.product?.sellingPrice.toString());
    discountController = TextEditingController(text: widget.product?.discount.toString());
    releaseDateController = TextEditingController(text: widget.product?.release != null ? DateFormat('yyyy-MM-dd').format(widget.product!.release) : '');
    stockController = TextEditingController(text: widget.product?.stock.toString());

    _selectedCategory = widget.product?.category ?? CategoryEnum.ram; // Default to RAM for adding

    // Initialize category specific controllers
    if (widget.product?.category == CategoryEnum.ram && widget.product is RAM) {
      ramBusController = TextEditingController(text: (widget.product as RAM).bus.name);
      ramCapacityController = TextEditingController(text: (widget.product as RAM).capacity.name);
      ramTypeController = TextEditingController(text: (widget.product as RAM).ramType.name);
    }
    if (widget.product?.category == CategoryEnum.cpu && widget.product is CPU) {
      cpuFamilyController = TextEditingController(text: (widget.product as CPU).family.name);
      cpuCoreController = TextEditingController(text: (widget.product as CPU).core.toString());
      cpuThreadController = TextEditingController(text: (widget.product as CPU).thread.toString());
      cpuClockSpeedController = TextEditingController(text: (widget.product as CPU).clockSpeed.toString());
    }
    if (widget.product?.category == CategoryEnum.psu && widget.product is PSU) {
      psuWattageController = TextEditingController(text: (widget.product as PSU).wattage.toString());
      psuEfficiencyController = TextEditingController(text: (widget.product as PSU).efficiency.name);
      psuModularController = TextEditingController(text: (widget.product as PSU).modular.name);
    }
    if (widget.product?.category == CategoryEnum.gpu && widget.product is GPU) {
      gpuSeriesController = TextEditingController(text: (widget.product as GPU).series.name);
      gpuCapacityController = TextEditingController(text: (widget.product as GPU).capacity.name);
      gpuBusWidthController = TextEditingController(text: (widget.product as GPU).bus.name);
      gpuClockSpeedController = TextEditingController(text: (widget.product as GPU).clockSpeed.toString());
    }
    if (widget.product?.category == CategoryEnum.mainboard && widget.product is Mainboard) {
      mainboardFormFactorController = TextEditingController(text: (widget.product as Mainboard).formFactor.name);
      mainboardSeriesController = TextEditingController(text: (widget.product as Mainboard).series.name);
      mainboardCompatibilityController = TextEditingController(text: (widget.product as Mainboard).compatibility.name);
    }
    if (widget.product?.category == CategoryEnum.drive && widget.product is Drive) {
      driveTypeController = TextEditingController(text: (widget.product as Drive).type.name);
      driveCapacityController = TextEditingController(text: (widget.product as Drive).capacity.name);
    }
  }

  List<Widget> _buildCategorySpecificFields() {
    switch (_selectedCategory) {
      case CategoryEnum.ram:
        return [
          TextFormField(controller: ramBusController, decoration: const InputDecoration(labelText: 'RAM Bus'), validator: _validateField), //Tốc độ bus RAM
          TextFormField(controller: ramCapacityController, decoration: const InputDecoration(labelText: 'RAM Capacity'), validator: _validateField), //Dung lượng RAM
          TextFormField(controller: ramTypeController, decoration: const InputDecoration(labelText: 'RAM Type'), validator: _validateField), //Loại RAM
        ];
      case CategoryEnum.cpu:
        return [
          TextFormField(controller: cpuFamilyController, decoration: const InputDecoration(labelText: 'CPU Family'), validator: _validateField), //Thương hiệu CPU
          TextFormField(controller: cpuCoreController, decoration: const InputDecoration(labelText: 'CPU Core'), keyboardType: TextInputType.number, validator: _validateField), //Số nhân CPU
          TextFormField(controller: cpuThreadController, decoration: const InputDecoration(labelText: 'CPU Thread'), keyboardType: TextInputType.number, validator: _validateField), //Số luồng CPU
          TextFormField(controller: cpuClockSpeedController, decoration: const InputDecoration(labelText: 'CPU Clock Speed'), keyboardType: TextInputType.number, validator: _validateField), //Tốc độ xung nhịp CPU
        ];
      case CategoryEnum.psu:
        return [
          TextFormField(controller: psuWattageController, decoration: const InputDecoration(labelText: 'PSU Wattage'), keyboardType: TextInputType.number, validator: _validateField), //Công suất PSU
          TextFormField(controller: psuEfficiencyController, decoration: const InputDecoration(labelText: 'PSU Efficiency'), validator: _validateField), //Hiệu suất PSU
          TextFormField(controller: psuModularController, decoration: const InputDecoration(labelText: 'PSU Modular'), validator: _validateField), //Loại PSU
        ];
      case CategoryEnum.gpu:
        return [
          TextFormField(controller: gpuSeriesController, decoration: const InputDecoration(labelText: 'GPU Series'), validator: _validateField), //Thương hiệu GPU
          TextFormField(controller: gpuCapacityController, decoration: const InputDecoration(labelText: 'GPU Capacity'), validator: _validateField), //Dung lượng GPU
          TextFormField(controller: gpuBusWidthController, decoration: const InputDecoration(labelText: 'GPU Bus Width'), validator: _validateField), //Băng thông GPU
          TextFormField(controller: gpuClockSpeedController, decoration: const InputDecoration(labelText: 'GPU Clock Speed'), keyboardType: TextInputType.number, validator: _validateField), //Tốc độ xung nhịp GPU
        ];
      case CategoryEnum.mainboard:
        return [
          TextFormField(controller: mainboardFormFactorController, decoration: const InputDecoration(labelText: 'Mainboard Form Factor'), validator: _validateField), //Kích thước mainboard
          TextFormField(controller: mainboardSeriesController, decoration: const InputDecoration(labelText: 'Mainboard Series'), validator: _validateField), //Thương hiệu mainboard
          TextFormField(controller: mainboardCompatibilityController, decoration: const InputDecoration(labelText: 'Mainboard Compatibility'), validator: _validateField), //Tương thích mainboard
        ];
      case CategoryEnum.drive:
        return [
          TextFormField(controller: driveTypeController, decoration: const InputDecoration(labelText: 'Drive Type'), validator: _validateField), //Loại ổ cứng
          TextFormField(controller: driveCapacityController, decoration: const InputDecoration(labelText: 'Drive Capacity'), validator: _validateField), //Dung lượng ổ cứng
        ];
      default:
        return [];
    }
  }
  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required'; //Trường này là bắt buộc
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'), //Thêm sản phẩm hoặc Chỉnh sửa sản phẩm
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CategoryEnum>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'), //Danh mục
                items: CategoryEnum.nonEmptyValues.map((CategoryEnum category) {
                  return DropdownMenuItem<CategoryEnum>(
                    value: category,
                    child: Text(category.toString()),
                  );
                }).toList(),
                onChanged: (CategoryEnum? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),
              TextFormField(controller: productNameController, decoration: const InputDecoration(labelText: 'Product Name'), validator: _validateField), //Tên sản phẩm
              TextFormField(controller: importPriceController, decoration: const InputDecoration(labelText: 'Import Price'), keyboardType: TextInputType.number, validator: _validateField), //Giá nhập
              TextFormField(controller: sellingPriceController, decoration: const InputDecoration(labelText: 'Selling Price'), keyboardType: TextInputType.number, validator: _validateField), //Giá bán
              TextFormField(controller: discountController, decoration: const InputDecoration(labelText: 'Discount'), keyboardType: TextInputType.number, validator: _validateField), //Giá khuyến mãi
              TextFormField(
                controller: releaseDateController,
                decoration: const InputDecoration(labelText: 'Release Date'), //Ngày phát hành
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2025));
                  if (pickedDate != null) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate); // Format date as yyyy-MM-dd
                    setState(() {
                      releaseDateController.text = formattedDate;
                    });
                  }
                },
                validator: _validateField,
              ),
              TextFormField(controller: stockController, decoration: const InputDecoration(labelText: 'Stock'), keyboardType: TextInputType.number, validator: _validateField), //Số lượng tồn kho
              const SizedBox(height: 16),
              ..._buildCategorySpecificFields(),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'), // Hủy
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save'), // Lưu
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              // Prepare product data
              Map<String, dynamic> productData = {
                'productName': productNameController.text,
                'importPrice': double.parse(importPriceController.text),
                'sellingPrice': double.parse(sellingPriceController.text),
                'discount': double.parse(discountController.text),
                'release': DateTime.parse(releaseDateController.text),
                'stock': int.parse(stockController.text),
                'manufacturer': _database.manufacturerList[0], // need to implement pick manufacturer
                // Add other common fields if necessary
              };

              // Add category-specific fields
              switch (_selectedCategory) {
                case CategoryEnum.ram:
                  productData['bus'] = ramBusController?.text;
                  productData['capacity'] = ramCapacityController?.text;
                  productData['ramType'] = ramTypeController?.text;
                  break;
                case CategoryEnum.cpu:
                  productData['family'] = cpuFamilyController?.text;
                  productData['core'] = int.tryParse(cpuCoreController?.text ?? '') ?? 0;
                  productData['thread'] = int.tryParse(cpuThreadController?.text ?? '') ?? 0;
                  productData['clockSpeed'] = double.tryParse(cpuClockSpeedController?.text ?? '') ?? 0.0;
                  break;
                case CategoryEnum.psu:
                  productData['wattage'] = int.tryParse(psuWattageController?.text ?? '') ?? 0;
                  productData['efficiency'] = psuEfficiencyController?.text;
                  productData['modular'] = psuModularController?.text;
                  break;
                case CategoryEnum.gpu:
                  productData['series'] = gpuSeriesController?.text;
                  productData['capacity'] = gpuCapacityController?.text;
                  productData['busWidth'] = gpuBusWidthController?.text;
                  productData['clockSpeed'] = double.tryParse(gpuClockSpeedController?.text ?? '') ?? 0.0;
                  break;
                case CategoryEnum.mainboard:
                  productData['formFactor'] = mainboardFormFactorController?.text;
                  productData['series'] = mainboardSeriesController?.text;
                  productData['compatibility'] = mainboardCompatibilityController?.text;
                  break;
                case CategoryEnum.drive:
                  productData['type'] = driveTypeController?.text;
                  productData['capacity'] = driveCapacityController?.text;
                  break;
                case CategoryEnum.empty:
                  throw UnimplementedError();
              }
              Product product = ProductFactory.createProduct(_selectedCategory, productData);

              // Access the Cubit and call the add or edit function
              final tabCubit = context.read<TabCubit>(); // Or ProductScreenCubit if more appropriate
              if (widget.product == null) {
                // Handle add logic using tabCubit
                if (kDebugMode) {
                  print('Adding product: $productData');
                } // Đang thêm sản phẩm
                await Firebase().addProduct(product);
                tabCubit.applyFilters();
                // tabCubit.addProduct(productData); // Implement this in your Cubit
              } else {
                // Handle edit logic using tabCubit, include product ID
                product.productID = widget.product!.productID;
                if (kDebugMode) {
                  print('Editing product: $productData');
                } //Chỉnh sửa sản phẩm
                await Firebase().updateProduct(product);
                tabCubit.applyFilters();
                // tabCubit.updateProduct(productData); // Implement this in your Cubit
              }

              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}