import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';
import 'package:gizmoglobe_client/enums/product_related/psu_enums/psu_efficiency.dart';
import 'package:gizmoglobe_client/enums/product_related/psu_enums/psu_modular.dart';
import 'package:gizmoglobe_client/enums/product_related/ram_enums/ram_type.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import '../../../enums/product_related/drive_enums/drive_type.dart';
import '../../../enums/product_related/gpu_enums/gpu_series.dart';
import '../../../enums/product_related/mainboard_enums/mainboard_form_factor.dart';
import '../../enums/product_related/cpu_enums/cpu_series.dart';
import '../../enums/product_related/cpu_enums/socket.dart';
import '../../enums/product_related/drive_enums/drive_form_factor.dart';
import '../../enums/product_related/drive_enums/drive_gen.dart';
import '../../enums/product_related/drive_enums/interface_type.dart';
import '../../enums/product_related/gpu_enums/gpu_version.dart';

class FilterArgument {
  final List<Manufacturer> manufacturerList;
  final String minStock;
  final String maxStock;
  final String minPrice;
  final String maxPrice;

  final CategoryEnum category;

  final List<CPUSeries> cpuSeries;

  final List<Socket> sockets;

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
    this.cpuSeries = const [],
    this.sockets = const [],
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
    List<CPUSeries>? cpuSeries,
    List<Socket>? sockets,
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
      sockets: sockets ?? this.sockets,
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
  }
}
