import 'package:gizmoglobe_client/enums/product_related/psu_enums/psu_efficiency.dart';
import 'package:gizmoglobe_client/enums/product_related/psu_enums/psu_modular.dart';

import '../../../enums/product_related/category_enum.dart';
import 'connector.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../manufacturer.dart';
import '../product.dart';

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
    int? importPrice,
    int? sellingPrice,
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
