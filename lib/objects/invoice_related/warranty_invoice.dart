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
    // Ensure we have a real Dart Map (not a JS interop proxy on web)
    final Map<String, dynamic> m = Map<String, dynamic>.from(map);

    final dynamic rawDate = m['date'];
    DateTime parsedDate;
    if (rawDate is Timestamp) {
      parsedDate = rawDate.toDate();
    } else if (rawDate is DateTime) {
      parsedDate = rawDate;
    } else if (rawDate is String) {
      parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    final String statusString = (m['status'] as String? ?? 'pending');
    final WarrantyStatus parsedStatus = WarrantyStatus.values.firstWhere(
      (e) => e.getName().toLowerCase() == statusString.toLowerCase(),
      orElse: () => WarrantyStatus.pending,
    );

    return WarrantyInvoice(
      warrantyInvoiceID: id,
      customerID: (m['customerID'] as String?) ?? '',
      salesInvoiceID: (m['salesInvoiceID'] as String?) ?? '',
      date: parsedDate,
      status: parsedStatus,
      reason: (m['reason'] as String?) ?? '',
      customerName: m['customerName'] as String?,
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
