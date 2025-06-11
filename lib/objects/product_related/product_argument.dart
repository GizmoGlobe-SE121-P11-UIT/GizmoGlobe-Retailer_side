import 'package:gizmoglobe_client/enums/product_related/cpu_enums/cpu_family.dart';
import 'package:gizmoglobe_client/enums/product_related/gpu_enums/gpu_bus.dart';
import 'package:gizmoglobe_client/enums/product_related/gpu_enums/gpu_capacity.dart';
import 'package:gizmoglobe_client/enums/product_related/gpu_enums/gpu_series.dart';
import 'package:gizmoglobe_client/enums/product_related/psu_enums/psu_efficiency.dart';
import 'package:gizmoglobe_client/enums/product_related/psu_enums/psu_modular.dart';
import 'package:gizmoglobe_client/enums/product_related/ram_enums/ram_bus.dart';
import 'package:gizmoglobe_client/enums/product_related/ram_enums/ram_capacity_enum.dart';
import 'package:gizmoglobe_client/enums/product_related/ram_enums/ram_type.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/product_related/psu.dart';
import 'package:gizmoglobe_client/objects/product_related/ram.dart';

import '../../enums/product_related/category_enum.dart';
import '../../enums/product_related/drive_enums/drive_capacity.dart';
import '../../enums/product_related/drive_enums/drive_type.dart';
import '../../enums/product_related/mainboard_enums/mainboard_compatibility.dart';
import '../../enums/product_related/mainboard_enums/mainboard_form_factor.dart';
import '../../enums/product_related/mainboard_enums/mainboard_series.dart';
import '../../enums/product_related/product_status_enum.dart';
import '../manufacturer.dart';
import 'cpu.dart';
import 'drive.dart';
import 'gpu.dart';
import 'mainboard.dart';

class ProductArgument {
  String? productID;
  String? productName;
  CategoryEnum? category;
  double? importPrice;
  double? sellingPrice;
  double? discount;
  DateTime? release;
  int? sales;
  int? stock;
  Manufacturer? manufacturer;
  ProductStatusEnum? status;
  String? imageUrl;
  String? enDescription;
  String? viDescription;

  // RAM specific properties
  RAMBus? ramBus;
  RAMCapacity? ramCapacity;
  RAMType? ramType;

  // CPU specific properties
  CPUFamily? family;
  int? core;
  int? thread;
  double? cpuClockSpeed;

  // PSU specific properties
  int? wattage;
  PSUEfficiency? efficiency;
  PSUModular? modular;

  // GPU specific properties
  GPUSeries? gpuSeries;
  GPUCapacity? gpuCapacity;
  GPUBus? gpuBus;
  double? gpuClockSpeed;

  // Mainboard specific properties
  MainboardFormFactor? formFactor;
  MainboardSeries? mainboardSeries;
  MainboardCompatibility? compatibility;

  // Drive specific properties
  DriveType? driveType;
  DriveCapacity? driveCapacity;

  ProductArgument({
    this.productID,
    this.productName,
    this.manufacturer,
    this.category,
    this.importPrice,
    this.sellingPrice,
    this.discount,
    this.release,
    this.sales,
    this.stock,
    this.status,
    this.ramBus,
    this.ramCapacity,
    this.ramType,
    this.family,
    this.core,
    this.thread,
    this.cpuClockSpeed,
    this.wattage,
    this.efficiency,
    this.modular,
    this.gpuSeries,
    this.gpuCapacity,
    this.gpuBus,
    this.gpuClockSpeed,
    this.formFactor,
    this.mainboardSeries,
    this.compatibility,
    this.driveType,
    this.driveCapacity,
    this.imageUrl,
    this.enDescription,
    this.viDescription,
  });

  bool get isEnEmpty {
    return enDescription == null || enDescription!.isEmpty;
  }

  bool get isViEmpty {
    return viDescription == null || viDescription!.isEmpty;
  }

