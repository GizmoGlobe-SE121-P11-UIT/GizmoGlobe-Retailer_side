import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

enum PaymentStatus {
  paid('paid'),
  unpaid('unpaid');

  final String description;

  const PaymentStatus(this.description);

  String getName() {
    return name;
  }

  String getLocalizedName(BuildContext context) {
    switch (this) {
      case PaymentStatus.paid:
        return S.of(context).paid;
      case PaymentStatus.unpaid:
        return S.of(context).unpaid;
    }
  }

  @override
  String toString() {
    return description;
  }
}

extension PaymentStatusExtension on PaymentStatus {
  static PaymentStatus fromName(String name) {
    return PaymentStatus.values.firstWhere((e) => e.getName() == name);
  }
}
