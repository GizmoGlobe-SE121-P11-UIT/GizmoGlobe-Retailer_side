import '../../enums/product_related/category_enum.dart';
import '../../enums/product_related/mainboard_enums/mainboard_form_factor.dart';
import 'product.dart';
import 'ram_related/ram.dart';
import 'psu_related/psu.dart';
import 'cpu_related/cpu.dart';
import 'drive_related/drive.dart';
import 'gpu_related/gpu.dart';
import 'mainboard_related/mainboard.dart';

// helpers imports
import '../../objects/manufacturer.dart';
import '../../enums/product_related/product_status_enum.dart';
import '../../enums/product_related/ram_enums/ram_type.dart';
import '../../enums/product_related/gpu_enums/gpu_series.dart';
import '../../enums/product_related/gpu_enums/gpu_version.dart';
import '../../enums/product_related/cpu_enums/cpu_series.dart';
import '../../enums/product_related/cpu_enums/socket.dart';
import '../../enums/product_related/drive_enums/drive_gen.dart';
import '../../enums/product_related/drive_enums/interface_type.dart';
import '../../enums/product_related/drive_enums/drive_form_factor.dart';
import '../../enums/product_related/drive_enums/drive_type.dart';
import '../../enums/product_related/psu_enums/psu_efficiency.dart';
import '../../enums/product_related/psu_enums/psu_modular.dart';
import 'mainboard_related/ram_spec.dart';
import 'mainboard_related/pcie_slot.dart';
import 'mainboard_related/storage_slot.dart';
import 'mainboard_related/io_port.dart';
import 'psu_related/connector.dart';

