import 'package:flutter/widgets.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

enum ProductStatusEnum {
  unknown('Unknown'),
  active('Active'),
  outOfStock('Out of Stock'),
  discontinued('Discontinued');

  final String description;

  const ProductStatusEnum(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }

  factory ProductStatusEnum.fromJson(Map<String, dynamic> json) {
    String name = json['status'] ?? 'Unknown';
    return ProductStatusEnumExtension.fromName(name);
  }
}

extension ProductStatusEnumExtension on ProductStatusEnum {
  static ProductStatusEnum fromName(String name) {
    return ProductStatusEnum.values.firstWhere(
      (e) => e.getName() == name,
      orElse: () => ProductStatusEnum.unknown,
    );
  }
}

// Add localization extension
extension ProductStatusEnumLocalized on ProductStatusEnum {
  String localized(BuildContext context) {
    switch (this) {
      case ProductStatusEnum.active:
        return S.of(context).active;
      case ProductStatusEnum.outOfStock:
        return S.of(context).outOfStock;
      case ProductStatusEnum.discontinued:
        return S.of(context).discontinued;
      default:
        return S.of(context).unknown;
    }
  }
}
