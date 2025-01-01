import '../../../../enums/invoice_related/warranty_status.dart';
import '../../../../objects/invoice_related/warranty_invoice.dart';

class WarrantyInvoicePermissions {
  static bool canEditStatus(String? userRole, WarrantyInvoice invoice) {
    return userRole == 'admin' && 
           invoice.status != WarrantyStatus.completed && 
           invoice.status != WarrantyStatus.denied;
  }
} 