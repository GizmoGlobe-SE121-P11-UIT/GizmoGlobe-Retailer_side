import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

enum DialogName {
  empty(''),
  success('success'),
  failure('failure'),
  confirm('confirm');

  final String description;
  const DialogName(this.description);

  String getName() {
    return name;
  }

  String getLocalizedName(BuildContext context) {
    switch (this) {
      case DialogName.empty:
        return '';
      case DialogName.success:
        return S.of(context).success;
      case DialogName.failure:
        return S.of(context).failure;
      case DialogName.confirm:
        return S.of(context).confirm;
    }
  }

  @override
  String toString() {
    return description;
  }
}

extension DialogNameExtension on DialogName {
  static DialogName fromName(String name) {
    return DialogName.values.firstWhere((e) => e.getName() == name);
  }
}