class ProductFactory {
  static Product createProduct(
      CategoryEnum category, Map<String, dynamic> properties) {
    // common helpers
    Manufacturer parseManufacturer(dynamic v) {
      if (v == null) return Manufacturer.nullManufacturer;
      if (v is Map<String, dynamic>) {
        return Manufacturer(
          manufacturerID: v['manufacturerID']?.toString(),
          manufacturerName: v['manufacturerName']?.toString() ?? 'Unknown',
        );
      }
      return Manufacturer(
        manufacturerName: v.toString(),
        manufacturerID: v.toString(),
      );
    }

    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int toInt(dynamic v) {
      if (v == null) return 0;
      if (v is num) return (v as num).toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    DateTime parseDate(dynamic v) {
      if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
      if (v is DateTime) return v;
      // assume epoch seconds if numeric
      if (v is num) return DateTime.fromMillisecondsSinceEpoch((v as num).toInt() * 1000);
      final parsed = int.tryParse(v.toString());
      if (parsed != null) return DateTime.fromMillisecondsSinceEpoch(parsed * 1000);
      return DateTime.tryParse(v.toString()) ?? DateTime.fromMillisecondsSinceEpoch(0);
    }

    ProductStatusEnum parseStatus(dynamic v) {
      if (v == null) return ProductStatusEnum.active;
      if (v is ProductStatusEnum) return v;
      try {
        return ProductStatusEnumExtension.fromName(v.toString());
      } catch (_) {
        return ProductStatusEnum.active;
      }
    }

    RAMType parseRamType(dynamic v) {
      if (v == null) return RAMType.unknown;
      try {
        return RAMTypeExtension.fromName(v.toString());
      } catch (_) {
        return RAMType.unknown;
      }
    }

    GPUSeries parseGPUSeries(dynamic v) {
      if (v == null) return GPUSeries.gtx;
      try {
        return GPUSeriesExtension.fromName(v.toString());
      } catch (_) {
        return GPUSeries.gtx;
      }
    }

    GPUVersion parseGPUVersion(dynamic v) {
      if (v == null) return GPUVersion.gddr6;
      try {
        return GPUVersionExtension.fromName(v.toString());
      } catch (_) {
        return GPUVersion.gddr6;
      }
    }

    CPUSeries parseCPUSeries(dynamic v) {
      if (v == null) return CPUSeries.unknown;
      try {
        return CPUSeriesExtension.fromName(v.toString());
      } catch (_) {
        return CPUSeries.unknown;
      }
    }

    Socket parseSocket(dynamic v) {
      if (v == null) return Socket.unknown;
      try {
        return SocketExtension.fromName(v.toString());
      } catch (_) {
        return Socket.unknown;
      }
    }

    DriveGen parseDriveGen(dynamic v) {
      if (v == null) return DriveGen.gen3;
      if (v is num) {
        switch ((v as num).toInt()) {
          case 3:
            return DriveGen.gen3;
          case 4:
            return DriveGen.gen4;
          case 5:
            return DriveGen.gen5;
          default:
            return DriveGen.gen3;
        }
      }
      // try by name
      try {
        return DriveGenExtension.fromName(v.toString());
      } catch (_) {
        return DriveGen.gen3;
      }
    }

    InterfaceType parseInterfaceType(dynamic v) {
      if (v == null) return InterfaceType.sata;
      final s = v.toString().toLowerCase();
      if (s.contains('pcie') || s.contains('nvme')) return InterfaceType.pcie;
      return InterfaceType.sata;
    }

    DriveFormFactor parseDriveFormFactor(dynamic v) {
      if (v == null) return DriveFormFactor.inch3_5;
      try {
        return DriveFormFactorExtension.fromName(v.toString());
      } catch (_) {
        return DriveFormFactor.inch3_5;
      }
    }

    DriveType parseDriveType(dynamic v) {
      if (v == null) return DriveType.hdd;
      final s = v.toString().toLowerCase();
      if (s.contains('hdd')) return DriveType.hdd;
      if (s.contains('nvme') || s.contains('m2_nvme') || s.contains('m2nvme')) return DriveType.m2NVME;
      if (s.contains('m2') && s.contains('ngff')) return DriveType.m2NGFF;
      return DriveType.sataSSD;
    }

    PSUEfficiency parsePSUEfficiency(dynamic v) {
      if (v == null) return PSUEfficiency.gold;
      try {
        return PSUEfficiencyExtension.fromName(v.toString());
      } catch (_) {
        return PSUEfficiency.gold;
      }
    }

    PSUModular parsePSUModular(dynamic v) {
      if (v == null) return PSUModular.fullModular;
      try {
        return PSUModularExtension.fromName(v.toString());
      } catch (_) {
        // handle common variations
        final s = v.toString().toLowerCase();
        if (s.contains('full')) return PSUModular.fullModular;
        if (s.contains('semi')) return PSUModular.semiModular;
        return PSUModular.nonModular;
      }
    }

    // path getter
    dynamic getAttr(String path) => getByPath(properties, path);

    switch (category) {
      case CategoryEnum.ram:
        return RAM(
          productName: properties['productName']?.toString() ?? '',
          manufacturer: parseManufacturer(properties['manufacturer']),
          category: category,
          importPrice: toDouble(properties['importPrice']),
          sellingPrice: toDouble(properties['sellingPrice']),
          discount: toDouble(properties['discount']),
          release: parseDate(properties['release']),
          stock: toInt(properties['stock']),
          sales: toInt(properties['sales']),
          status: parseStatus(properties['status']),
          imageUrl: properties['imageUrl']?.toString(),
          enDescription: properties['enDescription']?.toString(),
          viDescription: properties['viDescription']?.toString(),

          type: parseRamType(getAttr('attributes.type')),
          bus: toInt(getAttr('attributes.bus')),
          clLatency: toInt(getAttr('attributes.clLatency')),
          kitStickCount: toInt(getAttr('attributes.kitConfiguration.stickCount')),
          capacityPerStickGb: toInt(getAttr('attributes.kitConfiguration.capacityPerStickGb')),
        )..productID = properties['productID']?.toString();
      case CategoryEnum.cpu:
        final attrs = getAttr('attributes') as Map<String, dynamic>? ?? {};
        return CPU(
          productName: properties['productName']?.toString() ?? '',
          manufacturer: parseManufacturer(properties['manufacturer']),
          category: category,
          importPrice: toDouble(properties['importPrice']),
          sellingPrice: toDouble(properties['sellingPrice']),
          discount: toDouble(properties['discount']),
          release: parseDate(properties['release']),
          stock: toInt(properties['stock']),
          sales: toInt(properties['sales']),
          status: parseStatus(properties['status']),
          imageUrl: properties['imageUrl']?.toString(),
          enDescription: properties['enDescription']?.toString(),
          viDescription: properties['viDescription']?.toString(),

          series: parseCPUSeries(attrs['series']),
          socket: parseSocket(attrs['socket']),
          core: toInt(attrs['core']),
          thread: toInt(attrs['thread']),
          baseClock: toInt(attrs['baseClock']),
          tdp: toInt(attrs['tdp']),
          turboClock: toInt(attrs['turboClock']),
        )..productID = properties['productID']?.toString();
      case CategoryEnum.psu:
        final attrs = getAttr('attributes') as Map<String, dynamic>? ?? {};
        return PSU(
          productName: properties['productName']?.toString() ?? '',
          manufacturer: parseManufacturer(properties['manufacturer']),
          category: category,
          importPrice: toDouble(properties['importPrice']),
          sellingPrice: toDouble(properties['sellingPrice']),
          discount: toDouble(properties['discount']),
          release: parseDate(properties['release']),

          maxWattage: toInt(attrs['maxWattage']),
          efficiency: parsePSUEfficiency(attrs['efficiency']),
          modularity: parsePSUModular(attrs['modularity'] ?? attrs['modularityity'] ?? attrs['modular']),
          connectors: (attrs['connectors'] is Iterable)
              ? (attrs['connectors'] as Iterable).map((e) => Connector.fromJson(e as Map<String, dynamic>)).toList()
              : <Connector>[],

          stock: toInt(properties['stock']),
          sales: toInt(properties['sales']),
          status: parseStatus(properties['status']),
          imageUrl: properties['imageUrl']?.toString(),
          enDescription: properties['enDescription']?.toString(),
          viDescription: properties['viDescription']?.toString(),
        )..productID = properties['productID']?.toString();
      case CategoryEnum.gpu:
        final attrs = getAttr('attributes') as Map<String, dynamic>? ?? {};
        return GPU(
          productName: properties['productName']?.toString() ?? '',
          manufacturer: parseManufacturer(properties['manufacturer']),
          category: category,
          importPrice: toDouble(properties['importPrice']),
          sellingPrice: toDouble(properties['sellingPrice']),
          discount: toDouble(properties['discount']),
          release: parseDate(properties['release']),

          series: parseGPUSeries(attrs['series']),
          version: parseGPUVersion(attrs['vramVersion'] ?? attrs['vram']),
          memory: toInt(attrs['memory']),
          boostClock: toInt(attrs['boostClock']),
          tdp: toInt(attrs['tdp']),
          ports: (attrs['ports'] is Iterable)
              ? (attrs['ports'] as Iterable).map((e) => IOPort.fromJson(e as Map<String, dynamic>)).toList()
              : <IOPort>[],

          stock: toInt(properties['stock']),
          sales: toInt(properties['sales']),
          status: parseStatus(properties['status']),
          imageUrl: properties['imageUrl']?.toString(),
          enDescription: properties['enDescription']?.toString(),
          viDescription: properties['viDescription']?.toString(),
        )..productID = properties['productID']?.toString();
      case CategoryEnum.mainboard:
        final attrs = getAttr('attributes') as Map<String, dynamic>? ?? {};
        return Mainboard(
          productName: properties['productName']?.toString() ?? '',
          manufacturer: parseManufacturer(properties['manufacturer']),
          category: category,
          importPrice: toDouble(properties['importPrice']),
          sellingPrice: toDouble(properties['sellingPrice']),
          discount: toDouble(properties['discount']),
          release: parseDate(properties['release']),

          chipsetCode: attrs['chipsetCode']?.toString() ?? '',
          socket: parseSocket(attrs['socket']),
          formFactor: (attrs['formFactor'] != null)
              ? MainboardFormFactorExtension.fromName(attrs['formFactor'].toString())
              : MainboardFormFactor.atx,
          ramSpec: (attrs['ramSpec'] is Map<String, dynamic>)
              ? RamSpec.fromJson(attrs['ramSpec'] as Map<String, dynamic>)
              : RamSpec(type: RAMType.unknown, slots: 0, maxSingleDimmGb: 0),
          pcieSlots: (attrs['pcieSlots'] is Iterable)
              ? (attrs['pcieSlots'] as Iterable).map((e) => PCIeSlot.fromJson(e as Map<String, dynamic>)).toList()
              : <PCIeSlot>[],
          storageSlot: (attrs['storageSlots'] is Map<String, dynamic>)
              ? StorageSlot.fromJson(attrs['storageSlots'] as Map<String, dynamic>)
              : StorageSlot(m2Slots: 0, sataPorts: 0),
          ioPorts: (attrs['ioPorts'] is Iterable)
              ? (attrs['ioPorts'] as Iterable).map((e) => IOPort.fromJson(e as Map<String, dynamic>)).toList()
              : <IOPort>[],

          stock: toInt(properties['stock']),
          sales: toInt(properties['sales']),
          status: parseStatus(properties['status']),
          imageUrl: properties['imageUrl']?.toString(),
          enDescription: properties['enDescription']?.toString(),
          viDescription: properties['viDescription']?.toString(),
        )..productID = properties['productID']?.toString();
      case CategoryEnum.drive:
        final attrs = getAttr('attributes') as Map<String, dynamic>? ?? {};
        final speed = attrs['speed'] as Map<String, dynamic>? ?? {};
        return Drive(
          productName: properties['productName']?.toString() ?? '',
          manufacturer: parseManufacturer(properties['manufacturer']),
          category: category,
          importPrice: toDouble(properties['importPrice']),
          sellingPrice: toDouble(properties['sellingPrice']),
          discount: toDouble(properties['discount']),
          release: parseDate(properties['release']),

          gen: parseDriveGen(attrs['gen']),
          memoryGb: toInt(attrs['memoryGb'] ?? attrs['memory'] ?? attrs['capacity']),
          interfaceType: parseInterfaceType(attrs['interfaceType']),
          readMbps: toInt(speed['readMbps']),
          writeMbps: toInt(speed['writeMbps']),
          formFactor: parseDriveFormFactor(attrs['formFactor']),
          driveType: parseDriveType(attrs['driveType'] ?? attrs['driveTypeRaw'] ?? attrs['driveTypeString']),

          sales: toInt(properties['sales']),
          stock: toInt(properties['stock']),
          status: parseStatus(properties['status']),
          imageUrl: properties['imageUrl']?.toString(),
          enDescription: properties['enDescription']?.toString(),
          viDescription: properties['viDescription']?.toString(),
        )..productID = properties['productID']?.toString();
      default:
        throw Exception('Invalid product category');
    }
  }
}

dynamic getByPath(Map<String, dynamic> map, String path) {
  dynamic cur = map;
  for (final seg in path.split('.')) {
    if (cur is Map<String, dynamic> && cur.containsKey(seg)) {
      cur = cur[seg];
    } else {
      return null;
    }
  }
  return cur;
}