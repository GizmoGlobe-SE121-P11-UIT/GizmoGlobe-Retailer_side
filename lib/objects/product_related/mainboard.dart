import 'package:gizmoglobe_client/enums/product_related/mainboard_enums/mainboard_compatibility.dart';
import 'package:gizmoglobe_client/enums/product_related/mainboard_enums/mainboard_form_factor.dart';
import 'package:gizmoglobe_client/enums/product_related/mainboard_enums/mainboard_series.dart';
import 'package:gizmoglobe_client/enums/product_related/product_status_enum.dart';

import '../../enums/product_related/category_enum.dart';
import '../manufacturer.dart';
import 'product.dart';

class Mainboard extends Product {
  MainboardFormFactor formFactor;
  MainboardSeries series;
  MainboardCompatibility compatibility;

  Mainboard({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,
    super.category = CategoryEnum.mainboard,
    required this.formFactor,
    required this.series,
    required this.compatibility,
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
    MainboardFormFactor? formFactor,
    MainboardSeries? series,
    MainboardCompatibility? compatibility,
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

    this.formFactor = formFactor ?? this.formFactor;
    this.series = series ?? this.series;
    this.compatibility = compatibility ?? this.compatibility;
  }
}
