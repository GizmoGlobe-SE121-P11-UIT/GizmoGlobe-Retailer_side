import 'package:gizmoglobe_client/data/database/database.dart';

import '../../../../enums/invoice_related/warranty_status.dart';
import '../../../../enums/stakeholders/employee_role.dart';
import '../../../../objects/invoice_related/warranty_invoice.dart';

class WarrantyInvoicePermissions {
  static bool canEditStatus(WarrantyInvoice invoice) {
    return invoice.status != WarrantyStatus.completed &&
           invoice.status != WarrantyStatus.denied &&
          (Database().role == RoleEnum.owner ||
            Database().role == RoleEnum.manager ||
            Database().role == RoleEnum.employee);
  }
} 