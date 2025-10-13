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
  RAMType type;
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
  DriveGen gen;
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
    DriveGen? gen,
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
  GPUVersion version;
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
    required this.version,
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
    String? version,
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
    this.version = version ?? this.version;
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

class FilterArgument {
    final List<Manufacturer> manufacturerList;
    final String minStock;
    final String maxStock;
    final String minPrice;
    final String maxPrice;

    final CategoryEnum category;

    final CPUSeries cpuSeries;

    final Socket socket;

    final List<MainboardFormFactor> mainboardFormFactor;
    final String minM2Slots;
    final String maxM2Slots;
    final String minSataPorts;
    final String maxSataPorts;

    final List<RAMType> ramType;
    final String minTotalRamGb;
    final String maxTotalRamGb;

    final List<GPUSeries> gpuSeries;
    final List<GPUVersion> gpuVersion;

    final String minMemoryGb;
    final String maxMemoryGb;

    final String minClockSpeed;
    final String maxClockSpeed;
    final String minTdp;
    final String maxTdp;

    final List<DriveFormFactor> driveFormFactor;
    final List<DriveType> driveType;
    final List<InterfaceType> interfaceType;
    final String minReadMbps;
    final String maxReadMbps;
    final String minWriteMbps;
    final String maxWriteMbps;
    final List<DriveGen> gen;

    final List<PSUEfficiency> psuEfficiency;
    final List<PSUModular> psuModularity;
    final String minWattage;
    final String maxWattage;

    const FilterArgument({
        this.manufacturerList = const [],
        this.minStock = '',
        this.maxStock = '',
        this.minPrice = '',
        this.maxPrice = '',
        this.category = CategoryEnum.cpu,
        this.cpuSeries = CPUSeries.values.first,
        this.socket = Socket.values.first,
        this.mainboardFormFactor = const [],
        this.minM2Slots = '',
        this.maxM2Slots = '',
        this.minSataPorts = '',
        this.maxSataPorts = '',
        this.ramType = const [],
        this.minTotalRamGb = '',
        this.maxTotalRamGb = '',
        this.gpuSeries = const [],
        this.gpuVersion = const [],
        this.minMemoryGb = '',
        this.maxMemoryGb = '',
        this.minClockSpeed = '',
        this.maxClockSpeed = '',
        this.minTdp = '',
        this.maxTdp = '',
        this.driveFormFactor = const [],
        this.driveType = const [],
        this.interfaceType = const [],
        this.minReadMbps = '',
        this.maxReadMbps = '',
        this.minWriteMbps = '',
        this.maxWriteMbps = '',
        this.gen = const [],
        this.psuEfficiency = const [],
        this.psuModularity = const [],
        this.minWattage = '',
        this.maxWattage = '',
    });

