import 'package:gizmoglobe_client/data/database/database.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';

class SalesInvoicePermissions {
  static bool canEditInvoice(SalesInvoice invoice) {
    if ((invoice.salesStatus == SalesStatus.completed ||
            invoice.salesStatus == SalesStatus.cancelled ||
            invoice.salesStatus == SalesStatus.shipped) &&
        invoice.paymentStatus == PaymentStatus.paid) {
      return false;
    }
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager ||
        Database().role == RoleEnum.employee;
  }

  static bool canEditPaymentStatus(SalesInvoice invoice) {
    if (invoice.paymentStatus == PaymentStatus.paid) {
      return false;
    }
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager ||
        Database().role == RoleEnum.employee;
  }

  static bool canEditSalesStatus(SalesInvoice invoice) {
    if (invoice.salesStatus == SalesStatus.completed ||
        invoice.salesStatus == SalesStatus.cancelled ||
        invoice.salesStatus == SalesStatus.shipped) {
      return false;
    }
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager ||
        Database().role == RoleEnum.employee;
  }

  static bool canEditAddress(SalesInvoice invoice) {
    if (invoice.salesStatus == SalesStatus.completed ||
        invoice.salesStatus == SalesStatus.cancelled ||
        invoice.salesStatus == SalesStatus.shipping ||
        invoice.salesStatus == SalesStatus.shipped) {
      return false;
    }
    return Database().role == RoleEnum.owner ||
        Database().role == RoleEnum.manager ||
        Database().role == RoleEnum.employee;
  }
}
