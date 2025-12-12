import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'package:gizmoglobe_client/objects/employee.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import '../../objects/address_related/address.dart';
import '../../objects/address_related/province.dart';
import '../../objects/invoice_related/sales_invoice.dart';
import '../../objects/product_related/product_factory.dart';
import '../firebase/firebase.dart';
import '../../objects/invoice_related/warranty_invoice.dart';
import '../../objects/invoice_related/incoming_invoice.dart';

class Database {
  static final Database _database = Database._internal();

  String? username;
  String? email;
  RoleEnum? role;

  List<Manufacturer> manufacturerList = [];
  List<Address> addressList = [];
  List<Customer> customerList = [];
  List<Employee> employeeList = [];
  List<Province> provinceList = [];
  List<SalesInvoice> salesInvoiceList = [];
  List<Product> productList = [];
  List<WarrantyInvoice> warrantyInvoiceList = [];
  List<IncomingInvoice> incomingInvoiceList = [];
  List<Voucher> voucherList = [];

  // final List<Map<String, dynamic>> voucherDataList = [
  //   {
  //     'voucherID': 'voucher1',
  //     'voucherName': 'Discount 10%',
  //     'startTime': DateTime(2025, 5, 1),
  //     'discountValue': 10.0,
  //     'minimumPurchase': 0.0,
  //     'maxUsagePerPerson': 1,
  //     'isVisible': true,
  //     'isEnabled': true,
  //     'description': '',
  //     'hasEndTime': true,
  //     'endTime': DateTime(2025, 5, 31),
  //     'isLimited': true,
  //     'maximumUsage': 100,
  //     'usageLeft': 0,
  //     'isPercentage': true,
  //     'maximumDiscountValue': 100.0,
  //   },
  //   {
  //     'voucherID': 'voucher2',
  //     'voucherName': 'Discount \$20',
  //     'startTime': DateTime(2025, 6, 1),
  //     'discountValue': 20.0,
  //     'minimumPurchase': 50.0,
  //     'maxUsagePerPerson': 1,
  //     'isVisible': false,
  //     'isEnabled': false,
  //     'description': '\$20 off orders over \$50',
  //     'hasEndTime': true,
  //     'endTime': DateTime(2025, 6, 30),
  //     'isLimited': false,
  //     'isPercentage': false,
  //   },
  //   {
  //     'voucherID': 'voucher3',
  //     'voucherName': 'Discount 30%',
  //     'startTime': DateTime(2025, 5, 1),
  //     'discountValue': 30.0,
  //     'minimumPurchase': 0.0,
  //     'maxUsagePerPerson': 1,
  //     'isVisible': true,
  //     'isEnabled': true,
  //     'description': '30% off, up to \$100',
  //     'hasEndTime': false,
  //     'isLimited': true,
  //     'maximumUsage': 50,
  //     'usageLeft': 10,
  //     'isPercentage': true,
  //     'maximumDiscountValue': 100.0,
  //   },
  //   {
  //     'voucherID': 'voucher4',
  //     'voucherName': 'Discount \$50',
  //     'startTime': DateTime(2025, 6, 1),
  //     'discountValue': 50.0,
  //     'minimumPurchase': 100.0,
  //     'maxUsagePerPerson': 1,
  //     'isVisible': false,
  //     'isEnabled': true,
  //     'description': '\$50 off orders over \$100',
  //     'hasEndTime': false,
  //     'isLimited': true,
  //     'maximumUsage': 5,
  //     'usageLeft': 5,
  //     'isPercentage': false,
  //   },
  //   {
  //     'voucherID': 'voucher5',
  //     'voucherName': 'Discount 15%',
  //     'startTime': DateTime(2025, 4, 1),
  //     'discountValue': 15.0,
  //     'minimumPurchase': 0.0,
  //     'maxUsagePerPerson': 1,
  //     'isVisible': true,
  //     'isEnabled': true,
  //     'description': '15% off, up to \$100',
  //     'hasEndTime': true,
  //     'endTime': DateTime(2025, 4, 30),
  //     'isLimited': true,
  //     'maximumUsage': 5,
  //     'usageLeft': 5,
  //     'isPercentage': true,
  //     'maximumDiscountValue': 100.0,
  //   },
  // ];

  factory Database() {
    return _database;
  }

  Database._internal();

  Future<void> initialize() async {
    provinceList = await fetchProvinces();

    try {
      await fetchDataFromFirestore();
    } catch (e) {
      if (kDebugMode) {
        print('Error when initializing database: $e');
      }
      // Nếu không lấy được dữ liệu từ Firestore, sử dụng dữ liệu mẫu
      // _initializeSampleData();
    }
  }

