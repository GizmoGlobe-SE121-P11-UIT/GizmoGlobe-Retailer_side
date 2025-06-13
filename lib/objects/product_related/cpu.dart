import 'package:gizmoglobe_client/enums/product_related/cpu_enums/cpu_family.dart';

import '../../enums/product_related/category_enum.dart';
import '../../enums/product_related/product_status_enum.dart';
import '../manufacturer.dart';
import 'product.dart';

class CPU extends Product {
  CPUFamily family;
  int core;
  int thread;
  double clockSpeed;

  CPU({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,
    super.category = CategoryEnum.cpu,
    required this.family,
    required this.core,
    required this.thread,
    required this.clockSpeed,
    required super.sales,
    required super.stock,
    required super.status,
    super.imageUrl,

    super.enDescription,
    super.viDescription,
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
    CPUFamily? family,
    int? core,
    int? thread,
    double? clockSpeed,
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

    this.family = family ?? this.family;
    this.core = core ?? this.core;
    this.thread = thread ?? this.thread;
    this.clockSpeed = clockSpeed ?? this.clockSpeed;
  }
}
