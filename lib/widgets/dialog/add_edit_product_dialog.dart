import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gizmoglobe_client/objects/product_related/mainboard_related/storage_slot.dart';

import '../../objects/product_related/mainboard_related/io_port.dart';
import '../../objects/product_related/mainboard_related/pcie_slot.dart';
import '../../objects/product_related/psu_related/connector.dart';
import '../../objects/product_related/ram_related/ram.dart';
import '../../objects/product_related/cpu_related/cpu.dart';
import '../../objects/product_related/psu_related/psu.dart';
import '../../objects/product_related/gpu_related/gpu.dart';
import '../../objects/product_related/mainboard_related/mainboard.dart';
import '../../objects/product_related/drive_related/drive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_tab/product_tab_cubit.dart';
import 'package:intl/intl.dart';

import '../../../data/firebase/firebase.dart';
import '../../../objects/product_related/product_factory.dart';
import '../../../data/database/database.dart';

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
  TextEditingController? busController;
  TextEditingController? typeController;
  TextEditingController? stickCountController;
  TextEditingController? clLatencyController;
  TextEditingController? capacityController;
  // CPU
  TextEditingController? cpuSeriesController;
  TextEditingController? socketController;
  TextEditingController? coreController;
  TextEditingController? threadController;
  TextEditingController? baseClockController;
  TextEditingController? turboClockController;
  // PSU
  TextEditingController? maxWattageController;
  TextEditingController? efficiencyController;
  TextEditingController? modularityController;
  List<ConnectorControllers> connectorControllers = [];
  // GPU
  TextEditingController? gpuSeriesController;
  TextEditingController? gpuVersionController;
  TextEditingController? tdpController;
  List<IOPortControllers> ioPortsControllers = [];
  // Mainboard
  TextEditingController? mainboardFormFactorController;
  TextEditingController? chipsetCodeController;
  StorageSlotControllers? storageSlotControllerSingle;
  TextEditingController? formFactorController;
  List<PCIeSlotControllers> pcieSlotsController = [];
  List<StorageSlotControllers> storageSlotController = [];
  List<IOPortControllers> ioPortsController = [];
  // Drive
  TextEditingController? genController;
  TextEditingController? interfaceTypeController;
  TextEditingController? writeMbpsController;
  TextEditingController? readMbpsController;
  TextEditingController? driveTypeController;
  TextEditingController? driveFormFactorController;

  @override
  void initState() {
    super.initState();
    productNameController = TextEditingController(text: widget.product?.productName);
    importPriceController = TextEditingController(text: widget.product?.importPrice.toString());
    sellingPriceController = TextEditingController(text: widget.product?.sellingPrice.toString());
    discountController = TextEditingController(text: widget.product?.discount.toString());
    releaseDateController = TextEditingController(text: widget.product?.release != null ? DateFormat('yyyy-MM-dd').format(widget.product!.release) : '');
    stockController = TextEditingController(text: widget.product?.stock.toString());

    _selectedCategory = widget.product?.category ?? CategoryEnum.empty;

    // Initialize category specific controllers
    if (widget.product?.category == CategoryEnum.ram && widget.product is RAM) {
      busController = TextEditingController(text: (widget.product as RAM).bus.toString());
      typeController = TextEditingController(text: (widget.product as RAM).type.toString());
      stickCountController = TextEditingController(text: (widget.product as RAM).kitStickCount.toString());
      capacityController = TextEditingController(text: (widget.product as RAM).capacityPerStickGb.toString());
      clLatencyController = TextEditingController(text: (widget.product as RAM).clLatency.toString());
    }
    if (widget.product?.category == CategoryEnum.cpu && widget.product is CPU) {
      cpuSeriesController = TextEditingController(text: (widget.product as CPU).series.toString());
      socketController = TextEditingController(text: (widget.product as CPU).socket.toString());
      coreController = TextEditingController(text: (widget.product as CPU).core.toString());
      threadController = TextEditingController(text: (widget.product as CPU).thread.toString());
      baseClockController = TextEditingController(text: (widget.product as CPU).baseClock.toString());
      turboClockController = TextEditingController(text: (widget.product as CPU).turboClock.toString());
      tdpController = TextEditingController(text: (widget.product as CPU).tdp.toString());
    }
    if (widget.product?.category == CategoryEnum.psu && widget.product is PSU) {
      maxWattageController = TextEditingController(text: (widget.product as PSU).maxWattage.toString());
      efficiencyController = TextEditingController(text: (widget.product as PSU).efficiency.toString());
      modularityController = TextEditingController(text: (widget.product as PSU).modularity.toString());

      final connectors = (widget.product as PSU).connectors;
      if (connectors.isNotEmpty) {
        connectorControllers = connectors
            .map((c) => ConnectorControllers(
          type: c.type,
          quantity: c.quantity.toString(),
        ))
            .toList();
      } else {
        connectorControllers = [ConnectorControllers()];
      }
    }
    if (widget.product?.category == CategoryEnum.gpu && widget.product is GPU) {
      gpuSeriesController =
          TextEditingController(text: (widget.product as GPU).series.name);
      gpuVersionController =
          TextEditingController(text: (widget.product as GPU).version.name);
      capacityController = TextEditingController(
          text: (widget.product as GPU).memory.toString());
      tdpController =
          TextEditingController(text: (widget.product as GPU).tdp.toString());
      turboClockController = TextEditingController(
          text: (widget.product as GPU).boostClock.toString());

      final ioPorts = (widget.product as GPU).ports;
      if (ioPorts.isNotEmpty) {
        ioPortsControllers = ioPorts
            .map((port) =>
            IOPortControllers(
              port: port.port,
              quantity: port.quantity.toString(),
            ))
            .toList();
      } else {
        ioPortsControllers = [IOPortControllers()];
      }
    }
    if (widget.product?.category == CategoryEnum.mainboard && widget.product is Mainboard) {
      mainboardFormFactorController = TextEditingController(
          text: (widget.product as Mainboard).formFactor.toString());
      chipsetCodeController = TextEditingController(
          text: (widget.product as Mainboard).chipsetCode.toString());

      final pcieSlots = (widget.product as Mainboard).pcieSlots;
      if (pcieSlots.isNotEmpty) {
        pcieSlotsController = pcieSlots
            .map((slot) =>
            PCIeSlotControllers(
              physicalSize: slot.physicalSize.toString(),
              electricalSpeed: slot.electricalSpeed.toString(),
              gen: slot.gen.toString(),
              quantity: slot.quantity.toString(),
            ))
            .toList();
      } else {
        pcieSlotsController = [PCIeSlotControllers()];
      }

      final storageSlots = (widget.product as Mainboard).storageSlot;
      storageSlotControllerSingle = StorageSlotControllers(
        m2Slots: storageSlots.m2Slots.toString(),
        sataPorts: storageSlots.sataPorts.toString(),
      );
    }
    if (widget.product?.category == CategoryEnum.drive && widget.product is Drive) {
      genController = TextEditingController(text: (widget.product as Drive).gen.toString());
      interfaceTypeController = TextEditingController(text: (widget.product as Drive).interfaceType.toString());
      driveTypeController = TextEditingController(text: (widget.product as Drive).driveType.toString());
      driveFormFactorController = TextEditingController(text: (widget.product as Drive).formFactor.toString());
      capacityController = TextEditingController(text: (widget.product as Drive).memoryGb.toString());
      writeMbpsController = TextEditingController(text: (widget.product as Drive).writeMbps.toString());
      readMbpsController = TextEditingController(text: (widget.product as Drive).readMbps.toString());
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    productNameController.dispose();
    importPriceController.dispose();
    sellingPriceController.dispose();
    discountController.dispose();
    releaseDateController.dispose();
    stockController.dispose();
    gpuSeriesController?.dispose();
    mainboardFormFactorController?.dispose();
    driveTypeController?.dispose();
    stickCountController?.dispose();
    super.dispose();
  }

  List<Widget> _buildCategorySpecificFields() {
    switch (_selectedCategory) {
      case CategoryEnum.ram:
        return [
          TextFormField(
              controller: typeController,
              decoration: const InputDecoration(labelText: 'RAM type'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: busController,
              decoration: const InputDecoration(labelText: 'RAM bus'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: capacityController,
              decoration: const InputDecoration(labelText: 'Capacity per stick (GB)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: stickCountController,
              decoration: const InputDecoration(labelText: 'RAM stick count'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: clLatencyController,
              decoration: const InputDecoration(labelText: 'CL latency'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
        ];
      case CategoryEnum.cpu:
        return [
          TextFormField(
              controller: cpuSeriesController,
              decoration: const InputDecoration(labelText: 'CPU series'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: coreController,
              decoration: const InputDecoration(labelText: 'Number of CPU cores'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: threadController,
              decoration: const InputDecoration(labelText: 'Number of CPU threads'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: baseClockController,
              decoration: const InputDecoration(labelText: 'CPU base clock speed (GHz)'),
              keyboardType: TextInputType.number,
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: turboClockController,
              decoration: const InputDecoration(labelText: 'CPU turbo clock speed (GHz)'),
              keyboardType: TextInputType.number,
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: tdpController,
              decoration: const InputDecoration(labelText: 'CPU max tdp (W)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: socketController,
              decoration: const InputDecoration(labelText: 'CPU socket'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
        ];
      case CategoryEnum.psu:
        return [
          TextFormField(
              controller: maxWattageController,
              decoration: const InputDecoration(labelText: 'PSU max wattage (W)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: efficiencyController,
              decoration: const InputDecoration(labelText: 'PSU efficiency'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: modularityController,
              decoration: const InputDecoration(labelText: 'PSU modularity'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
          ...connectorControllers.asMap().entries.map((entry) {
            final i = entry.key;
            final controller = entry.value;
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.typeController,
                    decoration: const InputDecoration(labelText: 'Type'),
                    validator: _validateField,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: controller.quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateField,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      connectorControllers.removeAt(i);
                    });
                  },
                ),
              ],
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Connector'),
              onPressed: () {
                setState(() {
                  connectorControllers.add(ConnectorControllers());
                });
              },
            ),
          ),
        ];
      case CategoryEnum.gpu:
        return [
          TextFormField(
              controller: gpuSeriesController,
              decoration: const InputDecoration(labelText: 'GPU series'),
              validator: _validateField
          ),
          const SizedBox(width: 8),
          TextFormField(
              controller: gpuVersionController,
              decoration: const InputDecoration(labelText: 'GPU version'),
              validator: _validateField
          ),
          const SizedBox(width: 8),
          TextFormField(
              controller: capacityController,
              decoration: const InputDecoration(labelText: 'GPU memory capacity (GB)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(width: 8),
          TextFormField(
              controller: tdpController,
              decoration: const InputDecoration(labelText: 'GPU max tdp (W)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(width: 8),
          TextFormField(
              controller: turboClockController,
              decoration: const InputDecoration(labelText: 'GPU boost clock speed (GHz)'),
              keyboardType: TextInputType.number,
              validator: _validateField
          ),
          const SizedBox(width: 8),
          ...ioPortsControllers.asMap().entries.map((entry) {
            final i = entry.key;
            final controller = entry.value;
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.portController,
                    decoration: const InputDecoration(labelText: 'Port'),
                    validator: _validateField,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: controller.quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateField,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      ioPortsControllers.removeAt(i);
                    });
                  },
                ),
              ],
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add IO Port'),
              onPressed: () {
                setState(() {
                  ioPortsControllers.add(IOPortControllers());
                });
              },
            ),
          ),
        ];
      case CategoryEnum.mainboard:
        return [
          TextFormField(
              controller: chipsetCodeController,
              decoration: const InputDecoration(labelText: 'Chipset code'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: mainboardFormFactorController,
              decoration: const InputDecoration(labelText: 'Mainboard form factor'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: typeController,
            decoration: const InputDecoration(labelText: 'RAM type'),
            validator: _validateField,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: stickCountController,
            decoration: const InputDecoration(labelText: 'RAM slot count'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validateField,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: capacityController,
            decoration: const InputDecoration(labelText: 'Max single DIMM capacity (GB)'),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validateField,
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: storageSlotControllerSingle?.m2SlotsController,
              decoration: const InputDecoration(labelText: 'Number of M.2 slots'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: storageSlotControllerSingle?.sataPortsController,
              decoration: const InputDecoration(labelText: 'Number of SATA ports'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          ...ioPortsControllers.asMap().entries.map((entry) {
            final i = entry.key;
            final controller = entry.value;
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.portController,
                    decoration: const InputDecoration(labelText: 'Port'),
                    validator: _validateField,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: controller.quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateField,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      ioPortsControllers.removeAt(i);
                    });
                  },
                ),
              ],
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add IO Port'),
              onPressed: () {
                setState(() {
                  ioPortsControllers.add(IOPortControllers());
                });
              },
            ),
          ),
          const SizedBox(height: 8),

          ...pcieSlotsController.asMap().entries.map((entry) {
            final i = entry.key;
            final controller = entry.value;
            return Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.physicalSizeController,
                    decoration: const InputDecoration(labelText: 'Physical size'),
                    validator: _validateField,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: controller.electricalSpeedController,
                    decoration: const InputDecoration(labelText: 'Electrical speed'),
                    validator: _validateField,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: controller.genController,
                    decoration: const InputDecoration(labelText: 'Generation'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateField,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    controller: controller.quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: _validateField,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      pcieSlotsController.removeAt(i);
                    });
                  },
                ),
              ],
            );
          }),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add PCIe Slot'),
              onPressed: () {
                setState(() {
                  pcieSlotsController.add(PCIeSlotControllers());
                });
              },
            ),
          ),
        ];
      case CategoryEnum.drive:
        return [
          TextFormField(
              controller: genController,
              decoration: const InputDecoration(labelText: 'Drive generation'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: driveTypeController,
              decoration: const InputDecoration(labelText: 'Drive type'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: capacityController,
              decoration: const InputDecoration(labelText: 'Drive capacity'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: interfaceTypeController,
              decoration: const InputDecoration(labelText: 'Interface type'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: formFactorController,
              decoration: const InputDecoration(labelText: 'Drive form factor'),
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: readMbpsController,
              decoration: const InputDecoration(labelText: 'Read speed (MB/s)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
          TextFormField(
              controller: writeMbpsController,
              decoration: const InputDecoration(labelText: 'Write speed (MB/s)'),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField
          ),
          const SizedBox(height: 8),
        ];
      default:
        return [];
    }
  }
  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    return null;
  }


  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<CategoryEnum>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: CategoryEnum.values.map((CategoryEnum category) {
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
              TextFormField(
                  controller: productNameController,
                  decoration: const InputDecoration(labelText: 'Product name'),
                  validator: _validateField
              ),
              TextFormField(
                  controller: importPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Import price',
                    suffixText: '1000 VND',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: _validateField
              ),
              TextFormField(controller: sellingPriceController, decoration: const InputDecoration(labelText: 'Selling price'), keyboardType: TextInputType.number, validator: _validateField), //Giá bán
              TextFormField(controller: discountController, decoration: const InputDecoration(labelText: 'Discount'), keyboardType: TextInputType.number, validator: _validateField), //Giá khuyến mãi
              TextFormField(
                controller: releaseDateController,
                decoration: const InputDecoration(labelText: 'Release date'),
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2099));
                  if (pickedDate != null) {
                    String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
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
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save'),
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
                'manufacturer': _database.manufacturerList[0],
              };

              // Add category-specific fields
              switch (_selectedCategory) {
                case CategoryEnum.ram:
                  productData['bus'] = busController?.text;
                  productData['capacityPerStickGb'] = stickCountController?.text;
                  productData['type'] = typeController?.text;
                  productData['clLatency'] = clLatencyController?.text;
                  productData['kitStickCount'] = stickCountController?.text;
                  break;
                case CategoryEnum.cpu:
                  productData['series'] = cpuSeriesController?.text;
                  productData['core'] = coreController?.text;
                  productData['thread'] = threadController?.text;
                  productData['baseClock'] = baseClockController?.text;
                  productData['turboClock'] = turboClockController?.text;
                  productData['tdp'] = tdpController?.text;
                  productData['socket'] = socketController?.text;
                  break;
                case CategoryEnum.psu:
                  productData['maxWattage'] = maxWattageController?.text;
                  productData['efficiency'] = efficiencyController?.text;
                  productData['modularity'] = modularityController?.text;
                  List<Map<String, dynamic>> connectorsData = connectorControllers.map((controller) {
                    return {
                      'type': controller.typeController.text,
                      'quantity': int.parse(controller.quantityController.text),
                    };
                  }).toList();
                  productData['connectors'] = connectorsData;
                  break;
                case CategoryEnum.gpu:
                  productData['series'] = gpuSeriesController?.text;
                  productData['version'] = gpuVersionController?.text;
                  productData['memory'] = capacityController?.text;
                  productData['tdp'] = tdpController?.text;
                  productData['boostClock'] = turboClockController?.text;
                  List<Map<String, dynamic>> portsData = ioPortsControllers.map((controller) {
                    return {
                      'port': controller.portController.text,
                      'quantity': int.parse(controller.quantityController.text),
                    };
                  }).toList();
                  productData['ports'] = portsData;
                  break;
                case CategoryEnum.mainboard:
                  productData['formFactor'] = mainboardFormFactorController?.text;
                  productData['chipsetCode'] = chipsetCodeController?.text;
                  productData['ramSpec'] = {
                    'type': typeController?.text,
                    'slots': stickCountController?.text,
                    'maxSingleDimmGb': capacityController?.text,
                  };
                  productData['storageSlot'] = {
                    'm2Slots': storageSlotControllerSingle?.m2SlotsController.text,
                    'sataPorts': storageSlotControllerSingle?.sataPortsController.text,
                  };
                  List<Map<String, dynamic>> mbPcieSlotsData = pcieSlotsController.map((controller) {
                    return {
                      'physicalSize': controller.physicalSizeController.text,
                      'electricalSpeed': controller.electricalSpeedController.text,
                      'gen': int.parse(controller.genController.text),
                      'quantity': int.parse(controller.quantityController.text),
                    };
                  }).toList();
                  productData['pcieSlots'] = mbPcieSlotsData;
                  List<Map<String, dynamic>> mbIoPortsData = ioPortsControllers.map((controller) {
                    return {
                      'port': controller.portController.text,
                      'quantity': int.parse(controller.quantityController.text),
                    };
                  }).toList();
                  productData['ports'] = mbIoPortsData;
                  break;
                case CategoryEnum.drive:
                  productData['type'] = driveTypeController?.text;
                  productData['gen'] = genController?.text;
                  productData['formFactor'] = driveFormFactorController?.text;
                  productData['interfaceType'] = interfaceTypeController?.text;
                  productData['memoryGb'] = capacityController?.text;
                  productData['readMbps'] = readMbpsController?.text;
                  productData['writeMbps'] = writeMbpsController?.text;
                  break;
                case CategoryEnum.empty:
                  throw UnimplementedError();
              }
              Product product = ProductFactory.createProduct(productData);

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
