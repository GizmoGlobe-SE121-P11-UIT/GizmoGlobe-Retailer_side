import '../../../../enums/invoice_related/payment_status.dart';
import '../../../../objects/invoice_related/incoming_invoice.dart';

class IncomingInvoicePermissions {
  static bool canEditPaymentStatus(String? userRole, IncomingInvoice invoice) {
    return userRole == 'admin' && invoice.status == PaymentStatus.unpaid;
  }
} 