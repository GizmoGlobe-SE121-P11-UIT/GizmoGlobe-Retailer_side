import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/objects/address_related/address.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice_detail.dart';

import '../../data/database/database.dart';

class SalesInvoice {
  String? salesInvoiceID;
  String customerID;
  String? customerName;
  Address address;
  DateTime date;
  PaymentStatus paymentStatus;
  SalesStatus salesStatus;
  double totalPrice;
  List<SalesInvoiceDetail> details;

  SalesInvoice({
    this.salesInvoiceID,
    required this.customerID,
    this.customerName,
    required this.address,
    required this.date,
    required this.paymentStatus,
    required this.salesStatus,
    required this.totalPrice,
    required this.details,
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
      details: details ?? this.details,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'salesInvoiceID': salesInvoiceID,
      'customerID': customerID,
      'customerName': customerName,
      'address': address.addressID,
      'date': date,
      'paymentStatus': paymentStatus.toString(),
      'salesStatus': salesStatus.toString(),
      'totalPrice': totalPrice,
    };
  }

  static SalesInvoice fromMap(String id, Map<String, dynamic> map) {
    Address address = Database().addressList.firstWhere(
          (address) => address.addressID == map['address'],
    );

    return SalesInvoice(
      salesInvoiceID: id,
      customerID: map['customerID'] ?? '',
      customerName: map['customerName'],
      address: address,
      date: (map['date'] as Timestamp).toDate(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.toString() == map['paymentStatus'],
        orElse: () => PaymentStatus.unpaid,
      ),
      salesStatus: SalesStatus.values.firstWhere(
        (e) => e.toString() == map['salesStatus'],
        orElse: () => SalesStatus.pending,
      ),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      details: [],
    );
  }
} 