  ProductArgument copyWith(
      {String? productID,
      String? productName,
      Manufacturer? manufacturer,
      CategoryEnum? category,
      double? importPrice,
      double? sellingPrice,
      double? discount,
      DateTime? release,
      int? sales,
      int? stock,
      ProductStatusEnum? status,
      RAMBus? ramBus,
      RAMCapacity? ramCapacity,
      RAMType? ramType,
      CPUFamily? family,
      int? core,
      int? thread,
      double? cpuClockSpeed,
      int? wattage,
      PSUEfficiency? efficiency,
      PSUModular? modular,
      GPUSeries? gpuSeries,
      GPUCapacity? gpuCapacity,
      GPUBus? gpuBus,
      double? gpuClockSpeed,
      MainboardFormFactor? formFactor,
      MainboardSeries? mainboardSeries,
      MainboardCompatibility? compatibility,
      DriveType? driveType,
      DriveCapacity? driveCapacity,
      String? imageUrl,
      String? enDescription,
      String? viDescription
      }) {
    return ProductArgument(
      productID: productID ?? this.productID,
      productName: productName ?? this.productName,
      manufacturer: manufacturer ?? this.manufacturer,
      category: category ?? this.category,
      importPrice: importPrice ?? this.importPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      discount: discount ?? this.discount,
      release: release ?? this.release,
      sales: sales ?? this.sales,
      stock: stock ?? this.stock,
      status: status ?? this.status,
      ramBus: ramBus ?? this.ramBus,
      ramCapacity: ramCapacity ?? this.ramCapacity,
      ramType: ramType ?? this.ramType,
      family: family ?? this.family,
      core: core ?? this.core,
      thread: thread ?? this.thread,
      cpuClockSpeed: cpuClockSpeed ?? this.cpuClockSpeed,
      wattage: wattage ?? this.wattage,
      efficiency: efficiency ?? this.efficiency,
      modular: modular ?? this.modular,
      gpuSeries: gpuSeries ?? this.gpuSeries,
      gpuCapacity: gpuCapacity ?? this.gpuCapacity,
      gpuBus: gpuBus ?? this.gpuBus,
      gpuClockSpeed: gpuClockSpeed ?? this.gpuClockSpeed,
      formFactor: formFactor ?? this.formFactor,
      mainboardSeries: mainboardSeries ?? this.mainboardSeries,
      compatibility: compatibility ?? this.compatibility,
      driveType: driveType ?? this.driveType,
      driveCapacity: driveCapacity ?? this.driveCapacity,
      imageUrl: imageUrl ?? this.imageUrl,
      enDescription: enDescription ?? this.enDescription,
      viDescription: viDescription ?? this.viDescription,
    );
  }

