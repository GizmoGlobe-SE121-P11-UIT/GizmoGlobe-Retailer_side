import 'package:gizmoglobe_client/enums/product_related/psu_enums/psu_efficiency.dart';
import 'package:gizmoglobe_client/enums/product_related/psu_enums/psu_modular.dart';

import '../../enums/product_related/category_enum.dart';
import '../../enums/product_related/product_status_enum.dart';
import '../manufacturer.dart';
import 'product.dart';

class PSU extends Product {
  int wattage;
  PSUEfficiency efficiency;
  PSUModular modular;

  PSU({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,
    super.category = CategoryEnum.psu,
    required this.wattage,
    required this.efficiency,
    required this.modular,
    required super.sales,
    required super.stock,
    required super.status,
    String? imageUrl,

    String? enDescription,
    String? viDescription,
  }) : super(
    imageUrl: imageUrl,
    enDescription: enDescription,
    viDescription: viDescription,
  );

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
    int? wattage,
    PSUEfficiency? efficiency,
    PSUModular? modular,
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

    this.wattage = wattage ?? this.wattage;
    this.efficiency = efficiency ?? this.efficiency;
    this.modular = modular ?? this.modular;
  }
}
