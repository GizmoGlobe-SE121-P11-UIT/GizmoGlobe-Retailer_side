import 'package:flutter/widgets.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

enum ProductStatusEnum {
  active('Active'), // Đang hoạt động
  outOfStock('Out of Stock'), // Hết hàng
  discontinued('Discontinued'); // Ngừng kinh doanh

  final String description;

  const ProductStatusEnum(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }
}

extension ProductStatusEnumExtension on ProductStatusEnum {
  static ProductStatusEnum fromName(String name) {
    return ProductStatusEnum.values.firstWhere((e) => e.getName() == name);
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
    }
  }
}
