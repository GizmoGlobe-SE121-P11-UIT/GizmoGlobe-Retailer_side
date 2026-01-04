import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/product_related/cpu_enums/cpu_series.dart';
import 'package:gizmoglobe_client/enums/product_related/cpu_enums/socket.dart';
import 'package:gizmoglobe_client/enums/product_related/drive_enums/drive_gen.dart';
import 'package:gizmoglobe_client/enums/product_related/gpu_enums/gpu_version.dart';
import 'package:gizmoglobe_client/widgets/dialog/information_dialog.dart';
import 'package:gizmoglobe_client/widgets/general/app_text_style.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:intl/intl.dart';

import '../../../data/database/database.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/category_enum.dart';

import '../../../enums/product_related/drive_enums/drive_form_factor.dart';
import '../../../enums/product_related/drive_enums/drive_type.dart';
import '../../../enums/product_related/gpu_enums/gpu_series.dart';
import '../../../enums/product_related/mainboard_enums/mainboard_form_factor.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../../enums/product_related/psu_enums/psu_efficiency.dart';
import '../../../enums/product_related/psu_enums/psu_modular.dart';
import '../../../enums/product_related/ram_enums/ram_type.dart';
import '../../../objects/manufacturer.dart';
import '../../../objects/product_related/cpu_related/cpu.dart';
import '../../../objects/product_related/drive_related/drive.dart';
import '../../../objects/product_related/gpu_related/gpu.dart';
import '../../../objects/product_related/mainboard_related/io_port.dart';
import '../../../objects/product_related/mainboard_related/mainboard.dart';
import '../../../objects/product_related/mainboard_related/pcie_slot.dart';
import '../../../objects/product_related/mainboard_related/storage_slot.dart';
import '../../../objects/product_related/product.dart';
import '../../../objects/product_related/psu_related/connector.dart';
import '../../../objects/product_related/psu_related/psu.dart';
import '../../../objects/product_related/ram_related/ram.dart';
import '../../../widgets/general/field_with_icon.dart';
import '../../../widgets/general/gradient_dropdown.dart';
import '../../../widgets/general/multi_field_with_icon.dart';
import '../../media/image_manager_modal.dart';
import '../../../objects/product_related/product_image.dart';
import 'add_product_state.dart';
import 'add_product_cubit.dart';
import 'add_product_webview.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  static Future<bool?> showModal(BuildContext context,
      {Product? product}) async {
    if (kIsWeb) {
      return showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: product != null
              ? AddProductWebView.editInstance(product)
              : AddProductWebView.addInstance(),
        ),
      );
    } else {
      return Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => product != null
              ? AddProductScreen.editInstance(product)
              : AddProductScreen.addInstance(),
        ),
      );
    }
  }

  static Widget addInstance() {
    return BlocProvider(
      create: (context) => AddProductCubit(),
      child: const AddProductScreen(),
    );
  }

  static Widget editInstance(Product product) {
    return BlocProvider(
      create: (context) => AddProductCubit(product: product),
      child: AddProductScreen(product: product),
    );
  }

  @override
  State<AddProductScreen> createState() => _AddProductState();
}

class _AddProductState extends State<AddProductScreen> {
  AddProductCubit get cubit => context.read<AddProductCubit>();
  late TextEditingController productNameController;
  late TextEditingController importPriceController;
  late TextEditingController sellingPriceController;
  late TextEditingController discountController;
  late TextEditingController releaseDateController;
  late TextEditingController stockController;
  late TextEditingController enDescriptionController;
  late TextEditingController viDescriptionController;

  // Category specific controllers
  // RAM
  late TextEditingController busController;
  late TextEditingController typeController;
  late TextEditingController stickCountController;
  late TextEditingController clLatencyController;
  late TextEditingController capacityController;

  // CPU
  late TextEditingController cpuSeriesController;
  late TextEditingController socketController;
  late TextEditingController coreController;
  late TextEditingController threadController;
  late TextEditingController baseClockController;
  late TextEditingController turboClockController;

