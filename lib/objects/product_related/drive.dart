import 'package:gizmoglobe_client/enums/product_related/drive_enums/drive_capacity.dart';
import 'package:gizmoglobe_client/enums/product_related/drive_enums/drive_type.dart';

import '../../enums/product_related/category_enum.dart';
import '../manufacturer.dart';
import 'product.dart';

class Drive extends Product {
  DriveType type;
  DriveCapacity capacity;

  Drive({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,
    super.category = CategoryEnum.drive,
    required this.type,
    required this.capacity,
    required super.sales,
    required super.stock,
    required super.status,
  });

  @override
  void updateProduct({
    String? productName,
    double? importPrice,
    double? sellingPrice,
    double? discount,
    DateTime? release,
    int? sales,
    int? stock,
    Manufacturer? manufacturer,
    DriveType? type,
    DriveCapacity? capacity,
  }) {
    super.updateProduct(
      productName: productName,
      importPrice: importPrice,
      sellingPrice: sellingPrice,
      discount: discount,
      release: release,
      sales: sales,
      manufacturer: manufacturer,
    );

    this.type = type ?? this.type;
    this.capacity = capacity ?? this.capacity;
  }
}