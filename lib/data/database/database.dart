import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gizmoglobe_client/enums/product_related/mainboard_enums/mainboard_compatibility.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'package:gizmoglobe_client/objects/employee.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import '../../enums/product_related/category_enum.dart';
import '../../enums/product_related/cpu_enums/cpu_family.dart';
import '../../enums/product_related/drive_enums/drive_capacity.dart';
import '../../enums/product_related/drive_enums/drive_type.dart';
import '../../enums/product_related/gpu_enums/gpu_bus.dart';
import '../../enums/product_related/gpu_enums/gpu_capacity.dart';
import '../../enums/product_related/gpu_enums/gpu_series.dart';
import '../../enums/product_related/mainboard_enums/mainboard_form_factor.dart';
import '../../enums/product_related/mainboard_enums/mainboard_series.dart';
import '../../enums/product_related/product_status_enum.dart';
import '../../enums/product_related/psu_enums/psu_efficiency.dart';
import '../../enums/product_related/psu_enums/psu_modular.dart';
import '../../enums/product_related/ram_enums/ram_bus.dart';
import '../../enums/product_related/ram_enums/ram_capacity_enum.dart';
import '../../enums/product_related/ram_enums/ram_type.dart';
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

  final List<Map<String, dynamic>> voucherDataList = [
    {
      'voucherID': 'voucher1',
      'voucherName': 'Discount 10%',
      'startTime': DateTime(2025, 5, 1),
      'discountValue': 10.0,
      'minimumPurchase': 0.0,
      'maxUsagePerPerson': 1,
      'isVisible': true,
      'isEnabled': true,
      'description': '',
      'hasEndTime': true,
      'endTime': DateTime(2025, 5, 31),
      'isLimited': true,
      'maximumUsage': 100,
      'usageLeft': 0,
      'isPercentage': true,
      'maximumDiscountValue': 100.0,
    },
    {
      'voucherID': 'voucher2',
      'voucherName': 'Discount \$20',
      'startTime': DateTime(2025, 6, 1),
      'discountValue': 20.0,
      'minimumPurchase': 50.0,
      'maxUsagePerPerson': 1,
      'isVisible': false,
      'isEnabled': false,
      'description': '\$20 off orders over \$50',
      'hasEndTime': true,
      'endTime': DateTime(2025, 6, 30),
      'isLimited': false,
      'isPercentage': false,
    },
    {
      'voucherID': 'voucher3',
      'voucherName': 'Discount 30%',
      'startTime': DateTime(2025, 5, 1),
      'discountValue': 30.0,
      'minimumPurchase': 0.0,
      'maxUsagePerPerson': 1,
      'isVisible': true,
      'isEnabled': true,
      'description': '30% off, up to \$100',
      'hasEndTime': false,
      'isLimited': true,
      'maximumUsage': 50,
      'usageLeft': 10,
      'isPercentage': true,
      'maximumDiscountValue': 100.0,
    },
    {
      'voucherID': 'voucher4',
      'voucherName': 'Discount \$50',
      'startTime': DateTime(2025, 6, 1),
      'discountValue': 50.0,
      'minimumPurchase': 100.0,
      'maxUsagePerPerson': 1,
      'isVisible': false,
      'isEnabled': true,
      'description': '\$50 off orders over \$100',
      'hasEndTime': false,
      'isLimited': true,
      'maximumUsage': 5,
      'usageLeft': 5,
      'isPercentage': false,
    },
    {
      'voucherID': 'voucher5',
      'voucherName': 'Discount 15%',
      'startTime': DateTime(2025, 4, 1),
      'discountValue': 15.0,
      'minimumPurchase': 0.0,
      'maxUsagePerPerson': 1,
      'isVisible': true,
      'isEnabled': true,
      'description': '15% off, up to \$100',
      'hasEndTime': true,
      'endTime': DateTime(2025, 4, 30),
      'isLimited': true,
      'maximumUsage': 5,
      'usageLeft': 5,
      'isPercentage': true,
      'maximumDiscountValue': 100.0,
    },
  ];

  factory Database() {
    return _database;
  }

  Database._internal();

  Future<void> initialize() async {
    // provinceList = await fetchProvinces();

    try {
      await fetchDataFromFirestore();
    } catch (e) {
      if (kDebugMode) {
        print(
            'Error when initializing database: $e'); // Lỗi khi khởi tạo database
      }
      // Nếu không lấy được dữ liệu từ Firestore, sử dụng dữ liệu mẫu
      // _initializeSampleData();
    }
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      if (kDebugMode) {
        print(
            'Initializing connection to Firebase'); //Bắt đầu lấy dữ liệu từ Firestore
      }
      await getUser();
      await getUsername();
      if (kDebugMode) {
        print('User: $username, Email: $email'); //Thông tin người dùng
      }
      final manufacturerSnapshot =
          await FirebaseFirestore.instance.collection('manufacturers').get();

      manufacturerList = manufacturerSnapshot.docs.map((doc) {
        return Manufacturer(
          manufacturerID: doc.id,
          manufacturerName: doc['manufacturerName'] as String,
        );
      }).toList();

      if (kDebugMode) {
        print('Manufacturers: ${manufacturerList.length}'); //Nhà sản xuất
      }

      // Lấy danh sách products từ Firestore
      final productSnapshot =
          await FirebaseFirestore.instance.collection('products').get();

      if (kDebugMode) {
        print('Products: ${productSnapshot.docs.length}'); //Sản phẩm
      }

      productList = await Future.wait(productSnapshot.docs.map((doc) async {
        try {
          final data = doc.data();

          // Tìm manufacturer tương ứng
          final manufacturer = manufacturerList.firstWhere(
            (m) => m.manufacturerID == data['manufacturerID'],
            orElse: () {
              if (kDebugMode) {
                print('Manufacturer not found for product ${doc.id}');
              }
              throw Exception('Manufacturer not found for product ${doc.id}');
            },
          );

          // Chuyển đổi dữ liệu từ Firestore sang enum
          final category = CategoryEnum.nonEmptyValues.firstWhere(
            (c) => c.getName() == data['category'],
            orElse: () {
              if (kDebugMode) {
                print('Invalid category for product ${doc.id}');
              }
              throw Exception('Invalid category for product ${doc.id}');
            },
          );

          final specificData = _getSpecificProductData(data, category);
          if (specificData.isEmpty) {
            if (kDebugMode) {
              print('Cannot get specific data for product ${doc.id}');
            }
            throw Exception('Cannot get specific data for product ${doc.id}');
          }

          return ProductFactory.createProduct(
            category,
            {
              'productID': doc.id,
              'productName': data['productName'],
              'importPrice': data['importPrice'].toDouble(),
              'sellingPrice': data['sellingPrice'].toDouble(),
              'discount': data['discount'].toDouble(),
              'release': (data['release'] as Timestamp).toDate(),
              'sales': data['sales'],
              'stock': data['stock'],
              'status': ProductStatusEnum.values.firstWhere(
                (s) => s.getName() == data['status'],
                orElse: () {
                  if (kDebugMode) {
                    print('Invalid status for product ${doc.id}');
                  }
                  throw Exception('Invalid status for product ${doc.id}');
                },
              ),
              'manufacturer': manufacturer,
              'imageUrl': data['imageUrl'],
              ...specificData,
            },
          );
        } catch (e) {
          if (kDebugMode) {
            print('Error processing product ${doc.id}: $e');
          }
          return Future.error('Error processing product ${doc.id}: $e');
        }
      }));

      await fetchAddress();

      if (kDebugMode) {
        print('Products: ${productList.length}');
      }

      customerList = await Firebase().getCustomers();
      voucherList = Firebase().getVouchers();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      }
    }
  }

  Map<String, dynamic> _getSpecificProductData(
      Map<String, dynamic> data, CategoryEnum category) {
    switch (category) {
      case CategoryEnum.ram:
        return {
          'bus': RAMBus.values.firstWhere((b) => b.getName() == data['bus']),
          'capacity': RAMCapacity.values
              .firstWhere((c) => c.getName() == data['capacity']),
          'ramType':
              RAMType.values.firstWhere((t) => t.getName() == data['ramType']),
        };

      case CategoryEnum.cpu:
        return {
          'family':
              CPUFamily.values.firstWhere((f) => f.getName() == data['family']),
          'core': data['core'],
          'thread': data['thread'],
          'clockSpeed': data['clockSpeed'].toDouble(),
        };
      case CategoryEnum.gpu:
        return {
          'series':
              GPUSeries.values.firstWhere((s) => s.getName() == data['series']),
          'capacity': GPUCapacity.values
              .firstWhere((c) => c.getName() == data['capacity']),
          'busWidth':
              GPUBus.values.firstWhere((b) => b.getName() == data['busWidth']),
          'clockSpeed': data['clockSpeed'].toDouble(),
        };
      case CategoryEnum.mainboard:
        return {
          'formFactor': MainboardFormFactor.values
              .firstWhere((f) => f.getName() == data['formFactor']),
          'series': MainboardSeries.values
              .firstWhere((s) => s.getName() == data['series']),
          'compatibility': MainboardCompatibility.values
              .firstWhere((c) => c.getName() == data['compatibility']),
        };
      case CategoryEnum.drive:
        return {
          'type':
              DriveType.values.firstWhere((t) => t.getName() == data['type']),
          'capacity': DriveCapacity.values
              .firstWhere((c) => c.getName() == data['capacity']),
        };
      case CategoryEnum.psu:
        return {
          'wattage': data['wattage'],
          'efficiency': PSUEfficiency.values
              .firstWhere((e) => e.getName() == data['efficiency']),
          'modular': PSUModular.values
              .firstWhere((m) => m.getName() == data['modular']),
        };
      default:
        return {};
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
    }
  }

  Future<List<Province>> fetchProvinces() async {
    const filePath = 'lib/data/database/full_json_generated_data_vn_units.json';

    try {
      final String response = await rootBundle.loadString(filePath);
      if (response.isEmpty) {
        throw Exception('JSON file is empty'); // File JSON rỗng
      }

      final List? jsonList = jsonDecode(response) as List<dynamic>?;
      if (jsonList == null) {
        throw Exception('Error parsing JSON data'); // Lỗi khi parse JSON
      }

      List<Province> provinceList =
          jsonList.map((province) => Province.fromJson(province)).toList();
      return provinceList;
    } catch (e) {
      throw Exception(
          'Error loading provinces from file: $e'); // Lỗi khi load dữ liệu từ file
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
}