  Product buildProduct() {
    switch (category) {
      case CategoryEnum.ram:
        return RAM(
          productName: productName!,
          manufacturer: manufacturer!,
          category: category!,
          importPrice: importPrice!,
          sellingPrice: sellingPrice!,
          discount: discount!,
          release: release!,
          stock: stock!,
          sales: sales!,
          status: status!,
          bus: ramBus!,
          capacity: ramCapacity!,
          ramType: ramType!,
          imageUrl: imageUrl,
          enDescription: enDescription,
          viDescription: viDescription,
        )..productID = productID;
      case CategoryEnum.cpu:
        return CPU(
          productName: productName!,
          manufacturer: manufacturer!,
          category: category!,
          importPrice: importPrice!,
          sellingPrice: sellingPrice!,
          discount: discount!,
          release: release!,
          family: family!,
          core: core!,
          thread: thread!,
          clockSpeed: cpuClockSpeed!,
          stock: stock!,
          sales: sales!,
          status: status!,
          imageUrl: imageUrl,
          enDescription: enDescription,
          viDescription: viDescription,
        )..productID = productID;
      case CategoryEnum.psu:
        return PSU(
          productName: productName!,
          manufacturer: manufacturer!,
          category: category!,
          importPrice: importPrice!,
          sellingPrice: sellingPrice!,
          discount: discount!,
          release: release!,
          wattage: wattage!,
          efficiency: efficiency!,
          modular: modular!,
          stock: stock!,
          sales: sales!,
          status: status!,
          imageUrl: imageUrl,
          enDescription: enDescription,
          viDescription: viDescription,
        )..productID = productID;
      case CategoryEnum.gpu:
        return GPU(
          productName: productName!,
          manufacturer: manufacturer!,
          category: category!,
          importPrice: importPrice!,
          sellingPrice: sellingPrice!,
          discount: discount!,
          release: release!,
          series: gpuSeries!,
          capacity: gpuCapacity!,
          bus: gpuBus!,
          clockSpeed: gpuClockSpeed!,
          stock: stock!,
          sales: sales!,
          status: status!,
          imageUrl: imageUrl,
          enDescription: enDescription,
          viDescription: viDescription,
        )..productID = productID;
      case CategoryEnum.mainboard:
        return Mainboard(
          productName: productName!,
          manufacturer: manufacturer!,
          category: category!,
          importPrice: importPrice!,
          sellingPrice: sellingPrice!,
          discount: discount!,
          release: release!,
          formFactor: formFactor!,
          series: mainboardSeries!,
          compatibility: compatibility!,
          stock: stock!,
          sales: sales!,
          status: status!,
          imageUrl: imageUrl,
          enDescription: enDescription,
          viDescription: viDescription,
        )..productID = productID;
      case CategoryEnum.drive:
        return Drive(
          productName: productName!,
          manufacturer: manufacturer!,
          category: category!,
          importPrice: importPrice!,
          sellingPrice: sellingPrice!,
          discount: discount!,
          release: release!,
          type: driveType!,
          capacity: driveCapacity!,
          stock: stock!,
          sales: sales!,
          status: status!,
          imageUrl: imageUrl,
          enDescription: enDescription,
          viDescription: viDescription,
        )..productID = productID;
      default:
        throw Exception('Invalid product category');
    }
  }

  static ProductArgument fromProduct(Product product) {
    ProductArgument result = ProductArgument(
      productID: product.productID,
      productName: product.productName,
      manufacturer: product.manufacturer,
      category: product.category,
      importPrice: product.importPrice,
      sellingPrice: product.sellingPrice,
      discount: product.discount,
      release: product.release,
      sales: product.sales,
      stock: product.stock,
      status: product.status,
      imageUrl: product.imageUrl,
      enDescription: product.enDescription,
      viDescription: product.viDescription,
    );
    switch (product.category) {
      case CategoryEnum.ram:
        return result.copyWith(
          ramBus: (product as RAM).bus,
          ramCapacity: (product).capacity,
          ramType: (product).ramType,
        );
      case CategoryEnum.cpu:
        return result.copyWith(
          family: (product as CPU).family,
          core: (product).core,
          thread: (product).thread,
          cpuClockSpeed: (product).clockSpeed,
        );
      case CategoryEnum.psu:
        return result.copyWith(
          wattage: (product as PSU).wattage,
          efficiency: (product).efficiency,
          modular: (product).modular,
        );
      case CategoryEnum.gpu:
        return result.copyWith(
          gpuSeries: (product as GPU).series,
          gpuCapacity: (product).capacity,
          gpuBus: (product).bus,
          gpuClockSpeed: (product).clockSpeed,
        );
      case CategoryEnum.mainboard:
        return result.copyWith(
          formFactor: (product as Mainboard).formFactor,
          mainboardSeries: (product).series,
          compatibility: (product).compatibility,
        );
      case CategoryEnum.drive:
        return result.copyWith(
          driveType: (product as Drive).type,
          driveCapacity: (product).capacity,
        );
      default:
        throw Exception('Invalid product category');
    }
  }
}