  // Future<void> migrateManufacturerData() async {
  //   final productsSnapshot = await FirebaseFirestore.instance.collection('products').get();
  //   final manufacturers = await Firebase().getManufacturers();
  //   final manufacturerMap = {for (var m in manufacturers) m.manufacturerID: m.manufacturerName};
  //
  //   for (var doc in productsSnapshot.docs) {
  //     final data = doc.data();
  //     if (data['manufacturer'] is String) {
  //       final manufacturerId = data['manufacturer'];
  //       if (manufacturerId == 'vIQErfxHn8kBv3YRHxya\n') {
  //         await doc.reference.update({'manufacturer': 'vIQErfxHn8kBv3YRHxya'});
  //       }
  //     }
  //   }
  // }

  Future<void> fetchDataFromFirestore() async {
    try {
      if (kDebugMode) {
        print('Initializing connection to Firebase');
      }
      await getUser();
      await getUsername();
      if (kDebugMode) {
        print('User: $username, Email: $email');
      }

      manufacturerList = await Firebase().getManufacturers();

      // await migrateManufacturerData();

      if (kDebugMode) {
        print('Manufacturers: ${manufacturerList.length}');
      }

      final productSnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      if (kDebugMode) {
        print('Products: ${productSnapshot.docs.length}');
      }

      // Process products sequentially to avoid memory pressure on mobile
      final List<Product> products = [];
      for (final doc in productSnapshot.docs) {
        try {
          final dynamic raw = doc.data();
          if (raw is! Map<String, dynamic>) {
            if (kDebugMode) {
              print(
                  'Product ${doc.id} has unexpected data type: ${raw.runtimeType}');
            }
            continue;
          }

          // Normalize: parse JSON strings into Map/List where applicable
          final Map<String, dynamic> data =
              raw.map<String, dynamic>((key, value) {
            dynamic normalized = value;
            if (value is String) {
              final s = value.trim();
              if ((s.startsWith('{') && s.endsWith('}')) ||
                  (s.startsWith('[') && s.endsWith(']'))) {
                try {
                  normalized = jsonDecode(s);
                } catch (_) {
                  normalized = value; // leave original if parse fails
                }
              }
            }
            return MapEntry(key, normalized);
          });

          // Ensure productID present (some factories expect it)
          data.putIfAbsent('productID', () => doc.id);

          final product = ProductFactory.createProduct(data);
          products.add(product);
                } catch (e, st) {
          if (kDebugMode) {
            print('Error processing product ${doc.id}: $e\n$st');
          }
        }
      }

      productList = products;

      await fetchAddress();

      if (kDebugMode) {
        print('Products: ${productList.length}');
      }

      customerList = await Firebase().getCustomers();
      employeeList = await Firebase().getEmployees();
      voucherList = await Firebase().getVouchers();

      if (kDebugMode) {
        print('Customers: ${customerList.length}');
        print('Employees: ${employeeList.length}');
        print('Vouchers: ${voucherList.length}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Future<void> getUsername() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      username = userDoc['username'];
    } else {
      // Clear username if no user is authenticated
      username = null;
    }
  }

  Future<void> getUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      username = userDoc['username'];
      email = userDoc['email'];
    } else {
      // Clear user data if no user is authenticated
      username = null;
      email = null;
      role = null;
    }
  }

  Future<List<Province>> fetchProvinces() async {
    const filePath = 'lib/data/database/full_json_generated_data_vn_units.json';

    try {
      final String response = await rootBundle.loadString(filePath);
      if (response.isEmpty) {
        throw Exception('JSON file is empty');
      }

      final List? jsonList = jsonDecode(response) as List<dynamic>?;
      if (jsonList == null) {
        throw Exception('Error parsing JSON data');
      }

      List<Province> provinceList =
          jsonList.map((province) => Province.fromJson(province)).toList();
      return provinceList;
    } catch (e) {
      throw Exception('Error loading provinces from file: $e');
    }
  }

  Future<void> fetchAddress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final addressSnapshot =
          await FirebaseFirestore.instance.collection('addresses').get();

      addressList = addressSnapshot.docs.map((doc) {
        return Address.fromMap(doc.data());
      }).toList();
    }
  }

  void updateProductList(List<Product> productList) {
    this.productList = productList;
  }

  void updateVoucherList(List<Voucher> voucherList) {
    this.voucherList = voucherList;
  }

  Future<bool> isUserAdmin() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        return userDoc['role'] == 'admin';
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking admin status: $e');
      } // Lỗi khi kiểm tra quyền admin
      return false;
    }
  }

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Clear cached user data when user logs out
  void clearUserData() {
    username = null;
    email = null;
    role = null;
    if (kDebugMode) {
      print('Database - User data cleared');
    }
  }
}
