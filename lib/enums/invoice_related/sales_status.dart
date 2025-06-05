import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

enum SalesStatus {
  pending('pending'),
  preparing('preparing'),
  shipping('shipping'),
  shipped('shipped'),
  completed('completed'),
  cancelled('cancelled');

  final String key;

  const SalesStatus(this.key);

  String getName() {
    return name;
  }

  String getLocalizedName(BuildContext context) {
    switch (this) {
      case SalesStatus.pending:
        return S.of(context).pending;
      case SalesStatus.preparing:
        return S.of(context).preparing;
      case SalesStatus.shipping:
        return S.of(context).shipping;
      case SalesStatus.shipped:
        return S.of(context).shipped;
      case SalesStatus.completed:
        return S.of(context).completed;
      case SalesStatus.cancelled:
        return S.of(context).cancelled;
    }
  }

  @override
  String toString() {
    return key;
  }
}

extension SalesStatusExtension on SalesStatus {
  static SalesStatus fromName(String name) {
    return SalesStatus.values.firstWhere((e) => e.getName() == name);
  }
}
