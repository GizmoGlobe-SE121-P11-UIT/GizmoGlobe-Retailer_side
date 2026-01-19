import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:flutter/widgets.dart';

enum RoleEnum {
  owner('Owner'), // Chủ sở hữu
  manager('Manager'), // Quản lý
  employee('Employee'), // Nhân viên
  unknown('Unknown');

  final String description;

  const RoleEnum(this.description);

  String getName() {
    return name;
  }

  String localizedName(BuildContext context) {
    switch (this) {
      case RoleEnum.owner:
        return S.of(context).roleOwner;
      case RoleEnum.manager:
        return S.of(context).roleManager;
      case RoleEnum.employee:
        return S.of(context).roleEmployee;
      default:
        return S.of(context).unknown;
    }
  }

  @override
  String toString() {
    return description;
  }
}

extension RoleEnumExtension on RoleEnum {
  static RoleEnum fromName(String name) {
    return RoleEnum.values.firstWhere(
      (e) => e.getName().toLowerCase() == name.toLowerCase(),
      orElse: () => RoleEnum.unknown,
    );
  }
}
