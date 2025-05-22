import 'package:flutter/foundation.dart';
import 'package:gizmoglobe_client/data/database/database.dart';
import 'package:gizmoglobe_client/objects/address_related/address.dart';

class Customer {
  String? customerID;
  String customerName;
  String email;
  String phoneNumber;
  List<Address>? addresses;
  double totalLoyaltyPoints;

  Customer({
    this.customerID,
    required this.customerName,
    required this.email,
    required this.phoneNumber,
    this.addresses,
    this.totalLoyaltyPoints = 0,
  });

  Customer copyWith({
    String? customerID,
    String? customerName,
    String? email,
    String? phoneNumber,
    List<Address>? addresses,
    double? totalLoyaltyPoints,
  }) {
    return Customer(
      customerID: customerID ?? this.customerID,
      customerName: customerName ?? this.customerName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      addresses: addresses ?? this.addresses,
      totalLoyaltyPoints: totalLoyaltyPoints ?? this.totalLoyaltyPoints,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerName': customerName,
      'email': email,
      'phoneNumber': phoneNumber,
      'totalLoyaltyPoints': totalLoyaltyPoints,
    };
  }

  static Customer fromMap(String id, Map<String, dynamic> map) {
    final addressList = Database().addressList.where((a) => a.customerID == id).toList();

    Customer customer = Customer(
      customerID: id,
      customerName: map['customerName'] ?? '',
      email: map['email'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      addresses: addressList,
      totalLoyaltyPoints: map['totalLoyaltyPoints'] ?? 0,
    );

    if (kDebugMode) {
      print(customer.addresses.toString());
    }
    return customer;
  }
} 