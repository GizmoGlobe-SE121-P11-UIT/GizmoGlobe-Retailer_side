import 'package:gizmoglobe_client/enums/product_related/ram_enums/ram_bus.dart';
import 'package:gizmoglobe_client/enums/product_related/ram_enums/ram_capacity_enum.dart';
import 'package:gizmoglobe_client/enums/product_related/ram_enums/ram_type.dart';

import '../../enums/product_related/category_enum.dart';
import '../../enums/product_related/product_status_enum.dart';
import '../manufacturer.dart';
import 'product.dart';

class RAM extends Product {
  RAMBus bus;
  RAMCapacity capacity;
  RAMType ramType;

  RAM({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,
    super.category = CategoryEnum.ram,
    required this.bus,
    required this.capacity,
    required this.ramType,
    required super.sales,
    required super.stock,
    required super.status,
    String? imageUrl,
  }) : super(imageUrl: imageUrl);

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
    RAMBus? bus,
    RAMCapacity? capacity,
    RAMType? ramType,
    ProductStatusEnum? status,
    String? imageUrl,
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
    );

    this.bus = bus ?? this.bus;
    this.capacity = capacity ?? this.capacity;
    this.ramType = ramType ?? this.ramType;
  }
}
