import '../../enums/product_related/category_enum.dart';
import '../../enums/product_related/product_status_enum.dart';
import '../manufacturer.dart';
import 'product.dart';

class IOPort {
  String port;
  int quantity;

  IOPort({required this.port, required this.quantity});

  factory IOPort.fromJson(Map<String, dynamic> json) => IOPort(
        port: json['port']?.toString() ?? '',
        quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      );
}

class PCIeSlot {
  int physicalSize;
  int electricalSpeed;
  int gen;
  int quantity;

  PCIeSlot({required this.physicalSize, required this.electricalSpeed, required this.gen, required this.quantity});

  factory PCIeSlot.fromJson(Map<String, dynamic> json) => PCIeSlot(
        physicalSize: (json['physicalSize'] is num) ? (json['physicalSize'] as num).toInt() : int.tryParse(json['physicalSize']?.toString() ?? '') ?? 0,
        electricalSpeed: (json['electricalSpeed'] is num) ? (json['electricalSpeed'] as num).toInt() : int.tryParse(json['electricalSpeed']?.toString() ?? '') ?? 0,
        gen: (json['gen'] is num) ? (json['gen'] as num).toInt() : int.tryParse(json['gen']?.toString() ?? '') ?? 0,
        quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      );
}

class RamSpec {
  String type;
  int slots;
  int? maxSingleDimmGb;
  int? maxTotalGb;

  RamSpec({required this.type, required this.slots, this.maxSingleDimmGb, this.maxTotalGb});

  factory RamSpec.fromJson(Map<String, dynamic> json) => RamSpec(
        type: json['type']?.toString() ?? '',
        slots: (json['slots'] is num) ? (json['slots'] as num).toInt() : int.tryParse(json['slots']?.toString() ?? '') ?? 0,
        maxSingleDimmGb: json['maxSingleDimmGb'] != null ? ((json['maxSingleDimmGb'] is num) ? (json['maxSingleDimmGb'] as num).toInt() : int.tryParse(json['maxSingleDimmGb']?.toString() ?? '')) : null,
        maxTotalGb: json['maxTotalGb'] != null ? ((json['maxTotalGb'] is num) ? (json['maxTotalGb'] as num).toInt() : int.tryParse(json['maxTotalGb']?.toString() ?? '')) : null,
      );
}

class StorageSlots {
  int m2Slots;
  int sataPorts;

  StorageSlots({required this.m2Slots, required this.sataPorts});

  factory StorageSlots.fromJson(Map<String, dynamic> json) => StorageSlots(
        m2Slots: (json['m2Slots'] is num) ? (json['m2Slots'] as num).toInt() : int.tryParse(json['m2Slots']?.toString() ?? '') ?? 0,
        sataPorts: (json['sataPorts'] is num) ? (json['sataPorts'] as num).toInt() : int.tryParse(json['sataPorts']?.toString() ?? '') ?? 0,
      );
}

class Connector {
  String type;
  int quantity;

  Connector({required this.type, required this.quantity});

  factory Connector.fromJson(Map<String, dynamic> json) => Connector(
        type: json['type']?.toString() ?? '',
        quantity: (json['quantity'] is num) ? (json['quantity'] as num).toInt() : int.tryParse(json['quantity']?.toString() ?? '') ?? 0,
      );

}

class RamSpec {
  String type;
  int slots;
  int maxSingleDimmGb;

  RamSpec({required this.type, required this.slots, required this.maxSingleDimmGb});

  factory RamSpec.fromJson(Map<String, dynamic> json) => RamSpec(
        type: json['type']?.toString() ?? '',
        slots: (json['slots'] is num) ? (json['slots'] as num).toInt() : int.tryParse(json['slots']?.toString() ?? '') ?? 0,
        maxSingleDimmGb: json['maxSingleDimmGb'] != null ? ((json['maxSingleDimmGb'] is num) ? (json['maxSingleDimmGb'] as num).toInt() : int.tryParse(json['maxSingleDimmGb']?.toString() ?? '')) : 0,
      );
}

class CPU extends Product {
  CPUSeries series;
  Socket socket;
  int core;
  int thread;
  double baseClock;
  double turboClock;
  int tdp;

