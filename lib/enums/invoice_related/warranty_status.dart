import 'package:flutter/widgets.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

enum WarrantyStatus {
  pending("Pending"), //Đang chờ
  processing("Processing"), //Đang xử lý
  completed("Completed"), //Đã hoàn thành
  denied("Denied"); //Từ chối

  final String description;

  const WarrantyStatus(this.description);

  String getName() {
    return name;
  }

  @override
  String toString() {
    return description;
  }
}

extension WarrantyStatusExtension on WarrantyStatus {
  static WarrantyStatus fromName(String name) {
    return WarrantyStatus.values.firstWhere((e) => e.getName() == name);
  }
}

extension WarrantyStatusLocalized on WarrantyStatus {
  String localized(BuildContext context) {
    switch (this) {
      case WarrantyStatus.pending:
        return S.of(context).warrantyStatus_pending;
      case WarrantyStatus.processing:
        return S.of(context).warrantyStatus_processing;
      case WarrantyStatus.completed:
        return S.of(context).warrantyStatus_completed;
      case WarrantyStatus.denied:
        return S.of(context).warrantyStatus_denied;
    }
  }
}