    FilterArgument copyWith({
        List<Manufacturer>? manufacturerList,
        String? minStock,
        String? maxStock,
        String? minPrice,
        String? maxPrice,
        CategoryEnum? category,
        CPUSeries? cpuSeries,
        Socket? socket,
        List<MainboardFormFactor>? mainboardFormFactor,
        String? minM2Slots,
        String? maxM2Slots,
        String? minSataPorts,
        String? maxSataPorts,
        List<RAMType>? ramType,
        String? minTotalRamGb,
        String? maxTotalRamGb,
        List<GPUSeries>? gpuSeries,
        List<GPUVersion>? gpuVersion,
        String? minMemoryGb,
        String? maxMemoryGb,
        String? minClockSpeed,
        String? maxClockSpeed,
        String? minTdp,
        String? maxTdp,
        List<DriveFormFactor>? driveFormFactor,
        List<DriveType>? driveType,
        List<InterfaceType>? interfaceType,
        String? minReadMbps,
        String? maxReadMbps,
        String? minWriteMbps,
        String? maxWriteMbps,
        List<DriveGen>? gen,
        List<PSUEfficiency>? psuEfficiency,
        List<PSUModular>? psuModularity,
        String? minWattage,
        String? maxWattage,
    }) {
        return FilterArgument(
            manufacturerList: manufacturerList ?? this.manufacturerList,
            minStock: minStock ?? this.minStock,
            maxStock: maxStock ?? this.maxStock,
            minPrice: minPrice ?? this.minPrice,
            maxPrice: maxPrice ?? this.maxPrice,
            category: category ?? this.category,
            cpuSeries: cpuSeries ?? this.cpuSeries,
            socket: socket ?? this.socket,
            mainboardFormFactor: mainboardFormFactor ?? this.mainboardFormFactor,
            minM2Slots: minM2Slots ?? this.minM2Slots,
            maxM2Slots: maxM2Slots ?? this.maxM2Slots,
            minSataPorts: minSataPorts ?? this.minSataPorts,
            maxSataPorts: maxSataPorts ?? this.maxSataPorts,
            ramType: ramType ?? this.ramType,
            minTotalRamGb: minTotalRamGb ?? this.minTotalRamGb,
            maxTotalRamGb: maxTotalRamGb ?? this.maxTotalRamGb,
            gpuSeries: gpuSeries ?? this.gpuSeries,
            gpuVersion: gpuVersion ?? this.gpuVersion,
            minMemoryGb: minMemoryGb ?? this.minMemoryGb,
            maxMemoryGb: maxMemoryGb ?? this.maxMemoryGb,
            minClockSpeed: minClockSpeed ?? this.minClockSpeed,
            maxClockSpeed: maxClockSpeed ?? this.maxClockSpeed,
            minTdp: minTdp ?? this.minTdp,
            maxTdp: maxTdp ?? this.maxTdp,
            driveFormFactor: driveFormFactor ?? this.driveFormFactor,
            driveType: driveType ?? this.driveType,
            interfaceType: interfaceType ?? this.interfaceType,
            minReadMbps: minReadMbps ?? this.minReadMbps,
            maxReadMbps: maxReadMbps ?? this.maxReadMbps,
            minWriteMbps: minWriteMbps ?? this.minWriteMbps,
            maxWriteMbps: maxWriteMbps ?? this.maxWriteMbps,
            gen: gen ?? this.gen,
            psuEfficiency: psuEfficiency ?? this.psuEfficiency,
            psuModularity: psuModularity ?? this.psuModularity,
            minWattage: minWattage ?? this.minWattage,
            maxWattage: maxWattage ?? this.maxWattage,
        );

    FilterArgument copy({FilterArgument? filter}) {
    return FilterArgument(
        manufacturerList: filter?.manufacturerList ?? Database().manufacturerList,
        minStock: filter?.minStock ?? minStock,
        maxStock: filter?.maxStock ?? maxStock,
        minPrice: filter?.minPrice ?? minPrice,
        maxPrice: filter?.maxPrice ?? maxPrice,
        category: filter?.category ?? category,
        cpuSeries: filter?.cpuSeries ?? cpuSeries,
        socket: filter?.socket ?? socket,
        mainboardFormFactor: filter?.mainboardFormFactor ?? mainboardFormFactor,
        minM2Slots: filter?.minM2Slots ?? minM2Slots,
        maxM2Slots: filter?.maxM2Slots ?? maxM2Slots,
        minSataPorts: filter?.minSataPorts ?? minSataPorts,
        maxSataPorts: filter?.maxSataPorts ?? maxSataPorts,
        ramType: filter?.ramType ?? ramType,
        minTotalRamGb: filter?.minTotalRamGb ?? minTotalRamGb,
        maxTotalRamGb: filter?.maxTotalRamGb ?? maxTotalRamGb,
        gpuSeries: filter?.gpuSeries ?? gpuSeries,
        gpuVersion: filter?.gpuVersion ?? gpuVersion,
        minMemoryGb: filter?.minMemoryGb ?? minMemoryGb,
        maxMemoryGb: filter?.maxMemoryGb ?? maxMemoryGb,
        minClockSpeed: filter?.minClockSpeed ?? minClockSpeed,
        maxClockSpeed: filter?.maxClockSpeed ?? maxClockSpeed,
        minTdp: filter?.minTdp ?? minTdp,
        maxTdp: filter?.maxTdp ?? maxTdp,
        driveFormFactor: filter?.driveFormFactor ?? driveFormFactor,
        driveType: filter?.driveType ?? driveType,
        interfaceType: filter?.interfaceType ?? interfaceType,
        minReadMbps: filter?.minReadMbps ?? minReadMbps,
        maxReadMbps: filter?.maxReadMbps ?? maxReadMbps,
        minWriteMbps: filter?.minWriteMbps ?? minWriteMbps,
        maxWriteMbps: filter?.maxWriteMbps ?? maxWriteMbps,
        gen: filter?.gen ?? gen,
        psuEfficiency: filter?.psuEfficiency ?? psuEfficiency,
        psuModularity: filter?.psuModularity ?? psuModularity,
        minWattage: filter?.minWattage ?? minWattage,
        maxWattage: filter?.maxWattage ?? maxWattage,
    );
}
