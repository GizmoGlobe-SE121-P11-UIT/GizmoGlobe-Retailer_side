import 'package:gizmoglobe_client/data/database/database.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';

import '../../../../enums/invoice_related/payment_status.dart';
import '../../../../objects/invoice_related/incoming_invoice.dart';

class IncomingInvoicePermissions {
  static bool canEditPaymentStatus(IncomingInvoice invoice) {
    return (Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager) &&
        invoice.status == PaymentStatus.unpaid;
  }
} 