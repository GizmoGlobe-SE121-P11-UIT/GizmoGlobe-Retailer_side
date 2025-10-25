import 'package:gizmoglobe_client/enums/product_related/drive_enums/drive_type.dart';
import 'package:gizmoglobe_client/objects/product_related/drive_related/speed.dart';

import '../../../enums/product_related/category_enum.dart';
import '../../../enums/product_related/drive_enums/drive_form_factor.dart';
import '../../../enums/product_related/drive_enums/drive_gen.dart';
import '../../../enums/product_related/drive_enums/interface_type.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../manufacturer.dart';
import '../product.dart';

class Drive extends Product {
  DriveGen gen;
  int memoryGb;
  InterfaceType interfaceType;
  Speed speed;
  DriveFormFactor formFactor;
  DriveType driveType;

  Drive({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,

    super.imageUrl,
    super.enDescription,
    super.viDescription,
    super.category = CategoryEnum.drive,

    required this.gen,
    required this.memoryGb,
    required this.interfaceType,
    required this.speed,
    required this.formFactor,
    required this.driveType,
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
    DriveGen? gen,
    int? memoryGb,
    InterfaceType? interfaceType,
    Speed? speed,
    DriveFormFactor? formFactor,
    DriveType? driveType,
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

    this.gen = gen ?? this.gen;
    this.memoryGb = memoryGb ?? this.memoryGb;
    this.interfaceType = interfaceType ?? this.interfaceType;
    this.speed = speed ?? this.speed;
    this.formFactor = formFactor ?? this.formFactor;
    this.driveType = driveType ?? this.driveType;
  }
}


