import 'package:gizmoglobe_client/enums/product_related/cpu_enums/cpu_series.dart';
import 'package:gizmoglobe_client/enums/product_related/cpu_enums/socket.dart';

import '../../../enums/product_related/category_enum.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../manufacturer.dart';
import '../product.dart';

class CPU extends Product {
  CPUSeries series;
  Socket socket;
  int core;
  int thread;
  double baseClock;
  double turboClock;
  int tdp;

  CPU({
    required super.productName,
    required super.importPrice,
    required super.sellingPrice,
    required super.discount,
    required super.release,
    required super.manufacturer,

    super.imageUrl,
    super.enDescription,
    super.viDescription,
    super.category = CategoryEnum.cpu,

    required this.series,
    required this.socket,
    required this.core,
    required this.thread,
    required this.baseClock,
    required this.tdp,
    required this.turboClock,
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
    CPUSeries? series,
    Socket? socket,
    int? core,
    int? thread,
    double? baseClock,
    int? tdp,
    double? turboClock,
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
        stock: stock,
        manufacturer: manufacturer,
        status: status,
        imageUrl: imageUrl,
        enDescription: enDescription,
        viDescription: viDescription
    );

    this.series = series ?? this.series;
    this.socket = socket ?? this.socket;
    this.core = core ?? this.core;
    this.thread = thread ?? this.thread;
    this.baseClock = baseClock ?? this.baseClock;
    this.tdp = tdp ?? this.tdp;
    this.turboClock = turboClock ?? this.turboClock;
  }
}