  CPU({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,

    super.imageUrl,
    super.enDescription,
    super.viDescription,
    super.category = CategoryEnum.cpu,

    required this.series,
    required this.socket,
    required this.core,
    required this.thread,
    required this.baseClock,
    required this.tdp,
    required this.turboClock,
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
    CPUSeries? series,
    Socket? socket,
    int? core,
    int? thread,
    double? baseClock,
    int? tdp,
    double? turboClock,
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
      stock: stock,
      manufacturer: manufacturer,
      status: status,
      imageUrl: imageUrl,
      enDescription: enDescription,
      viDescription: viDescription
    );

    this.series = series ?? this.series;
    this.socket = socket ?? this.socket;
    this.core = core ?? this.core;
    this.thread = thread ?? this.thread;
    this.baseClock = baseClock ?? this.baseClock;
    this.tdp = tdp ?? this.tdp;
    this.turboClock = turboClock ?? this.turboClock;
  }
}

class Drive extends Product {
  int gen;
  int memoryGb;
  InterfaceType interfaceType;
  int readMbps;
  int writeMbps;
  DriveFormFactor formFactor;
  DriveType driveType;

  Drive({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,

    super.imageUrl,
    super.enDescription,
    super.viDescription,
    super.category = CategoryEnum.drive,

    required this.gen,
    required this.memoryGb,
    required this.interfaceType,
    required this.readMbps,
    required this.writeMbps,
    required this.formFactor,
    required this.driveType,
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
    int? gen,
    int? memoryGb,
    InterfaceType? interfaceType,
    int? readMbps,
    int? writeMbps,
    DriveFormFactor? formFactor,
    DriveType? driveType,
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

    this.gen = gen ?? this.gen;
    this.memoryGb = memoryGb ?? this.memoryGb;
    this.interfaceType = interfaceType ?? this.interfaceType;
    this.readMbps = readMbps ?? this.readMbps;
    this.writeMbps = writeMbps ?? this.writeMbps;
    this.formFactor = formFactor ?? this.formFactor;
    this.driveType = driveType ?? this.driveType;
  }
}

class GPU extends Product {
  GPUSeries series;
  VramVersion vramVersion;
  int memory;
  int boostClock;
  int tdp;
  List<IOPort> ports;

  GPU({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,
    
    super.imageUrl,
    super.enDescription,
    super.viDescription,
    super.category = CategoryEnum.gpu,

    required this.series,
    required this.vramVersion,
    required this.memoryGb,
    required this.boostClock,
    required this.tdp,
    required this.ports,
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
    String? series,
    String? vramVersion,
    int? memoryGb,
    int? boostClock,
    int? tdp,
    List<Map<String, dynamic>>? ports,
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

    this.series = series ?? this.series;
    this.vramVersion = vramVersion ?? this.vramVersion;
    this.memoryGb = memoryGb ?? this.memoryGb;
    this.boostClock = boostClock ?? this.boostClock;
    this.tdp = tdp ?? this.tdp;
    this.ports = ports ?? this.ports;
  }
}

class Mainboard extends Product {
  String chipsetCode;
  Socket socket;
  MainboardFormFactor formFactor;
  RamSpec ramSpec;
  List<PCIeSlot> pcieSlots;
  StorageSlots storageSlots;
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
    required this.storageSlots,
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
    StorageSlots? storageSlots,
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
    this.storageSlots = storageSlots ?? this.storageSlots;
    this.ioPorts = ioPorts ?? this.ioPorts;
  }
}

class PSU extends Product {
  int maxWattage;
  PSUEfficiency efficiency;
  PSUModular modularity;
  List<Connector> connectors;

  PSU({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,

    super.imageUrl,
    super.enDescription,
    super.viDescription,
    super.category = CategoryEnum.psu,

    required this.maxWattage,
    required this.efficiency,
    required this.modularity,
    required this.connectors,
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
    int? maxWattage,
    PSUEfficiency? efficiency,
    PSUModular? modularity,
    List<Connector>? connectors,
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

    this.maxWattage = maxWattage ?? this.maxWattage;
    this.efficiency = efficiency ?? this.efficiency;
    this.modularity = modularity ?? this.modularity;
    this.connectors = connectors ?? this.connectors;
  }
}

class RAM extends Product {
  RAMType type;
  int bus;
  int clLatency;
  int kitStickCount;
  int capacityPerStickGb;

  RAM({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,

    super.imageUrl,
    super.enDescription,
    super.viDescription,
    super.category = CategoryEnum.ram,

    required this.type,
    required this.bus,
    required this.clLatency,
    required this.kitStickCount,
    required this.capacityPerStickGb,
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
    RAMType? type,
    int? bus,
    int? clLatency,
    int? kitStickCount,
    int? capacityPerStickGb,
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

    this.type = type ?? this.type;
    this.bus = bus ?? this.bus;
    this.clLatency = clLatency ?? this.clLatency;
    this.kitStickCount = kitStickCount ?? this.kitStickCount;
    this.capacityPerStickGb = capacityPerStickGb ?? this.capacityPerStickGb;
  }
}
