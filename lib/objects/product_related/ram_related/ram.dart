import 'package:gizmoglobe_client/enums/product_related/ram_enums/ram_type.dart';

import '../../../enums/product_related/category_enum.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../manufacturer.dart';
import '../product.dart';

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
    int? importPrice,
    int? sellingPrice,
    int? discount,
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
    double? rating,

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
