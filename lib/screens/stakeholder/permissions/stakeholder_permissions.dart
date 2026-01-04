import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import '../../../../data/database/database.dart';

class StakeholderPermissions {
  static bool canViewCustomers() {
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager ||
        Database().role == RoleEnum.employee;
  }

  static bool canAddCustomers() {
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager;
  }

  static bool canEditCustomers() {
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager;
  }

  static bool canViewEmployees() {
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager;
  }

  static bool canAddEmployees() {
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager;
  }

  static bool canEditEmployees() {
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager;
  }

  static bool canPromoteEmployees() {
    return Database().role == RoleEnum.owner;
  }

  static bool canFireEmployees() {
    return Database().role == RoleEnum.owner;
  }

  static bool canViewVendors() {
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager ||
        Database().role == RoleEnum.employee;
  }

  static bool canAddVendors() {
    return Database().role == RoleEnum.owner;
  }

  static bool canEditVendors() {
    return Database().role == RoleEnum.owner;
  }

  static bool canManageVendors() {
    return Database().role == RoleEnum.owner;
  }
}
