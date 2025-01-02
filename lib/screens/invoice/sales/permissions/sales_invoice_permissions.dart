import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';

class SalesInvoicePermissions {
  static bool canEditInvoice(String userRole, SalesInvoice invoice) {
    if ((invoice.salesStatus == SalesStatus.completed ||
        invoice.salesStatus == SalesStatus.shipping ||
        invoice.salesStatus == SalesStatus.shipped) &&
        invoice.paymentStatus == PaymentStatus.paid) {
      return false;
    }
    return userRole == 'admin';
  }

  static bool canEditPaymentStatus(String userRole, SalesInvoice invoice) {    
    if (invoice.paymentStatus == PaymentStatus.paid) {
      return false;
    }
    return userRole == 'admin';
  }

  static bool canEditSalesStatus(String userRole, SalesInvoice invoice) {
    if (invoice.salesStatus == SalesStatus.completed || 
        invoice.salesStatus == SalesStatus.shipping ||
        invoice.salesStatus == SalesStatus.shipped) {
      return false;
    }
    return userRole == 'admin';
  }

  static bool canEditAddress(String userRole, SalesInvoice invoice) {
    if (invoice.salesStatus == SalesStatus.completed || 
        invoice.salesStatus == SalesStatus.shipping) {
      return false;
    }
    return userRole == 'admin';
  }
} 