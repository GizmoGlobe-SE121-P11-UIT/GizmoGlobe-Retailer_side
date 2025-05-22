import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:gizmoglobe_client/enums/product_related/mainboard_enums/mainboard_compatibility.dart';
import 'package:gizmoglobe_client/enums/stakeholders/employee_role.dart';
import 'package:gizmoglobe_client/enums/voucher_related/voucher_status.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'package:gizmoglobe_client/objects/employee.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import '../../enums/invoice_related/payment_status.dart';
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
import '../../objects/invoice_related/incoming_invoice_detail.dart';

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

  factory Database() {
    return _database;
  }

  Database._internal();

  Future<void> initialize() async {
    provinceList = await fetchProvinces();

    // addressList = [
    //   Address(
    //     customerID: '4e2PT6vyB9tszKqEcx6I',
    //     receiverName: 'DuyVu',
    //     receiverPhone: '123456789',
    //     isDefault: true,
    //     province: provinceList[0],
    //     district: provinceList[0].districts![0],
    //     ward: provinceList[0].districts![0].wards![0],
    //     street: '123 Nguyen Trai',
    //   ),
    //
    //   Address(
    //     customerID: 'DyyMyOTtZ7J2SQzsr6IZ',
    //     receiverName: 'Terry',
    //     receiverPhone: '123456780',
    //     isDefault: false,
    //     province: provinceList[0],
    //     district: provinceList[0].districts![2],
    //     ward: provinceList[0].districts![2].wards![5],
    //     street: '456 Le Loi',
    //   ),
    //
    //   Address(
    //     customerID: 'DyyMyOTtZ7J2SQzsr6IZ',
    //     receiverName: 'Terry',
    //     receiverPhone: '123456780',
    //     isDefault: true,
    //     province: provinceList[0],
    //     district: provinceList[0].districts![2],
    //     ward: provinceList[0].districts![2].wards![5],
    //     street: '456 Le Loi',
    //   ),
    //
    //   Address(
    //     customerID: 'dKV74hSAXozpmhPgXerv',
    //     receiverName: 'QuanDo',
    //     receiverPhone: '123456780',
    //     isDefault: true,
    //     province: provinceList[0],
    //     district: provinceList[0].districts![2],
    //     ward: provinceList[0].districts![2].wards![2],
    //     street: '789 Tran Hung Dao',
    //   ),
    //
    //   Address(
    //     customerID: 'noxiFkqUTN4bum27HPCq',
    //     receiverName: 'NhatTan',
    //     receiverPhone: '123456789',
    //     isDefault: true,
    //     province: provinceList[1],
    //     district: provinceList[1].districts![0],
    //     ward: provinceList[1].districts![0].wards![0],
    //     street: '123 Nguyen Trai',
    //   ),
    //
    //   Address(
    //     customerID: 'tqyMZqXphgCTdKudaWyV',
    //     receiverName: 'NguyenKhoa',
    //     receiverPhone: '123456790',
    //     isDefault: true,
    //     province: provinceList[1],
    //     district: provinceList[1].districts![1],
    //     ward: provinceList[1].districts![1].wards![1],
    //     street: '456 Le Loi',
    //   ),
    // ];

    try {
      await fetchDataFromFirestore();
    } catch (e) {
      if (kDebugMode) {
        print('Error when initializing database: $e'); // Lỗi khi khởi tạo database
      }
      // Nếu không lấy được dữ liệu từ Firestore, sử dụng dữ liệu mẫu
      // _initializeSampleData();
    }
  }

  Future<void> fetchDataFromFirestore() async {
    try {
      if (kDebugMode) {
        print('Initializing connection to Firebase'); //Bắt đầu lấy dữ liệu từ Firestore
      }
      final manufacturerSnapshot = await FirebaseFirestore.instance
          .collection('manufacturers')
          .get();

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
      final productSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

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
      } //Sản phẩm

      customerList = await Firebase().getCustomers();

      //voucherList = await Firebase().getVouchers();
      voucherList = [
        Voucher.createPercentageVoucher(
          voucherID: 'voucher1',
          voucherName: 'Discount 10%',
          startTime: DateTime(2025, 5, 1),
          haveEndTime: true,
          endTime: DateTime(2025, 5, 31),
          discountValue: 10,
          minimumPurchase: 0,
          maximumValue: 100,
          quantity: 10,
          maxUsagePerPerson: 1,
          isVisible: true,
          isEnabled: true,
        ),
        Voucher.createAmountVoucher(
          voucherID: 'voucher2',
          voucherName: 'Discount 20\$',
          discountValue: 20,
          minimumPurchase: 50,
          quantity: 0,
          maxUsagePerPerson: 1,
          startTime: DateTime(2025, 6, 1),
          haveEndTime: true,
          endTime: DateTime(2025, 6, 30),
          isVisible: false,
          isEnabled: true,
        ),
        Voucher.createPercentageVoucher(
          voucherID: 'voucher3',
          voucherName: 'Discount 30%',
          startTime: DateTime(2025, 6, 1),
          haveEndTime: true,
          endTime: DateTime(2025, 6, 31),
          discountValue: 30,
          minimumPurchase: 0,
          maximumValue: 100,
          quantity: 10,
          maxUsagePerPerson: 1,
          isVisible: true,
          isEnabled: true,
        ),
        Voucher.createAmountVoucher(
          voucherID: 'voucher4',
          voucherName: 'Discount 50\$',
          discountValue: 50,
          minimumPurchase: 100,
          quantity: 5,
          maxUsagePerPerson: 1,
          startTime: DateTime(2025, 5, 1),
          haveEndTime: false,
          endTime: DateTime(2025, 7, 30),
          isVisible: true,
          isEnabled: false,
        ),
        Voucher.createPercentageVoucher(
          voucherID: 'voucher5',
          voucherName: 'Discount 15%',
          startTime: DateTime(2025, 4, 1),
          haveEndTime: true,
          endTime: DateTime(2025, 4, 30),
          discountValue: 15,
          minimumPurchase: 0,
          maximumValue: 100,
          quantity: 10,
          maxUsagePerPerson: 1,
          isVisible: true,
          isEnabled: true,
        ),
      ];

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching data: $e');
      } //Lỗi khi lấy dữ liệu
    }
  }

  Map<String, dynamic> _getSpecificProductData(Map<String, dynamic> data, CategoryEnum category) {
    switch (category) {
      case CategoryEnum.ram:
        return {
          'bus': RAMBus.values.firstWhere((b) => b.getName() == data['bus']),
          'capacity': RAMCapacity.values.firstWhere((c) => c.getName() == data['capacity']),
          'ramType': RAMType.values.firstWhere((t) => t.getName() == data['ramType']),
        };

      case CategoryEnum.cpu:
        return {
          'family': CPUFamily.values.firstWhere((f) => f.getName() == data['family']),
          'core': data['core'],
          'thread': data['thread'],
          'clockSpeed': data['clockSpeed'].toDouble(),
        };
      case CategoryEnum.gpu:
        return {
          'series': GPUSeries.values.firstWhere((s) => s.getName() == data['series']),
          'capacity': GPUCapacity.values.firstWhere((c) => c.getName() == data['capacity']),
          'busWidth': GPUBus.values.firstWhere((b) => b.getName() == data['busWidth']),
          'clockSpeed': data['clockSpeed'].toDouble(),
        };
      case CategoryEnum.mainboard:
        return {
          'formFactor': MainboardFormFactor.values.firstWhere((f) => f.getName() == data['formFactor']),
          'series': MainboardSeries.values.firstWhere((s) => s.getName() == data['series']),
          'compatibility': MainboardCompatibility.values.firstWhere((c) => c.getName() == data['compatibility']),
        };
      case CategoryEnum.drive:
        return {
          'type': DriveType.values.firstWhere((t) => t.getName() == data['type']),
          'capacity': DriveCapacity.values.firstWhere((c) => c.getName() == data['capacity']),
        };
      case CategoryEnum.psu:
        return {
          'wattage': data['wattage'],
          'efficiency': PSUEfficiency.values.firstWhere((e) => e.getName() == data['efficiency']),
          'modular': PSUModular.values.firstWhere((m) => m.getName() == data['modular']),
        };
      default:
        return {};
    }
  }

  // void _initializeSampleData() {
  //   manufacturerList = [
  //     Manufacturer(
  //       manufacturerID: 'Corsair',
  //       manufacturerName: 'Corsair',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'G.Skill',
  //       manufacturerName: 'G.Skill',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Crucial',
  //       manufacturerName: 'Crucial',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Kingston',
  //       manufacturerName: 'Kingston',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Intel',
  //       manufacturerName: 'Intel',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'AMD',
  //       manufacturerName: 'AMD',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'ASUS',
  //       manufacturerName: 'ASUS',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'MSI',
  //       manufacturerName: 'MSI',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Gigabyte',
  //       manufacturerName: 'Gigabyte',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Samsung',
  //       manufacturerName: 'Samsung',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Western Digital',
  //       manufacturerName: 'Western Digital',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Seagate',
  //       manufacturerName: 'Seagate',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Seasonic',
  //       manufacturerName: 'Seasonic',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'be quiet!',
  //       manufacturerName: 'be quiet!',
  //     ),
  //     Manufacturer(
  //       manufacturerID: 'Thermaltake',
  //       manufacturerName: 'Thermaltake',
  //     ),
  //   ];
  //
  //   productList = [
  //     // DDR3 RAM samples
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Kingston HyperX Fury DDR3',
  //       'importPrice': 49.99,
  //       'sellingPrice': 59.99,
  //       'discount': 0.1,
  //       'release': DateTime(2015, 1, 1),
  //       'sales': 100,
  //       'stock': 50,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[3], // Kingston
  //       'bus': RAMBus.mhz1600,
  //       'capacity': RAMCapacity.gb8,
  //       'ramType': RAMType.ddr3,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Corsair Vengeance DDR3',
  //       'importPrice': 69.99,
  //       'sellingPrice': 79.99,
  //       'discount': 0.12,
  //       'release': DateTime(2016, 1, 1),
  //       'sales': 200,
  //       'stock': 100,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'bus': RAMBus.mhz2133,
  //       'capacity': RAMCapacity.gb16,
  //       'ramType': RAMType.ddr3,
  //     }),
  //
  //     // DDR4 RAM samples
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'G.Skill Ripjaws V DDR4',
  //       'importPrice': 79.99,
  //       'sellingPrice': 89.99,
  //       'discount': 0.11,
  //       'release': DateTime(2017, 1, 1),
  //       'sales': 300,
  //       'stock': 150,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[1], // G.Skill
  //       'bus': RAMBus.mhz2400,
  //       'capacity': RAMCapacity.gb16,
  //       'ramType': RAMType.ddr4,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Crucial Ballistix DDR4',
  //       'importPrice': 99.99,
  //       'sellingPrice': 109.99,
  //       'discount': 0.09,
  //       'release': DateTime(2018, 1, 1),
  //       'sales': 400,
  //       'stock': 200,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[2], // Crucial
  //       'bus': RAMBus.mhz3200,
  //       'capacity': RAMCapacity.gb32,
  //       'ramType': RAMType.ddr4,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Corsair Dominator DDR4',
  //       'importPrice': 149.99,
  //       'sellingPrice': 159.99,
  //       'discount': 0.06,
  //       'release': DateTime(2019, 1, 1),
  //       'sales': 500,
  //       'stock': 250,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'bus': RAMBus.mhz3200,
  //       'capacity': RAMCapacity.gb64,
  //       'ramType': RAMType.ddr4,
  //     }),
  //
  //     // DDR5 RAM samples
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'G.Skill Trident Z5 DDR5',
  //       'importPrice': 199.99,
  //       'sellingPrice': 219.99,
  //       'discount': 0.09,
  //       'release': DateTime(2020, 1, 1),
  //       'sales': 600,
  //       'stock': 300,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[1], // G.Skill
  //       'bus': RAMBus.mhz4800,
  //       'capacity': RAMCapacity.gb32,
  //       'ramType': RAMType.ddr5,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Corsair Vengeance DDR5',
  //       'importPrice': 299.99,
  //       'sellingPrice': 329.99,
  //       'discount': 0.08,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 0,
  //       'stock': 0,
  //       'status': ProductStatusEnum.discontinued,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'bus': RAMBus.mhz4800,
  //       'capacity': RAMCapacity.gb64,
  //       'ramType': RAMType.ddr5,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.ram, {
  //       'productName': 'Kingston Fury Beast DDR5',
  //       'importPrice': 399.99,
  //       'sellingPrice': 429.99,
  //       'discount': 0.07,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 0,
  //       'stock': 0,
  //       'status': ProductStatusEnum.discontinued,
  //       'manufacturer': manufacturerList[3], // Kingston
  //       'bus': RAMBus.mhz4800,
  //       'capacity': RAMCapacity.gb128,
  //       'ramType': RAMType.ddr5,
  //     }),
  //
  //     // CPU samples
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'Intel Core i3-13100',
  //       'importPrice': 99.99,
  //       'sellingPrice': 119.99,
  //       'discount': 0.17,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 100,
  //       'stock': 50,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[4], // Intel
  //       'family': CPUFamily.corei3Ultra3,
  //       'core': 4,
  //       'thread': 8,
  //       'clockSpeed': 3.4,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'Intel Core i5-13600K',
  //       'importPrice': 199.99,
  //       'sellingPrice': 229.99,
  //       'discount': 0.13,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 200,
  //       'stock': 100,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[4], // Intel
  //       'family': CPUFamily.corei5Ultra5,
  //       'core': 14,
  //       'thread': 20,
  //       'clockSpeed': 3.5,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'Intel Core i7-13700K',
  //       'importPrice': 299.99,
  //       'sellingPrice': 349.99,
  //       'discount': 0.14,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 300,
  //       'stock': 150,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[4], // Intel
  //       'family': CPUFamily.corei7Ultra7,
  //       'core': 16,
  //       'thread': 24,
  //       'clockSpeed': 3.4,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'Intel Xeon W-3475X',
  //       'importPrice': 999.99,
  //       'sellingPrice': 1199.99,
  //       'discount': 0.17,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 400,
  //       'stock': 200,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[4], // Intel
  //       'family': CPUFamily.xeon,
  //       'core': 36,
  //       'thread': 72,
  //       'clockSpeed': 2.8,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'AMD Ryzen 3 4100',
  //       'importPrice': 99.99,
  //       'sellingPrice': 119.99,
  //       'discount': 0.17,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 100,
  //       'stock': 50,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[5], // AMD
  //       'family': CPUFamily.ryzen3,
  //       'core': 4,
  //       'thread': 8,
  //       'clockSpeed': 3.8,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'AMD Ryzen 5 7600X',
  //       'importPrice': 199.99,
  //       'sellingPrice': 229.99,
  //       'discount': 0.13,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 200,
  //       'stock': 100,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[5], // AMD
  //       'family': CPUFamily.ryzen5,
  //       'core': 6,
  //       'thread': 12,
  //       'clockSpeed': 4.7,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'AMD Ryzen 7 7800X3D',
  //       'importPrice': 299.99,
  //       'sellingPrice': 349.99,
  //       'discount': 0.14,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 300,
  //       'stock': 150,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[5], // AMD
  //       'family': CPUFamily.ryzen7,
  //       'core': 8,
  //       'thread': 16,
  //       'clockSpeed': 4.2,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.cpu, {
  //       'productName': 'AMD Threadripper PRO 5995WX',
  //       'importPrice': 999.99,
  //       'sellingPrice': 1199.99,
  //       'discount': 0.17,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 400,
  //       'stock': 200,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[5], // AMD
  //       'family': CPUFamily.threadripper,
  //       'core': 64,
  //       'thread': 128,
  //       'clockSpeed': 2.7,
  //     }),
  //
  //     // GPU samples
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'ASUS ROG STRIX GTX 1660 SUPER',
  //       'importPrice': 299.99,
  //       'sellingPrice': 349.99,
  //       'discount': 0.14,
  //       'release': DateTime(2019, 1, 1),
  //       'sales': 100,
  //       'stock': 50,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'series': GPUSeries.gtx,
  //       'capacity': GPUCapacity.gb6,
  //       'busWidth': GPUBus.bit128,
  //       'clockSpeed': 1.53,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'MSI Gaming X RTX 4070',
  //       'importPrice': 499.99,
  //       'sellingPrice': 599.99,
  //       'discount': 0.17,
  //       'release': DateTime(2020, 1, 1),
  //       'sales': 200,
  //       'stock': 100,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[7], // MSI
  //       'series': GPUSeries.rtx,
  //       'capacity': GPUCapacity.gb12,
  //       'busWidth': GPUBus.bit128,
  //       'clockSpeed': 2.31,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'NVIDIA Quadro RTX A6000',
  //       'importPrice': 1999.99,
  //       'sellingPrice': 2299.99,
  //       'discount': 0.13,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 300,
  //       'stock': 150,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'series': GPUSeries.quadro,
  //       'capacity': GPUCapacity.gb24,
  //       'busWidth': GPUBus.bit384,
  //       'clockSpeed': 1.80,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'Gigabyte RX 7900 XTX',
  //       'importPrice': 299.99,
  //       'sellingPrice': 349.99,
  //       'discount': 0.14,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 400,
  //       'stock': 200,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[8], // Gigabyte
  //       'series': GPUSeries.rx,
  //       'capacity': GPUCapacity.gb24,
  //       'busWidth': GPUBus.bit384,
  //       'clockSpeed': 2.50,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'AMD FirePro W9100',
  //       'importPrice': 999.99,
  //       'sellingPrice': 1199.99,
  //       'discount': 0.17,
  //       'release': DateTime(2015, 1, 1),
  //       'sales': 500,
  //       'stock': 250,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[5], // AMD
  //       'series': GPUSeries.firePro,
  //       'capacity': GPUCapacity.gb16,
  //       'busWidth': GPUBus.bit512,
  //       'clockSpeed': 0.93,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'Intel Arc A770',
  //       'importPrice': 199.99,
  //       'sellingPrice': 229.99,
  //       'discount': 0.13,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 600,
  //       'stock': 300,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[4], // Intel
  //       'series': GPUSeries.arc,
  //       'capacity': GPUCapacity.gb16,
  //       'busWidth': GPUBus.bit256,
  //       'clockSpeed': 2.10,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'MSI Gaming X RTX 4090',
  //       'importPrice': 999.99,
  //       'sellingPrice': 1199.99,
  //       'discount': 0.17,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 700,
  //       'stock': 350,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[7], // MSI
  //       'series': GPUSeries.rtx,
  //       'capacity': GPUCapacity.gb24,
  //       'busWidth': GPUBus.bit384,
  //       'clockSpeed': 2.52,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.gpu, {
  //       'productName': 'Gigabyte RX 6600',
  //       'importPrice': 299.99,
  //       'sellingPrice': 349.99,
  //       'discount': 0.14,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 800,
  //       'stock': 400,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[8], // Gigabyte
  //       'series': GPUSeries.rx,
  //       'capacity': GPUCapacity.gb8,
  //       'busWidth': GPUBus.bit128,
  //       'clockSpeed': 2.49,
  //     }),
  //
  //     // Mainboard samples
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'ASUS PRIME H610M-K',
  //       'importPrice': 79.99,
  //       'sellingPrice': 89.99,
  //       'discount': 0.1,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 100,
  //       'stock': 50,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'formFactor': MainboardFormFactor.microATX,
  //       'series': MainboardSeries.h,
  //       'compatibility': MainboardCompatibility.intel,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'MSI PRO H610I',
  //       'importPrice': 99.99,
  //       'sellingPrice': 109.99,
  //       'discount': 0.09,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 200,
  //       'stock': 100,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[7], // MSI
  //       'formFactor': MainboardFormFactor.miniITX,
  //       'series': MainboardSeries.h,
  //       'compatibility': MainboardCompatibility.intel,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'Gigabyte B650 AORUS ELITE AX',
  //       'importPrice': 149.99,
  //       'sellingPrice': 169.99,
  //       'discount': 0.12,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 300,
  //       'stock': 150,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[8], // Gigabyte
  //       'formFactor': MainboardFormFactor.atx,
  //       'series': MainboardSeries.b,
  //       'compatibility': MainboardCompatibility.amd,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'MSI MAG B760M MORTAR',
  //       'importPrice': 199.99,
  //       'sellingPrice': 229.99,
  //       'discount': 0.13,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 400,
  //       'stock': 200,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[7], // MSI
  //       'formFactor': MainboardFormFactor.microATX,
  //       'series': MainboardSeries.b,
  //       'compatibility': MainboardCompatibility.intel,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'ASUS ROG STRIX B650E-I',
  //       'importPrice': 299.99,
  //       'sellingPrice': 349.99,
  //       'discount': 0.14,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 500,
  //       'stock': 250,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'formFactor': MainboardFormFactor.miniITX,
  //       'series': MainboardSeries.b,
  //       'compatibility': MainboardCompatibility.amd,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'ASUS ROG MAXIMUS Z790 HERO',
  //       'importPrice': 399.99,
  //       'sellingPrice': 449.99,
  //       'discount': 0.1,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 600,
  //       'stock': 300,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'formFactor': MainboardFormFactor.atx,
  //       'series': MainboardSeries.z,
  //       'compatibility': MainboardCompatibility.intel,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'MSI MPG Z790M EDGE',
  //       'importPrice': 499.99,
  //       'sellingPrice': 549.99,
  //       'discount': 0.09,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 700,
  //       'stock': 350,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[7], // MSI
  //       'formFactor': MainboardFormFactor.microATX,
  //       'series': MainboardSeries.z,
  //       'compatibility': MainboardCompatibility.intel,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'Gigabyte X670E AORUS MASTER',
  //       'importPrice': 599.99,
  //       'sellingPrice': 649.99,
  //       'discount': 0.08,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 800,
  //       'stock': 400,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[8], // Gigabyte
  //       'formFactor': MainboardFormFactor.atx,
  //       'series': MainboardSeries.x,
  //       'compatibility': MainboardCompatibility.amd,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.mainboard, {
  //       'productName': 'ASUS ROG STRIX X670E-I',
  //       'importPrice': 699.99,
  //       'sellingPrice': 749.99,
  //       'discount': 0.07,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 900,
  //       'stock': 450,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[6], // ASUS
  //       'formFactor': MainboardFormFactor.miniITX,
  //       'series': MainboardSeries.x,
  //       'compatibility': MainboardCompatibility.amd,
  //     }),
  //
  //     // Drive samples
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Seagate Barracuda',
  //       'importPrice': 49.99,
  //       'sellingPrice': 59.99,
  //       'discount': 0.1,
  //       'release': DateTime(2015, 1, 1),
  //       'sales': 100,
  //       'stock': 50,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[11], // Seagate
  //       'type': DriveType.hdd,
  //       'capacity': DriveCapacity.tb2,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'WD Blue HDD',
  //       'importPrice': 69.99,
  //       'sellingPrice': 79.99,
  //       'discount': 0.12,
  //       'release': DateTime(2016, 1, 1),
  //       'sales': 200,
  //       'stock': 100,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[10], // Western Digital
  //       'type': DriveType.hdd,
  //       'capacity': DriveCapacity.tb4,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Samsung 870 EVO',
  //       'importPrice': 79.99,
  //       'sellingPrice': 89.99,
  //       'discount': 0.11,
  //       'release': DateTime(2017, 1, 1),
  //       'sales': 300,
  //       'stock': 150,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[9], // Samsung
  //       'type': DriveType.sataSSD,
  //       'capacity': DriveCapacity.gb512,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Crucial MX500',
  //       'importPrice': 99.99,
  //       'sellingPrice': 109.99,
  //       'discount': 0.09,
  //       'release': DateTime(2018, 1, 1),
  //       'sales': 400,
  //       'stock': 200,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[2], // Crucial
  //       'type': DriveType.sataSSD,
  //       'capacity': DriveCapacity.tb1,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'WD Blue SATA SSD',
  //       'importPrice': 119.99,
  //       'sellingPrice': 129.99,
  //       'discount': 0.07,
  //       'release': DateTime(2019, 1, 1),
  //       'sales': 500,
  //       'stock': 250,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[10], // Western Digital
  //       'type': DriveType.sataSSD,
  //       'capacity': DriveCapacity.tb2,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Samsung 860 EVO M.2',
  //       'importPrice': 149.99,
  //       'sellingPrice': 159.99,
  //       'discount': 0.06,
  //       'release': DateTime(2020, 1, 1),
  //       'sales': 600,
  //       'stock': 300,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[9], // Samsung
  //       'type': DriveType.m2NGFF,
  //       'capacity': DriveCapacity.gb512,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'WD Blue M.2 SATA',
  //       'importPrice': 199.99,
  //       'sellingPrice': 219.99,
  //       'discount': 0.09,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 700,
  //       'stock': 350,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[10], // Western Digital
  //       'type': DriveType.m2NGFF,
  //       'capacity': DriveCapacity.tb1,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Samsung 970 EVO Plus',
  //       'importPrice': 299.99,
  //       'sellingPrice': 329.99,
  //       'discount': 0.08,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 800,
  //       'stock': 400,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[9], // Samsung
  //       'type': DriveType.m2NVME,
  //       'capacity': DriveCapacity.gb512,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'WD Black SN850X',
  //       'importPrice': 399.99,
  //       'sellingPrice': 429.99,
  //       'discount': 0.07,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 900,
  //       'stock': 450,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[10], // Western Digital
  //       'type': DriveType.m2NVME,
  //       'capacity': DriveCapacity.tb1,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Seagate FireCuda 530',
  //       'importPrice': 499.99,
  //       'sellingPrice': 549.99,
  //       'discount': 0.06,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 1000,
  //       'stock': 500,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[11], // Seagate
  //       'type': DriveType.m2NVME,
  //       'capacity': DriveCapacity.tb2,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.drive, {
  //       'productName': 'Corsair Force MP600',
  //       'importPrice': 599.99,
  //       'sellingPrice': 649.99,
  //       'discount': 0.05,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 1100,
  //       'stock': 550,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'type': DriveType.m2NVME,
  //       'capacity': DriveCapacity.tb4,
  //     }),
  //
  //     // PSU samples
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'Thermaltake Smart 500W',
  //       'importPrice': 39.99,
  //       'sellingPrice': 49.99,
  //       'discount': 0.2,
  //       'release': DateTime(2015, 1, 1),
  //       'sales': 100,
  //       'stock': 50,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[14], // Thermaltake
  //       'wattage': 500,
  //       'efficiency': PSUEfficiency.white,
  //       'modular': PSUModular.nonModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'Corsair CV650',
  //       'importPrice': 49.99,
  //       'sellingPrice': 59.99,
  //       'discount': 0.17,
  //       'release': DateTime(2016, 1, 1),
  //       'sales': 200,
  //       'stock': 100,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'wattage': 650,
  //       'efficiency': PSUEfficiency.bronze,
  //       'modular': PSUModular.nonModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'be quiet! Pure Power 11',
  //       'importPrice': 69.99,
  //       'sellingPrice': 79.99,
  //       'discount': 0.13,
  //       'release': DateTime(2017, 1, 1),
  //       'sales': 300,
  //       'stock': 150,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[13], // be quiet!
  //       'wattage': 600,
  //       'efficiency': PSUEfficiency.bronze,
  //       'modular': PSUModular.semiModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'Seasonic FOCUS GX-750',
  //       'importPrice': 99.99,
  //       'sellingPrice': 109.99,
  //       'discount': 0.09,
  //       'release': DateTime(2018, 1, 1),
  //       'sales': 400,
  //       'stock': 200,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[12], // Seasonic
  //       'wattage': 750,
  //       'efficiency': PSUEfficiency.gold,
  //       'modular': PSUModular.fullModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'Corsair RM850x',
  //       'importPrice': 129.99,
  //       'sellingPrice': 139.99,
  //       'discount': 0.07,
  //       'release': DateTime(2019, 1, 1),
  //       'sales': 500,
  //       'stock': 250,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[0], // Corsair
  //       'wattage': 850,
  //       'efficiency': PSUEfficiency.gold,
  //       'modular': PSUModular.fullModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'be quiet! Straight Power 11',
  //       'importPrice': 149.99,
  //       'sellingPrice': 159.99,
  //       'discount': 0.06,
  //       'release': DateTime(2020, 1, 1),
  //       'sales': 600,
  //       'stock': 300,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[13], // be quiet!
  //       'wattage': 850,
  //       'efficiency': PSUEfficiency.platinum,
  //       'modular': PSUModular.fullModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'Seasonic PRIME TX-1000',
  //       'importPrice': 199.99,
  //       'sellingPrice': 219.99,
  //       'discount': 0.09,
  //       'release': DateTime(2021, 1, 1),
  //       'sales': 700,
  //       'stock': 350,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[12], // Seasonic
  //       'wattage': 1000,
  //       'efficiency': PSUEfficiency.titanium,
  //       'modular': PSUModular.fullModular,
  //     }),
  //     ProductFactory.createProduct(CategoryEnum.psu, {
  //       'productName': 'be quiet! Dark Power Pro 12',
  //       'importPrice': 299.99,
  //       'sellingPrice': 329.99,
  //       'discount': 0.08,
  //       'release': DateTime(2022, 1, 1),
  //       'sales': 800,
  //       'stock': 400,
  //       'status': ProductStatusEnum.active,
  //       'manufacturer': manufacturerList[13], // be quiet!
  //       'wattage': 1200,
  //       'efficiency': PSUEfficiency.titanium,
  //       'modular': PSUModular.fullModular,
  //     }),
  //   ];
  //
  //   customerList = [
  //     Customer(
  //       customerName: 'Tran Nhat Tan',
  //       phoneNumber: '0901234567',
  //       email: 'tan.tran@example.com',
  //     ),
  //     Customer(
  //       customerName: 'Phan Nguyen Khoa',
  //       phoneNumber: '0912345678',
  //       email: 'khoa.phan@example.com',
  //     ),
  //     Customer(
  //       customerName: 'Do Hong Quan',
  //       phoneNumber: '0923456789',
  //       email: 'quan.do@example.com',
  //     ),
  //     Customer(
  //       customerName: 'To Vinh Tien',
  //       phoneNumber: '0934567890',
  //       email: 'tien.to@example.com',
  //     ),
  //     Customer(
  //       customerName: 'Nguyen Duy Vu',
  //       phoneNumber: '0945678901',
  //       email: 'vu.nguyen@example.com',
  //     ),
  //   ];
  //
  //   employeeList = [
  //     Employee(
  //       employeeID: 'EMPSAMPLE',
  //       employeeName: 'To Vinh Tien',
  //       phoneNumber: '0901234567',
  //       email: '22521474@gm.uit.edu.vn',
  //       role: RoleEnum.owner,
  //     ),
  //   ];
  //
  //   // salesInvoiceList = [
  //   //   SalesInvoice(
  //   //     customerID: 'noxiFkqUTN4bum27HPCq', // Tran Nhat Tan
  //   //     address: '123 Nguyen Van Cu, District 5, Ho Chi Minh City',
  //   //     date: DateTime(2024, 3, 15),
  //   //     paymentStatus: PaymentStatus.paid,
  //   //     salesStatus: SalesStatus.completed,
  //   //     totalPrice: 639.96,
  //   //     details: [
  //   //       SalesInvoiceDetail(
  //   //         salesInvoiceID: '',
  //   //         productID: '7eugMyslQdaIX59qzD8x', // AMD Ryzen 5 7600X
  //   //         sellingPrice: 229.99,
  //   //         quantity: 1,
  //   //         subtotal: 229.99,
  //   //       ),
  //   //       SalesInvoiceDetail(
  //   //         salesInvoiceID: '',
  //   //         productID: 'PCSKvpsEj5FPBV1U7njG', // MSI MAG B760M MORTAR
  //   //         sellingPrice: 229.99,
  //   //         quantity: 1,
  //   //         subtotal: 229.99,
  //   //       ),
  //   //       SalesInvoiceDetail(
  //   //         salesInvoiceID: '',
  //   //         productID: '2xMyMBUL86Gv16kxUC8V', // G.Skill Ripjaws V DDR4
  //   //         sellingPrice: 89.99,
  //   //         quantity: 2,
  //   //         subtotal: 179.98,
  //   //       ),
  //   //     ],
  //   //   ),
  //   //
  //   //   SalesInvoice(
  //   //     customerID: 'dKV74hSAXozpmhPgXerv', // Do Hong Quan
  //   //     address: '456 Le Hong Phong, District 10, Ho Chi Minh City',
  //   //     date: DateTime(2024, 3, 16),
  //   //     paymentStatus: PaymentStatus.unpaid,
  //   //     salesStatus: SalesStatus.pending,
  //   //     totalPrice: 349.99,
  //   //     details: [
  //   //       SalesInvoiceDetail(
  //   //         salesInvoiceID: '',
  //   //         productID: '9xKyNBWL86Gv16kxUC8Z', // AMD Ryzen 7 7800X3D
  //   //         sellingPrice: 349.99,
  //   //         quantity: 1,
  //   //         subtotal: 349.99,
  //   //       ),
  //   //     ],
  //   //   ),
  //   //
  //   //   SalesInvoice(
  //   //     customerID: '4e2PT6vyB9tszKqEcx6I', // Nguyen Duy Vu
  //   //     address: '789 Ly Thuong Kiet, District 11, Ho Chi Minh City',
  //   //     date: DateTime(2024, 3, 17),
  //   //     paymentStatus: PaymentStatus.paid,
  //   //     salesStatus: SalesStatus.shipping,
  //   //     totalPrice: 1649.98,
  //   //     details: [
  //   //       SalesInvoiceDetail(
  //   //         salesInvoiceID: '',
  //   //         productID: '3zLxMBWL86Gv16kxUC8Y', // AMD Threadripper PRO 5995WX
  //   //         sellingPrice: 1199.99,
  //   //         quantity: 1,
  //   //         subtotal: 1199.99,
  //   //       ),
  //   //       SalesInvoiceDetail(
  //   //         salesInvoiceID: '',
  //   //         productID: '5vNwMBWL86Gv16kxUC8X', // ASUS ROG MAXIMUS Z790 HERO
  //   //         sellingPrice: 449.99,
  //   //         quantity: 1,
  //   //         subtotal: 449.99,
  //   //       ),
  //   //     ],
  //   //   ),
  //   // ];
  //
  //   // warrantyInvoiceList = [
  //   //   WarrantyInvoice(
  //   //     customerID: 'noxiFkqUTN4bum27HPCq', // Tran Nhat Tan
  //   //     date: DateTime(2024, 3, 1),
  //   //     status: WarrantyStatus.pending,
  //   //     reason: 'RAM không hoạt động',
  //   //     details: [
  //   //       WarrantyInvoiceDetail(
  //   //         warrantyInvoiceID: '',
  //   //         productID: '2xMyMBUL86Gv16kxUC8V', // G.Skill Ripjaws V DDR4
  //   //         quantity: 1,
  //   //       ),
  //   //     ],
  //   //   ),
  //   //
  //   //   WarrantyInvoice(
  //   //     customerID: 'dKV74hSAXozpmhPgXerv', // Do Hong Quan
  //   //     date: DateTime(2024, 3, 10),
  //   //     status: WarrantyStatus.processing,
  //   //     reason: 'CPU quá nóng khi sử dụng',
  //   //     details: [
  //   //       WarrantyInvoiceDetail(
  //   //         warrantyInvoiceID: '',
  //   //         productID: '3udzXJtFke9jwkqhVh46', // Intel Core i5-13600K
  //   //         quantity: 1,
  //   //       ),
  //   //     ],
  //   //   ),
  //   //
  //   //   WarrantyInvoice(
  //   //     customerID: 'DyyMyOTtZ7J2SQzsr6IZ', // To Vinh Tien
  //   //     date: DateTime(2024, 3, 15),
  //   //     status: WarrantyStatus.completed,
  //   //     reason: 'Mainboard không nhận RAM',
  //   //     details: [
  //   //       WarrantyInvoiceDetail(
  //   //         warrantyInvoiceID: '',
  //   //         productID: 'mL08tBQDtbM95zDqAbbj', // MSI PRO H610I
  //   //         quantity: 1,
  //   //       ),
  //   //     ],
  //   //   ),
  //   // ];
  //
  //   incomingInvoiceList = [
  //     IncomingInvoice(
  //       manufacturerID: 'Corsair',
  //       date: DateTime(2024, 3, 1),
  //       status: PaymentStatus.paid,
  //       totalPrice: 2499.95,
  //       details: [
  //         IncomingInvoiceDetail(
  //           incomingInvoiceID: '',
  //           productID: productList[0].productID!, // Kingston HyperX Fury DDR3
  //           importPrice: 49.99,
  //           quantity: 50,
  //           subtotal: 2499.95,
  //         ),
  //       ],
  //     ),
  //
  //     IncomingInvoice(
  //       manufacturerID: 'Intel',
  //       date: DateTime(2024, 3, 5),
  //       status: PaymentStatus.unpaid,
  //       totalPrice: 9999.90,
  //       details: [
  //         IncomingInvoiceDetail(
  //           incomingInvoiceID: '',
  //           productID: productList[8].productID!, // Intel Core i3-13100
  //           importPrice: 99.99,
  //           quantity: 100,
  //           subtotal: 9999.90,
  //         ),
  //       ],
  //     ),
  //
  //     IncomingInvoice(
  //       manufacturerID: 'Samsung',
  //       date: DateTime(2024, 3, 10),
  //       status: PaymentStatus.unpaid,
  //       totalPrice: 29999.25,
  //       details: [
  //         IncomingInvoiceDetail(
  //           incomingInvoiceID: '',
  //           productID: productList[20].productID!, // Samsung 870 EVO
  //           importPrice: 79.99,
  //           quantity: 250,
  //           subtotal: 19997.50,
  //         ),
  //         IncomingInvoiceDetail(
  //           incomingInvoiceID: '',
  //           productID: productList[21].productID!, // Samsung 970 EVO Plus
  //           importPrice: 199.99,
  //           quantity: 50,
  //           subtotal: 9999.75,
  //         ),
  //       ],
  //     ),
  //
  //     IncomingInvoice(
  //       manufacturerID: 'AMD',
  //       date: DateTime(2024, 3, 15),
  //       status: PaymentStatus.paid,
  //       totalPrice: 149997.00,
  //       details: [
  //         IncomingInvoiceDetail(
  //           incomingInvoiceID: '',
  //           productID: productList[13].productID!, // AMD Ryzen 5 7600X
  //           importPrice: 199.99,
  //           quantity: 300,
  //           subtotal: 59997.00,
  //         ),
  //         IncomingInvoiceDetail(
  //           incomingInvoiceID: '',
  //           productID: productList[14].productID!, // AMD Ryzen 7 7800X3D
  //           importPrice: 299.99,
  //           quantity: 300,
  //           subtotal: 89997.00,
  //         ),
  //       ],
  //     ),
  //   ];
  // }
  //
  // void generateSampleData() {
  //    _initializeSampleData();
  // }

  Future<void> getUsername() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      username = userDoc['username'];
    }
  }

  Future<void> getUser() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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

      List<Province> provinceList = jsonList.map((province) => Province.fromJson(province)).toList();
      return provinceList;
    } catch (e) {
      throw Exception('Error loading provinces from file: $e'); // Lỗi khi load dữ liệu từ file
    }
  }

  Future<void> fetchAddress() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final addressSnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .get();

      addressList = addressSnapshot.docs.map((doc) {
        return Address.fromMap(doc.data());
      }).toList();
    }
  }

  void updateProductList (List<Product> productList) {
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

