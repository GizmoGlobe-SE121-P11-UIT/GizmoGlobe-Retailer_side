import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gizmoglobe_client/enums/invoice_related/warranty_status.dart';
import 'package:gizmoglobe_client/objects/invoice_related/warranty_invoice_detail.dart';

class WarrantyInvoice {
  String? warrantyInvoiceID;
  String customerID;
  String salesInvoiceID;
  DateTime date;
  WarrantyStatus status;
  String reason;
  String? customerName;
  List<WarrantyInvoiceDetail> details;

  WarrantyInvoice({
    this.warrantyInvoiceID,
    required this.customerID,
    required this.salesInvoiceID,
    required this.date,
    required this.status,
    required this.reason,
    this.customerName,
    this.details = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'customerID': customerID,
      'salesInvoiceID': salesInvoiceID,
      'date': Timestamp.fromDate(date),
      'status': status.getName(),
      'reason': reason,
      'customerName': customerName,
    };
  }

  static WarrantyInvoice fromMap(String id, Map<String, dynamic> map) {
    return WarrantyInvoice(
      warrantyInvoiceID: id,
      customerID: map['customerID'] ?? '',
      salesInvoiceID: map['salesInvoiceID'] ?? '',
      date: (map['date'] as Timestamp).toDate(),
      status: WarrantyStatus.values.firstWhere(
        (e) => e.getName().toLowerCase() == (map['status'] as String? ?? 'pending').toLowerCase(),
        orElse: () => WarrantyStatus.pending,
      ),
      reason: map['reason'] ?? '',
      customerName: map['customerName'],
    );
  }

  WarrantyInvoice copyWith({
    String? warrantyInvoiceID,
    String? customerID,
    String? salesInvoiceID,
    DateTime? date,
    WarrantyStatus? status,
    String? reason,
    String? customerName,
    List<WarrantyInvoiceDetail>? details,
  }) {
    return WarrantyInvoice(
      warrantyInvoiceID: warrantyInvoiceID ?? this.warrantyInvoiceID,
      customerID: customerID ?? this.customerID,
      salesInvoiceID: salesInvoiceID ?? this.salesInvoiceID,
      date: date ?? this.date,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      customerName: customerName ?? this.customerName,
      details: details ?? this.details,
    );
  }
} 