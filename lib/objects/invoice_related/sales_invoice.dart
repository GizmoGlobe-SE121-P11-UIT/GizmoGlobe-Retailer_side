import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/objects/address_related/address.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice_detail.dart';

import '../../data/database/database.dart';

class SalesInvoice {
  final String salesInvoiceID;
  final String customerID;
  late final String customerName;
  final Address address;
  final DateTime date;
  final PaymentStatus paymentStatus;
  final SalesStatus salesStatus;
  final double totalPrice;
  final double loyaltyPoints;
  List<SalesInvoiceDetail> details;

  SalesInvoice({
    required this.salesInvoiceID,
    required this.customerID,
    required this.customerName,
    required this.address,
    required this.date,
    required this.paymentStatus,
    required this.salesStatus,
    required this.totalPrice,
    required this.loyaltyPoints,
    this.details = const [],
  });

  SalesInvoice copyWith({
    String? salesInvoiceID,
    String? customerID,
    String? customerName,
    Address? address,
    DateTime? date,
    PaymentStatus? paymentStatus,
    SalesStatus? salesStatus,
    double? totalPrice,
    double? loyaltyPoints,
    List<SalesInvoiceDetail>? details,
  }) {
    return SalesInvoice(
      salesInvoiceID: salesInvoiceID ?? this.salesInvoiceID,
      customerID: customerID ?? this.customerID,
      customerName: customerName ?? this.customerName,
      address: address ?? this.address,
      date: date ?? this.date,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      salesStatus: salesStatus ?? this.salesStatus,
      totalPrice: totalPrice ?? this.totalPrice,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'salesInvoiceID': salesInvoiceID,
      'customerID': customerID,
      'customerName': customerName,
      'address': address.addressID,
      'date': Timestamp.fromDate(date),
      'paymentStatus': paymentStatus.getName(),
      'salesStatus': salesStatus.getName(),
      'totalPrice': totalPrice,
      'loyaltyPoints': loyaltyPoints,
    };
  }

  factory SalesInvoice.fromMap(String id, Map<String, dynamic> map) {
    final addressID = map['address'] as String;
    final address = Database().addressList.firstWhere(
          (addr) => addr.addressID == addressID,
          orElse: () => Address.nullAddress,
        );

    return SalesInvoice(
      salesInvoiceID: id,
      customerID: map['customerID'] as String,
      customerName: map['customerName'] as String,
      address: address,
      date: (map['date'] as Timestamp).toDate(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.getName() == map['paymentStatus'],
        orElse: () => PaymentStatus.unpaid,
      ),
      salesStatus: SalesStatus.values.firstWhere(
        (e) => e.getName() == map['salesStatus'],
        orElse: () => SalesStatus.pending,
      ),
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: (map['loyaltyPoints'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return toJson();
  }
}
