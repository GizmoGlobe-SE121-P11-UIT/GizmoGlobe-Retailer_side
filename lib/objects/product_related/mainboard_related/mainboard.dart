import 'package:gizmoglobe_client/enums/product_related/mainboard_enums/mainboard_form_factor.dart';
import 'package:gizmoglobe_client/enums/product_related/product_status_enum.dart';
import 'package:gizmoglobe_client/enums/product_related/cpu_enums/socket.dart';
import 'package:gizmoglobe_client/objects/product_related/mainboard_related/ram_spec.dart';

import '../../../enums/product_related/category_enum.dart';
import 'io_port.dart';
import 'pcie_slot.dart';
import 'storage_slot.dart';
import '../../manufacturer.dart';
import '../product.dart';

class Mainboard extends Product {
  String chipsetCode;
  Socket socket;
  MainboardFormFactor formFactor;
  RamSpec ramSpec;
  List<PCIeSlot> pcieSlots;
  StorageSlot storageSlot;
  List<IOPort> ioPorts;

  Mainboard({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,

    super.imageUrl,
    super.enDescription,
    super.viDescription,
    super.category = CategoryEnum.mainboard,

    required this.chipsetCode,
    required this.socket,
    required this.formFactor,
    required this.ramSpec,
    required this.pcieSlots,
    required this.storageSlot,
    required this.ioPorts,
    required super.sales,
    required super.stock,
    required super.status,
  });

  @override
  void updateProduct({
    String? productID,
    String? productName,
    double? importPrice,
    double? sellingPrice,
    double? discount,
    DateTime? release,
    int? sales,
    int? stock,
    Manufacturer? manufacturer,
    String? chipsetCode,
    Socket? socket,
    MainboardFormFactor? formFactor,
    RamSpec? ramSpec,
    List<PCIeSlot>? pcieSlots,
    StorageSlot? storageSlot,
    List<IOPort>? ioPorts,
    ProductStatusEnum? status,
    String? imageUrl,

    String? enDescription,
    String? viDescription,
  }) {
    super.updateProduct(
      productID: productID,
      productName: productName,
      importPrice: importPrice,
      sellingPrice: sellingPrice,
      discount: discount,
      release: release,
      sales: sales,
      manufacturer: manufacturer,
      stock: stock,
      status: status,
      imageUrl: imageUrl,
      enDescription: enDescription,
      viDescription: viDescription,
    );

    this.chipsetCode = chipsetCode ?? this.chipsetCode;
    this.socket = socket ?? this.socket;
    this.formFactor = formFactor ?? this.formFactor;
    this.ramSpec = ramSpec ?? this.ramSpec;
    this.pcieSlots = pcieSlots ?? this.pcieSlots;
    this.storageSlot = storageSlot ?? this.storageSlot;
    this.ioPorts = ioPorts ?? this.ioPorts;
  }
}