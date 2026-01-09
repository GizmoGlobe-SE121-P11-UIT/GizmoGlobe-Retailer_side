import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

enum SalesStatus {
  pending('pending'),
  preparing('preparing'),
  shipping('shipping'),
  shipped('shipped'),
  received('received'),
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
      case SalesStatus.received:
        return S.of(context).received;
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

  static List<SalesStatus> nextStatus(SalesStatus currentStatus) {
    switch (currentStatus) {
      case SalesStatus.pending:
        return [SalesStatus.pending, SalesStatus.preparing, SalesStatus.cancelled];
      case SalesStatus.preparing:
        return [SalesStatus.preparing, SalesStatus.shipping, SalesStatus.cancelled];
      case SalesStatus.shipping:
        return [SalesStatus.shipping, SalesStatus.shipped];
      default:
        return [currentStatus];
    }
  }

  static List<SalesStatus> outOfStockStatus(SalesStatus currentStatus) {
    return [currentStatus, SalesStatus.cancelled];
  }
}

extension SalesStatusExtension on SalesStatus {
  static SalesStatus fromName(String name) {
    return SalesStatus.values.firstWhere((e) => e.getName() == name);
  }
}
