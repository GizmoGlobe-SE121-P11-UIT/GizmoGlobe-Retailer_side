import 'package:gizmoglobe_client/enums/product_related/gpu_enums/gpu_series.dart';
import 'package:gizmoglobe_client/enums/product_related/product_status_enum.dart';

import '../../../enums/product_related/category_enum.dart';
import '../../../enums/product_related/gpu_enums/gpu_version.dart';
import '../mainboard_related/io_port.dart';
import '../../manufacturer.dart';
import '../product.dart';

class GPU extends Product {
  GPUSeries series;
  GPUVersion version;
  int memory;
  double boostClock;
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
    required this.memory,
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
    int? importPrice,
    int? sellingPrice,
    double? discount,
    DateTime? release,
    int? sales,
    int? stock,
    Manufacturer? manufacturer,
    GPUSeries? series,
    GPUVersion? version,
    int? memory,
    double? boostClock,
    int? tdp,
    List<IOPort>? ports,
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
    this.memory = memory ?? this.memory;
    this.boostClock = boostClock ?? this.boostClock;
    this.tdp = tdp ?? this.tdp;
    this.ports = ports ?? this.ports;
  }
}