  // PSU
  late TextEditingController maxWattageController;
  late TextEditingController efficiencyController;
  late TextEditingController modularityController;
  List<ConnectorControllers> connectorControllers = [];

  // GPU
  late TextEditingController gpuSeriesController;
  late TextEditingController gpuVersionController;
  late TextEditingController tdpController;
  List<IOPortControllers> ioPortsControllers = [];

  // Mainboard
  late TextEditingController mainboardFormFactorController;
  late TextEditingController chipsetCodeController;
  StorageSlotControllers? storageSlotControllerSingle;
  late TextEditingController formFactorController;
  List<PCIeSlotControllers> pcieSlotsController = [];

  // Drive
  late TextEditingController genController;
  late TextEditingController interfaceTypeController;
  late TextEditingController writeMbpsController;
  late TextEditingController readMbpsController;
  late TextEditingController driveTypeController;
  late TextEditingController driveFormFactorController;

  @override
  void initState() {
    super.initState();
    productNameController =
        TextEditingController(text: widget.product?.productName);
    importPriceController =
        TextEditingController(text: widget.product?.importPrice.toString());
    sellingPriceController =
        TextEditingController(text: widget.product?.sellingPrice.toString());
    discountController =
        TextEditingController(text: widget.product?.discount.toString());
    releaseDateController = TextEditingController(
        text: widget.product?.release != null
            ? DateFormat('yyyy-MM-dd').format(widget.product!.release)
            : '');
    stockController =
        TextEditingController(text: widget.product?.stock.toString());
    enDescriptionController =
        TextEditingController(text: widget.product?.enDescription);
    viDescriptionController =
        TextEditingController(text: widget.product?.viDescription);

    // Initialize all category specific controllers (with empty values if not editing)
    // RAM controllers
    if (widget.product?.category == CategoryEnum.ram && widget.product is RAM) {
      busController =
          TextEditingController(text: (widget.product as RAM).bus.toString());
      typeController =
          TextEditingController(text: (widget.product as RAM).type.toString());
      stickCountController = TextEditingController(
          text: (widget.product as RAM).kitStickCount.toString());
      capacityController = TextEditingController(
          text: (widget.product as RAM).capacityPerStickGb.toString());
      clLatencyController = TextEditingController(
          text: (widget.product as RAM).clLatency.toString());
    } else {
      busController = TextEditingController();
      typeController = TextEditingController();
      stickCountController = TextEditingController();
      clLatencyController = TextEditingController();
      capacityController = TextEditingController();
    }

    // CPU controllers
    if (widget.product?.category == CategoryEnum.cpu && widget.product is CPU) {
      cpuSeriesController = TextEditingController(
          text: (widget.product as CPU).series.toString());
      socketController = TextEditingController(
          text: (widget.product as CPU).socket.toString());
      coreController =
          TextEditingController(text: (widget.product as CPU).core.toString());
      threadController = TextEditingController(
          text: (widget.product as CPU).thread.toString());
      baseClockController = TextEditingController(
          text: (widget.product as CPU).baseClock.toString());
      turboClockController = TextEditingController(
          text: (widget.product as CPU).turboClock.toString());
      tdpController =
          TextEditingController(text: (widget.product as CPU).tdp.toString());
    } else {
      cpuSeriesController = TextEditingController();
      socketController = TextEditingController();
      coreController = TextEditingController();
      threadController = TextEditingController();
      baseClockController = TextEditingController();
      turboClockController = TextEditingController();
      tdpController = TextEditingController();
    }

    // PSU controllers
    if (widget.product?.category == CategoryEnum.psu && widget.product is PSU) {
      maxWattageController = TextEditingController(
          text: (widget.product as PSU).maxWattage.toString());
      efficiencyController = TextEditingController(
          text: (widget.product as PSU).efficiency.toString());
      modularityController = TextEditingController(
          text: (widget.product as PSU).modularity.toString());

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
    } else {
      maxWattageController = TextEditingController();
      efficiencyController = TextEditingController();
      modularityController = TextEditingController();
      connectorControllers = [ConnectorControllers()];
    }

    // GPU controllers
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
            .map((port) => IOPortControllers(
          port: port.port,
          quantity: port.quantity.toString(),
        ))
            .toList();
      } else {
        ioPortsControllers = [IOPortControllers()];
      }
    } else {
      gpuSeriesController = TextEditingController();
      gpuVersionController = TextEditingController();
      tdpController = TextEditingController();
      ioPortsControllers = [IOPortControllers()];
    }

    // Mainboard controllers
    if (widget.product?.category == CategoryEnum.mainboard &&
        widget.product is Mainboard) {
      mainboardFormFactorController = TextEditingController(
          text: (widget.product as Mainboard).formFactor.toString());
      chipsetCodeController = TextEditingController(
          text: (widget.product as Mainboard).chipsetCode.toString());

      final pcieSlots = (widget.product as Mainboard).pcieSlots;
      if (pcieSlots.isNotEmpty) {
        pcieSlotsController = pcieSlots
            .map((slot) => PCIeSlotControllers(
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
    } else {
      mainboardFormFactorController = TextEditingController();
      chipsetCodeController = TextEditingController();
      formFactorController = TextEditingController();
      pcieSlotsController = [PCIeSlotControllers()];
      storageSlotControllerSingle = StorageSlotControllers(
        m2Slots: '0',
        sataPorts: '0',
      );
    }

    // Drive controllers
    if (widget.product?.category == CategoryEnum.drive &&
        widget.product is Drive) {
      genController =
          TextEditingController(text: (widget.product as Drive).gen.toString());
      interfaceTypeController = TextEditingController(
          text: (widget.product as Drive).interfaceType.toString());
      driveTypeController = TextEditingController(
          text: (widget.product as Drive).driveType.toString());
      driveFormFactorController = TextEditingController(
          text: (widget.product as Drive).formFactor.toString());
      capacityController = TextEditingController(
          text: (widget.product as Drive).memoryGb.toString());
      writeMbpsController = TextEditingController(
          text: (widget.product as Drive).speed.writeMbps.toString());
      readMbpsController = TextEditingController(
          text: (widget.product as Drive).speed.readMbps.toString());
    } else {
      genController = TextEditingController();
      interfaceTypeController = TextEditingController();
      writeMbpsController = TextEditingController();
      readMbpsController = TextEditingController();
      driveTypeController = TextEditingController();
      driveFormFactorController = TextEditingController();
    }
  }

  @override
  void dispose() {
    productNameController.dispose();
    importPriceController.dispose();
    sellingPriceController.dispose();
    discountController.dispose();
    releaseDateController.dispose();
    stockController.dispose();
    enDescriptionController.dispose();
    viDescriptionController.dispose();

    // RAM controllers
    busController.dispose();
    typeController.dispose();
    stickCountController.dispose();
    clLatencyController.dispose();
    capacityController.dispose();

    // CPU controllers
    cpuSeriesController.dispose();
    socketController.dispose();
    coreController.dispose();
    threadController.dispose();
    baseClockController.dispose();
    turboClockController.dispose();
    tdpController.dispose();

    // PSU controllers
    maxWattageController.dispose();
    efficiencyController.dispose();
    modularityController.dispose();
    for (var connectorController in connectorControllers) {
      connectorController.typeController.dispose();
      connectorController.quantityController.dispose();
    }

    // GPU controllers
    gpuSeriesController.dispose();
    gpuVersionController.dispose();
    for (var ioPortController in ioPortsControllers) {
      ioPortController.portController.dispose();
      ioPortController.quantityController.dispose();
    }

    // Mainboard controllers
    mainboardFormFactorController.dispose();
    chipsetCodeController.dispose();
    storageSlotControllerSingle?.m2SlotsController.dispose();
    storageSlotControllerSingle?.sataPortsController.dispose();
    for (var pcieSlotController in pcieSlotsController) {
      pcieSlotController.physicalSizeController.dispose();
      pcieSlotController.electricalSpeedController.dispose();
      pcieSlotController.genController.dispose();
      pcieSlotController.quantityController.dispose();
    }

    // Drive controllers
    genController.dispose();
    interfaceTypeController.dispose();
    writeMbpsController.dispose();
    readMbpsController.dispose();
    driveTypeController.dispose();
    driveFormFactorController.dispose();

    super.dispose();
  }

  Widget buildCategorySpecificInputs(
      CategoryEnum category, AddProductState state, AddProductCubit cubit) {
    // Fix: Use the 'category' argument (from state) instead of '_selectedCategory' (from initState)
    switch (category) {
      case CategoryEnum.ram:
        return Column(children: [
          buildInputWidget<RAMType>(S.of(context).ramType,
              TextEditingController(), state.productArgument?.type, (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(type: value));
              }, RAMType.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).ramBus,
            busController,
            state.productArgument?.bus,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(bus: value));
            },
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).capacityPerStick,
            capacityController,
            state.productArgument?.capacity,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(capacity: value));
            },
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).kitStickCount,
            stickCountController,
            state.productArgument?.stickCount,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(stickCount: value));
            },
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).clLatency,
            clLatencyController,
            state.productArgument?.clLatency,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(clLatency: value));
            },
            null,
          ),
          const SizedBox(height: 8),
        ]);

      case CategoryEnum.cpu:
        return Column(children: [
          buildInputWidget<CPUSeries>(
              S.of(context).cpuSeries,
              TextEditingController(),
              state.productArgument?.cpuSeries, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(cpuSeries: value));
          }, CPUSeries.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).numberOfCpuCores,
            coreController,
            state.productArgument?.core,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(core: value));
            },
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).numberOfCpuThreads,
            threadController,
            state.productArgument?.thread,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(thread: value));
            },
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<double>(
              S.of(context).cpuBaseClock,
              baseClockController,
              state.productArgument?.baseClock, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(baseClock: value));
          }, null),
          const SizedBox(height: 8),
          buildInputWidget<double>(
              S.of(context).cpuTurboClock,
              turboClockController,
              state.productArgument?.turboClock, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(turboClock: value));
          }, null),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).cpuTdp,
            tdpController,
            state.productArgument?.tdp,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(tdp: value));
            },
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<Socket>(S.of(context).cpuSocket,
              TextEditingController(), state.productArgument?.socket, (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(socket: value));
              }, Socket.getValues()),
          const SizedBox(height: 8),
        ]);
      case CategoryEnum.psu:
        return Column(children: [
          buildInputWidget<int>(
            S.of(context).maxWattage,
            maxWattageController,
            state.productArgument?.tdp,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(tdp: value));
            },
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<PSUEfficiency>(
              S.of(context).psuEfficiency,
              TextEditingController(),
              state.productArgument?.efficiency, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(efficiency: value));
          }, PSUEfficiency.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<PSUModular>(
              S.of(context).psuModularity,
              TextEditingController(),
              state.productArgument?.modularity, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(modularity: value));
          }, PSUModular.getValues()),
          const SizedBox(height: 8),
          ...connectorControllers.asMap().entries.map((entry) {
            final i = entry.key;
            return Row(
              children: [
                Expanded(
                  child: buildInputWidget<String>(
                    S.of(context).connectorType,
                    connectorControllers[i].typeController,
                    state.productArgument?.connectors != null &&
                        i < state.productArgument!.connectors!.length
                        ? state.productArgument!.connectors![i].type
                        : null,
                        (value) {
                      cubit.changeConnectorType(value, i);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: buildInputWidget<int>(
                    S.of(context).quantity,
                    connectorControllers[i].quantityController,
                    state.productArgument?.connectors != null &&
                        i < state.productArgument!.connectors!.length
                        ? state.productArgument!.connectors![i].quantity
                        : null,
                        (value) {
                      cubit.changeConnectorQuantity(value, i);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      connectorControllers.removeAt(i);
                      cubit.removeConnector(i);
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
              label: Text(S.of(context).addConnector),
              onPressed: () {
                setState(() {
                  connectorControllers.add(ConnectorControllers());
                  cubit.addConnector();
                });
              },
            ),
          ),
        ]);
      case CategoryEnum.gpu:
        return Column(children: [
          buildInputWidget<GPUSeries>(
              S.of(context).gpuSeries,
              TextEditingController(),
              state.productArgument?.gpuSeries, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(gpuSeries: value));
          }, GPUSeries.getValues()),
          const SizedBox(width: 8),
          buildInputWidget<GPUVersion>(
              S.of(context).gpuVersion,
              TextEditingController(),
              state.productArgument?.gpuVersion, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(gpuVersion: value));
          }, GPUVersion.getValues()),
          const SizedBox(width: 8),
          buildInputWidget<int>(
            S.of(context).gpuMemory,
            capacityController,
            state.productArgument?.capacity,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(capacity: value));
            },
            null,
          ),
          const SizedBox(width: 8),
          buildInputWidget<int>(
            S.of(context).gpuTdp,
            tdpController,
            state.productArgument?.tdp,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(tdp: value));
            },
            null,
          ),
          const SizedBox(width: 8),
          buildInputWidget<double>(S.of(context).gpuBoostClock,
              turboClockController, state.productArgument?.turboClock, (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(turboClock: value));
              }, null),
          const SizedBox(width: 8),
          ...ioPortsControllers.asMap().entries.map((entry) {
            final i = entry.key;
            return Row(
              children: [
                Expanded(
                    child: buildInputWidget<String>(
                      S.of(context).port,
                      ioPortsControllers[i].portController,
                      state.productArgument?.ioPorts != null &&
                          i < state.productArgument!.ioPorts!.length
                          ? state.productArgument!.ioPorts![i].port
                          : null,
                          (value) {
                        cubit.changeIoPortType(value, i);
                      },
                    )),
                const SizedBox(width: 8),
                Expanded(
                    child: buildInputWidget<int>(
                      S.of(context).quantity,
                      ioPortsControllers[i].quantityController,
                      state.productArgument?.ioPorts != null &&
                          i < state.productArgument!.ioPorts!.length
                          ? state.productArgument!.ioPorts![i].quantity
                          : null,
                          (value) {
                        cubit.changeIoPortQuantity(value, i);
                      },
                    )),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      ioPortsControllers.removeAt(i);
                      cubit.removeIoPort(i);
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
              label: Text(S.of(context).addIoPort),
              onPressed: () {
                setState(() {
                  ioPortsControllers.add(IOPortControllers());
                  cubit.addIoPort();
                });
              },
            ),
          ),
        ]);
      case CategoryEnum.mainboard:
        return Column(children: [
          buildInputWidget<String>(
              S.of(context).chipsetCode,
              chipsetCodeController,
              state.productArgument?.chipsetCode, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(chipsetCode: value));
          }, null),
          const SizedBox(height: 8),
          buildInputWidget<MainboardFormFactor>(
              S.of(context).mainboardFormFactor,
              TextEditingController(),
              state.productArgument?.mainboardFormFactor, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(mainboardFormFactor: value));
          }, MainboardFormFactor.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).ramBusSpeed,
            busController,
            state.productArgument?.bus,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(bus: value));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<RAMType>(S.of(context).supportedRamType,
              TextEditingController(), state.productArgument?.type, (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(type: value));
              }, RAMType.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
              S.of(context).maximumSingleRamCapacity,
              capacityController,
              state.productArgument?.capacity, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(capacity: value));
          }, null),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).numberOfM2Slots,
            storageSlotControllerSingle?.m2SlotsController ?? TextEditingController(),
            state.productArgument?.storageSlot?.m2Slots,
                (value) {
              cubit.updateProductArgument(state.productArgument!.copyWith(
                  storageSlot: state.productArgument!.storageSlot
                      ?.copyWith(m2Slots: value)));
            },
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).numberOfSataPorts,
            storageSlotControllerSingle?.sataPortsController ?? TextEditingController(),
            state.productArgument?.storageSlot?.sataPorts,
                (value) {
              cubit.updateProductArgument(state.productArgument!.copyWith(
                  storageSlot: state.productArgument!.storageSlot
                      ?.copyWith(sataPorts: value)));
            },
          ),
          const SizedBox(height: 8),
          ...ioPortsControllers.asMap().entries.map((entry) {
            final i = entry.key;
            return Row(
              children: [
                Expanded(
                    child: buildInputWidget<String>(
                      S.of(context).port,
                      ioPortsControllers[i].portController,
                      state.productArgument?.ioPorts != null &&
                          i < state.productArgument!.ioPorts!.length
                          ? state.productArgument!.ioPorts![i].port
                          : null,
                          (value) {
                        cubit.changeIoPortType(value, i);
                      },
                    )),
                const SizedBox(width: 8),
                Expanded(
                    child: buildInputWidget<int>(
                      S.of(context).quantity,
                      ioPortsControllers[i].quantityController,
                      state.productArgument?.ioPorts != null &&
                          i < state.productArgument!.ioPorts!.length
                          ? state.productArgument!.ioPorts![i].quantity
                          : null,
                          (value) {
                        cubit.changeIoPortQuantity(value, i);
                      },
                    )),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      ioPortsControllers.removeAt(i);
                      cubit.removeIoPort(i);
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
              label: Text(S.of(context).addIoPort),
              onPressed: () {
                setState(() {
                  ioPortsControllers.add(IOPortControllers());
                  cubit.addIoPort();
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
                  child: buildInputWidget<int>(
                    S.of(context).physicalSize,
                    controller.physicalSizeController,
                    state.productArgument?.pcieSlots != null &&
                        i < state.productArgument!.pcieSlots!.length
                        ? state.productArgument!.pcieSlots![i].physicalSize
                        : null,
                        (value) {
                      cubit.changePCIeSlotPhysicalSize(value, i);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: buildInputWidget<int>(
                    S.of(context).electricalSpeed,
                    controller.electricalSpeedController,
                    state.productArgument?.pcieSlots != null &&
                        i < state.productArgument!.pcieSlots!.length
                        ? state.productArgument!.pcieSlots![i].electricalSpeed
                        : null,
                        (value) {
                      cubit.changePCIeSlotElectricalSpeed(value, i);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: buildInputWidget<int>(
                    S.of(context).generation,
                    controller.genController,
                    state.productArgument?.pcieSlots != null &&
                        i < state.productArgument!.pcieSlots!.length
                        ? state.productArgument!.pcieSlots![i].gen
                        : null,
                        (value) {
                      cubit.changePCIeSlotGen(value, i);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: buildInputWidget<int>(
                    S.of(context).quantity,
                    controller.quantityController,
                    state.productArgument?.pcieSlots != null &&
                        i < state.productArgument!.pcieSlots!.length
                        ? state.productArgument!.pcieSlots![i].quantity
                        : null,
                        (value) {
                      cubit.changePCIeSlotQuantity(value, i);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      pcieSlotsController.removeAt(i);
                      cubit.removePcieSlot(i);
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
              label: Text(S.of(context).addPcieSlot),
              onPressed: () {
                setState(() {
                  pcieSlotsController.add(PCIeSlotControllers());
                  cubit.addPcieSlot();
                });
              },
            ),
          ),
        ]);
      case CategoryEnum.drive:
        return Column(children: [
          buildInputWidget<DriveGen>(S.of(context).driveGeneration,
              TextEditingController(), state.productArgument?.gen, (value) {
                cubit.updateProductArgument(
                    state.productArgument!.copyWith(gen: value));
              }, DriveGen.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<DriveType>(
              S.of(context).driveType,
              TextEditingController(),
              state.productArgument?.driveType, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(driveType: value));
          }, DriveType.getValues()),
          const SizedBox(height: 8),
          TextFormField(
              controller: capacityController,
              decoration: InputDecoration(labelText: S.of(context).capacity),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: _validateField),
          const SizedBox(height: 8),
          TextFormField(
              controller: interfaceTypeController,
              decoration:
              InputDecoration(labelText: S.of(context).interfaceType),
              validator: _validateField),
          const SizedBox(height: 8),
          buildInputWidget<DriveFormFactor>(
              S.of(context).formFactor,
              TextEditingController(),
              state.productArgument?.driveFormFactor, (value) {
            cubit.updateProductArgument(
                state.productArgument!.copyWith(driveFormFactor: value));
          }, DriveFormFactor.getValues()),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).readSpeed,
            readMbpsController,
            state.productArgument?.readMbps,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(readMbps: value));
            },
            null,
          ),
          const SizedBox(height: 8),
          buildInputWidget<int>(
            S.of(context).writeSpeed,
            writeMbpsController,
            state.productArgument?.writeMbps,
                (value) {
              cubit.updateProductArgument(
                  state.productArgument!.copyWith(writeMbps: value));
            },
            null,
          ),
          const SizedBox(height: 8),
        ]);
      default:
        return Container();
    }
  }

  String? _validateField(String? value) {
    if (value == null || value.isEmpty) {
      return S.of(context).thisFieldIsRequired;
    }
    return null;
  }

  /// Helper to display ProductImage - handles both pending (memory) and uploaded (network) images
  Widget _buildImageWidget(
      ProductImage image, {
        double? width,
        double? height,
        BoxFit fit = BoxFit.cover,
      }) {
    final colorScheme = Theme.of(context).colorScheme;

    if (image.hasPendingUpload && image.pendingBytes != null) {
      // Pending image - use memory
      return Image.memory(
        image.pendingBytes!,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: colorScheme.errorContainer,
            child: Icon(
              Icons.broken_image,
              color: colorScheme.error,
              size: width != null ? width / 2 : 48,
            ),
          );
        },
      );
    } else if (image.url.isNotEmpty) {
      // Uploaded image - use network
      return Image.network(
        image.url,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: width,
            height: height,
            color: colorScheme.errorContainer,
            child: Icon(
              Icons.broken_image,
              color: colorScheme.error,
              size: width != null ? width / 2 : 48,
            ),
          );
        },
      );
    } else {
      // No image data available
      return Container(
        width: width,
        height: height,
        color: colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.image_not_supported,
          color: colorScheme.onSurfaceVariant,
          size: width != null ? width / 2 : 48,
        ),
      );
    }
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
          onPressed: () => Navigator.pop(context, false),
          fillColor: Colors.transparent,
        ),
        title: GradientText(
            text: widget.product == null
                ? S.of(context).addProduct
                : S.of(context).editProduct),
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocConsumer<AddProductCubit, AddProductState>(
          listener: (context, state) {
            if (state.processState == ProcessState.success) {
              if (state.notifyMessage == NotifyMessage.msg21) {
                // Description generation - show dialog to notify
                enDescriptionController.text =
                    state.productArgument?.enDescription ?? '';
                viDescriptionController.text =
                    state.productArgument?.viDescription ?? '';

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
              } else {
                // Product add/edit success - close and let parent show snackbar
                Navigator.pop(context, true);
              }
            } else if (state.processState == ProcessState.failure) {
              // Show error dialog
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
                    onTap: () => ImageManagerModal.show(context),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.2),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (state.activeImages.isNotEmpty)
                            Center(
                              child: _buildImageWidget(
                                state.activeImages.first,
                                fit: BoxFit.contain,
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
                          // Image count badge
                          if (state.activeImages.isNotEmpty)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.photo_library,
                                        size: 16, color: Colors.white),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${state.activeImages.length}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (state.isUploadingImage || state.isLoadingImages)
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
                                  child: buildInputWidget<int>(
                                    S.of(context).importPrice,
                                    importPriceController,
                                    state.productArgument?.importPrice,
                                        (value) {
                                      cubit.updateProductArgument(state.productArgument!
                                          .copyWith(importPrice: value));
                                    },
                                    null,
                                    '.000đ',
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: buildInputWidget<int>(
                                    S.of(context).sellingPrice,
                                    sellingPriceController,
                                    state.productArgument?.sellingPrice,
                                        (value) {
                                      cubit.updateProductArgument(state.productArgument!
                                          .copyWith(sellingPrice: value));
                                    },
                                    null,
                                    '.000đ',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: buildInputWidget<int>(
                                    S.of(context).discount,
                                    discountController,
                                    state.productArgument?.discount,
                                        (value) {
                                      cubit.updateProductArgument(
                                          state.productArgument!.copyWith(discount: value));
                                    },
                                    null,
                                    '%',
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
                              state.productArgument?.category ?? CategoryEnum.cpu,
                                  (value) {
                                cubit.updateProductArgument(state.productArgument!
                                    .copyWith(category: value));
                              },
                              CategoryEnum.getValues(),
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
                                hintText: S
                                    .of(context)
                                    .enterField(S.of(context).enDescription),
                                labelText: S.of(context).enDescription,
                                onChanged: (value) {
                                  cubit.updateProductArgument(state
                                      .productArgument!
                                      .copyWith(enDescription: value));
                                },
                                suffixIcon: (state.productArgument!.isEnEmpty &&
                                    state.productArgument!.isViEmpty)
                                    ? Icons.add_comment
                                    : Icons.g_translate,
                                onSuffixIconPressed: () {
                                  cubit.generateEnDescription();
                                },
                              ),
                              const SizedBox(height: 16),
                              MultiFieldWithIcon(
                                controller: viDescriptionController,
                                hintText: S
                                    .of(context)
                                    .enterField(S.of(context).viDescription),
                                labelText: S.of(context).viDescription,
                                onChanged: (value) {
                                  cubit.updateProductArgument(state
                                      .productArgument!
                                      .copyWith(viDescription: value));
                                },
                                suffixIcon: (state.productArgument!.isEnEmpty &&
                                    state.productArgument!.isViEmpty)
                                    ? Icons.add_comment
                                    : Icons.g_translate,
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
      ),
    );
  }

  Widget buildInputWidget<T>(
      String propertyName,
      TextEditingController controller,
      T? propertyValue,
      void Function(T?) onChanged,
      [List<T>? enumValues,
        String? suffixText]) {
    return Builder(builder: (BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;

      if (T == DateTime) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(propertyName, style: AppTextStyle.smallText),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: propertyValue as DateTime? ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );

                if (pickedDate != null) {
                  onChanged(pickedDate as T?);
                }
              },
              child: AbsorbPointer(
                child: FieldWithIcon(
                  controller: TextEditingController(
                    text: (propertyValue as DateTime?) != null
                        ? DateFormat('yyyy-MM-dd')
                        .format(propertyValue as DateTime)
                        : '',
                  ),
                  readOnly: true,
                  hintText: S.of(context).selectField(propertyName),
                  fillColor: colorScheme.surface,
                  textColor: colorScheme.onSurface,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
              ),
            ),
          ],
        );
      } else if (enumValues != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(propertyName, style: AppTextStyle.smallText),
            const SizedBox(height: 4),
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
        List<TextInputFormatter> inputFormatters = [];

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
          inputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'.*'))];
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(propertyName, style: AppTextStyle.smallText),
            const SizedBox(height: 4),
            _FocusableFieldWithIcon(
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
              fillColor: colorScheme.surface,
              textColor: colorScheme.onSurface,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              suffixText: suffixText,
            ),
          ],
        );
      }
    });
  }
}

class _FocusableFieldWithIcon extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final Color fillColor;
  final Color textColor;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final String? suffixText;

  const _FocusableFieldWithIcon({
    required this.controller,
    required this.hintText,
    this.onChanged,
    required this.fillColor,
    required this.textColor,
    required this.keyboardType,
    required this.inputFormatters,
    this.suffixText,
  });

  @override
  State<_FocusableFieldWithIcon> createState() => _FocusableFieldWithIconState();
}

class _FocusableFieldWithIconState extends State<_FocusableFieldWithIcon> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FieldWithIcon(
      controller: widget.controller,
      focusNode: _focusNode,
      hintText: _isFocused ? '' : widget.hintText,
      onChanged: widget.onChanged,
      fillColor: widget.fillColor,
      textColor: widget.textColor,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      suffixText: widget.suffixText,
    );
  }
}