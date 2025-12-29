import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import '../../../../data/database/database.dart';

class ProductPermissions {
  static bool canAddProducts() {
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager;
  }

  static bool canEditProducts() {
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager;
  }

  static bool canDiscontinueProducts() {
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager;
  }
}