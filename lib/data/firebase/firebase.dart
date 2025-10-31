import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:gizmoglobe_client/objects/voucher_related/owned_voucher.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher_factory.dart';
import 'package:gizmoglobe_client/objects/voucher_related/end_time_interface.dart';
import '../../data/database/database.dart';
import '../../enums/invoice_related/payment_status.dart';
import '../../enums/invoice_related/sales_status.dart';
import '../../objects/product_related/product_serializer.dart';
import '../../enums/product_related/product_status_enum.dart';
import '../../enums/stakeholders/employee_role.dart';
import '../../enums/stakeholders/manufacturer_status.dart';
import '../../objects/address_related/address.dart';
import '../../objects/address_related/district.dart';
import '../../objects/address_related/province.dart';
import '../../objects/address_related/ward.dart';
import '../../objects/customer.dart';
import '../../objects/employee.dart';
import '../../objects/invoice_related/incoming_invoice.dart';
import '../../objects/invoice_related/incoming_invoice_detail.dart';
import '../../objects/invoice_related/sales_invoice_detail.dart';
import '../../objects/invoice_related/warranty_invoice_detail.dart';
import '../../objects/manufacturer.dart';
import '../../objects/product_related/product.dart';
import '../../objects/product_related/product_factory.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gizmoglobe_client/objects/invoice_related/warranty_invoice.dart';
import 'package:gizmoglobe_client/objects/chat_related/chat.dart';

class Firebase {
  static final Firebase _firebase = Firebase._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory Firebase() {
    return _firebase;
  }

  Firebase._internal();

  // Thêm getter để lấy current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  Future<List<Customer>> getCustomers() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('customers').get();

      return snapshot.docs.map((doc) {
        return Customer.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting customers data : $e');
      } // Lỗi khi lấy danh sách khách hàng
      rethrow;
    }
  }

  Stream<List<Customer>> customersStream() {
    return FirebaseFirestore.instance
        .collection('customers')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Customer.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      if (customer.customerID == null) {
        throw Exception(
            'Customer ID cannot be null'); // ID khách hàng không thể trống
      }

      // Update customer information
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(customer.customerID)
          .update({
        'customerName': customer.customerName,
        'phoneNumber': customer.phoneNumber,
      });

      // Update corresponding user information
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userID', isEqualTo: customer.customerID)
          .get();

      for (var doc in userSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .update({
          'username': customer.customerName,
        });
      }

      // Fetch and update matched addresses
      QuerySnapshot addressSnapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .where('customerID', isEqualTo: customer.customerID)
          .get();

      for (var doc in addressSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('addresses')
            .doc(doc.id)
            .update({
          'receiverName': customer.customerName,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating customer: $e');
      } // Lỗi khi cập nhật thông tin khách hàng
      rethrow;
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      // Xóa khách hàng từ collection customers
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .delete();

      // Xóa tài khoản user tương ứng nếu có
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('userID', isEqualTo: customerId)
          .get();

      for (var doc in userSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(doc.id)
            .delete();
      }

      // Có thể thêm logic để xóa các dữ liệu liên quan khác
      // như orders, cart items, etc.
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting customers data: $e');
      } // Lỗi khi xóa khách hàng
      rethrow;
    }
  }

  Future<void> createCustomer(Customer customer) async {
    try {
      // Tạo customer trong collection customers
      DocumentReference customerRef = await FirebaseFirestore.instance
          .collection('customers')
          .add(customer.toMap());

      String customerId = customerRef.id;
      customer.customerID = customerId;

      // Cập nhật customerID trong document customer
      await customerRef.update({'customerID': customerId});

      // Tạo user với cùng ID như customer
      await FirebaseFirestore.instance
          .collection('users')
          .doc(customerId) // Sử dụng customerId làm document ID
          .set({
        'email': customer.email,
        'username': customer.customerName,
        'role': 'customer',
        'userID': customerId
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error creating new customer: $e');
      } // Lỗi khi tạo khách hàng mới
      rethrow;
    }
  }

  Future<Customer?> getCustomerByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) return null;

      return Customer.fromMap(
        snapshot.docs.first.id,
        snapshot.docs.first.data() as Map<String, dynamic>,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error searching customer by email: $e');
      } // Lỗi khi tìm kiếm khách hàng theo email
      rethrow;
    }
  }

  Future<void> createAddress(Address address) async {
    try {
      // Add address to collection addresses
      DocumentReference addressRef = await FirebaseFirestore.instance
          .collection('addresses')
          .add(address.toMap());

      String addressId = addressRef.id;
      address.addressID = addressId;

      // Update addressID in the document address
      await addressRef.update({'addressID': addressId});
      await FirebaseFirestore.instance
          .collection('addresses')
          .doc(addressId)
          .set({
        'addressID': addressId,
        'customerID': address.customerID,
        'receiverName': address.receiverName,
        'receiverPhone': address.receiverPhone,
        'provinceCode': address.province?.code,
        'districtCode': address.district?.code,
        'wardCode': address.ward?.code,
        'street': address.street ?? '',
        'hidden': address.hidden,
      });

      await Database().fetchAddress();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating new address: $e');
      } // Lỗi khi tạo địa chỉ mới
      rethrow;
    }
  }

  Future<void> updateAddress(Address address) async {
    try {
      if (address.addressID == null) {
        throw Exception('Address ID cannot be null');
      }

      // Update address information
      await FirebaseFirestore.instance
          .collection('addresses')
          .doc(address.addressID)
          .update({
        'receiverName': address.receiverName,
        'receiverPhone': address.receiverPhone,
        'provinceCode': address.province?.code,
        'districtCode': address.district?.code,
        'wardCode': address.ward?.code,
        'street': address.street ?? '',
        'hidden': address.hidden,
      });

      await Database().fetchAddress();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating address: $e');
      } // Lỗi khi cập nhật địa chỉ
      rethrow;
    }
  }

  // Employee-related functions
  Future<List<Employee>> getEmployees() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('employees').get();

      return snapshot.docs.map((doc) {
        return Employee.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting employees list: $e');
      } // Lỗi khi lấy danh sách nhân viên
      rethrow;
    }
  }

  Stream<List<Employee>> employeesStream() {
    return FirebaseFirestore.instance
        .collection('employees')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Employee.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<void> updateEmployee(Employee employee) async {
    try {
      if (employee.employeeID == null) {
        throw Exception(
            'Employee ID cannot be null'); // ID nhân viên không thể trống
      }

      // Lấy thông tin employee cũ trước khi cập nhật
      DocumentSnapshot oldEmployeeDoc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(employee.employeeID)
          .get();

      if (!oldEmployeeDoc.exists) {
        throw Exception('Employee not found'); // Không tìm thấy nhân viên
      }

      Map<String, dynamic> oldEmployeeData =
          oldEmployeeDoc.data() as Map<String, dynamic>;
      String oldEmail = oldEmployeeData['email'];

      // Tạo map chứa thông tin cần cập nhật, không bao gồm email
      Map<String, dynamic> updateData = {
        'employeeName': employee.employeeName,
        'phoneNumber': employee.phoneNumber,
        'role': employee.role.getName(),
      };

      // Cập nhật thông tin employee
      await FirebaseFirestore.instance
          .collection('employees')
          .doc(employee.employeeID)
          .update(updateData);

      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: oldEmail)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        await updateUserInformation(userSnapshot.docs.first.id, {
          'username': employee.employeeName,
          'role': employee.role == RoleEnum.owner
              ? 'admin'
              : employee.role.getName(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating employees information: $e');
      } // Lỗi khi cập nhật thông tin nhân viên
      rethrow;
    }
  }

  Future<void> deleteEmployee(String employeeId) async {
    try {
      // Lấy thông tin nhân viên trước khi xóa
      DocumentSnapshot employeeDoc = await FirebaseFirestore.instance
          .collection('employees')
          .doc(employeeId)
          .get();

      if (employeeDoc.exists) {
        String employeeEmail =
            (employeeDoc.data() as Map<String, dynamic>)['email'];

        // Xóa nhân viên
        await FirebaseFirestore.instance
            .collection('employees')
            .doc(employeeId)
            .delete();

        // Xóa tài khoản user tương ứng
        QuerySnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: employeeEmail)
            .get();

        for (var doc in userSnapshot.docs) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(doc.id)
              .delete();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting employee: $e');
      } // Lỗi khi xóa nhân viên
      rethrow;
    }
  }

  Future<void> addEmployee(Employee employee) async {
    try {
      // Kiểm tra xem email đã tồn tại chưa
      QuerySnapshot existingEmployees = await FirebaseFirestore.instance
          .collection('employees')
          .where('email', isEqualTo: employee.email)
          .get();

      if (existingEmployees.docs.isNotEmpty) {
        throw Exception(
            'Email has already been registered'); // Email đã được đăng ký
      }

      // Thêm nhân viên mới vào collection employees
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('employees')
          .add(employee.toMap());

      // Cập nhật ID cho nhân viên
      employee.employeeID = docRef.id;

      // Thêm tài khoản user tương ứng
      await FirebaseFirestore.instance.collection('users').doc(docRef.id).set({
        'email': employee.email,
        'username': employee.employeeName,
        'userID': docRef.id,
        'role':
            employee.role == RoleEnum.owner ? 'admin' : employee.role.getName(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding employee: $e');
      } // Lỗi khi thêm nhân viên
      rethrow;
    }
  }

  // Manufacturer-related functions
  Future<List<Manufacturer>> getManufacturers() async {
    try {
      final snapshot = await _firestore.collection('manufacturers').get();
      return snapshot.docs
          .map((doc) => _mapManufacturerFromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting manufacturers: $e');
      } // Lỗi khi lấy danh sách nhà sản xuất
      rethrow;
    }
  }

  Stream<List<Manufacturer>> manufacturersStream() {
    return _firestore.collection('manufacturers').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => _mapManufacturerFromJson(doc.data()))
            .toList());
  }

  Future<void> updateManufacturer(Manufacturer manufacturer) async {
    try {
      final doc = _firestore
          .collection('manufacturers')
          .doc(manufacturer.manufacturerID);
      await doc.update(_mapManufacturerToJson(manufacturer));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating manufacturer: $e');
      } // Lỗi khi cập nhật thông tin nhà sản xuất
      rethrow;
    }
  }

  Future<void> deleteManufacturer(String manufacturerId) async {
    try {
      // Find document by manufacturerID field
      final querySnapshot = await FirebaseFirestore.instance
          .collection('manufacturers')
          .where('manufacturerID', isEqualTo: manufacturerId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Manufacturer not found');
      }

      await FirebaseFirestore.instance
          .collection('manufacturers')
          .doc(querySnapshot.docs.first.id)
          .delete();

      // Cập nhật trạng thái discontinued cho các sản phẩm liên quan
      final productsSnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('manufacturerID', isEqualTo: manufacturerId)
          .get();

      for (var doc in productsSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('products')
            .doc(doc.id)
            .update({'status': 'discontinued'});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting manufacturer: $e');
      } // Lỗi khi xóa nhà sản xuất
      rethrow;
    }
  }

  Future<void> createManufacturer(Manufacturer manufacturer) async {
    try {
      final doc = _firestore
          .collection('manufacturers')
          .doc(manufacturer.manufacturerID);
      await doc.set(_mapManufacturerToJson(manufacturer));
    } catch (e) {
      if (kDebugMode) {
        print('Error creating manufacturer: $e');
      } // Lỗi khi tạo nhà sản xuất
      rethrow;
    }
  }

  Future<Manufacturer?> getManufacturerById(String manufacturerId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('manufacturers')
          .where('manufacturerID', isEqualTo: manufacturerId)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final data = querySnapshot.docs.first.data();
      return Manufacturer(
        manufacturerID: data['manufacturerID'] ?? '',
        manufacturerName: data['manufacturerName'] ?? '',
        status: _mapManufacturerStatus(data['status'] as String? ?? 'active'),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error finding manufacturer by ID: $e');
      } // Lỗi khi tìm nhà sản xuất theo ID
      rethrow;
    }
  }

  Future<void> updateUserInformation(
      String userId, Map<String, dynamic> userData) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update(userData);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user data: $e');
      } // Lỗi khi cập nhật thông tin user
      rethrow;
    }
  }

  Future<bool> checkUserExistsInDatabase(String email) async {
    try {
      QuerySnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      return userSnapshot.docs.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('Error checking user exists in database: $e');
      } // Lỗi khi kiểm tra user tồn tại trong database
      rethrow;
    }
  }

  // Product-related functions
  Future<List<Product>> getProducts() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('products').get();

      List<Product> products = [];
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Tạo product instance thông qua factory
        Product product = ProductFactory.createProduct(data);
        products.add(product);
      }

      return products;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting products: $e');
      } // Lỗi khi lấy danh sách sản phẩm
      rethrow;
    }
  }

  Stream<List<Product>> productsStream() {
    return FirebaseFirestore.instance
        .collection('products')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Product> products = [];
      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data();

          Product product = ProductFactory.createProduct(data);
          products.add(product);
        } catch (e) {
          if (kDebugMode) {
            print('Error processing product ${doc.id}: $e');
          } // Lỗi khi xử lý sản phẩm
          continue;
        }
      }
      return products;
    });
  }

  Future<List<SalesInvoice>> getSalesInvoices() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('sales_invoices')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return SalesInvoice.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading sales invoices: $e');
      } // Lỗi khi tải danh sách hóa đơn bán hàng
      rethrow;
    }
  }

  Stream<List<SalesInvoice>> salesInvoicesStream() {
    return _firestore
        .collection('sales_invoices')
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      List<SalesInvoice> invoices = [];

      for (var doc in snapshot.docs) {
        // Create the invoice
        final invoice = SalesInvoice.fromMap(doc.id, doc.data());

        // Get details for this invoice
        final details = await getSalesInvoiceDetails(invoice.salesInvoiceID);
        invoice.details = details;

        invoices.add(invoice);
      }

      return invoices;
    });
  }

  Future<SalesInvoice?> createSalesInvoice(SalesInvoice invoice) async {
    try {
      final batch = FirebaseFirestore.instance.batch();

      final docRef = FirebaseFirestore.instance
          .collection('sales_invoices')
          .doc(invoice.salesInvoiceID);

      // Store only the addressID instead of the full address object
      batch.set(docRef, {
        'salesInvoiceID': invoice.salesInvoiceID,
        'customerID': invoice.customerID,
        'customerName': invoice.customerName,
        'address': invoice.address.addressID, // Just store the ID
        'paymentStatus': invoice.paymentStatus.getName(),
        'salesStatus': invoice.salesStatus.getName(),
        'totalPrice': invoice.totalPrice,
        'date': invoice.date,
      });

      // Add details...
      for (final detail in invoice.details) {
        final detailRef = FirebaseFirestore.instance
            .collection('sales_invoice_details')
            .doc();

        batch.set(detailRef, {
          'salesInvoiceDetailID': detailRef.id,
          'salesInvoiceID': invoice.salesInvoiceID,
          'productID': detail.productID,
          'productName': detail.productName,
          'quantity': detail.quantity,
          'sellingPrice': detail.sellingPrice,
          'subtotal': detail.subtotal,
        });
      }

      await batch.commit();
      // After creating the invoice and its details, update product stock and sales
      // We do this after the batch commit to avoid mixing counters with set/delete ops
      for (final detail in invoice.details) {
        try {
          // stock decreases by quantity; sales increases by quantity
          await updateProductStockAndSales(
              detail.productID, -detail.quantity, detail.quantity);
        } catch (_) {
          // ignore single product failures here; overall invoice is created
          // and any failed product updates can be corrected separately
        }
      }

      return invoice;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating sales invoice: $e');
      } //Lỗi khi tạo hóa đơn bán hàng
      return null;
    }
  }

  // Add a method to fetch invoice details
  Future<List<SalesInvoiceDetail>> getSalesInvoiceDetails(
      String invoiceId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('sales_invoice_details')
          .where('salesInvoiceID', isEqualTo: invoiceId)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return SalesInvoiceDetail(
          salesInvoiceID: data['salesInvoiceID'] ?? '',
          productID: data['productID'] ?? '',
          productName: data['productName'] ?? '',
          quantity: data['quantity'] ?? 0,
          sellingPrice: (data['sellingPrice'] ?? 0).toDouble(),
          subtotal: (data['subtotal'] ?? 0).toDouble(),
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching sales invoice details: $e');
      } //Lỗi khi tải chi tiết hóa đơn bán hàng
      return [];
    }
  }

  // Future<void> _updateProductStock(String productID, int quantity) async {
  //   final productRef = _firestore.collection('products').doc(productID);
  //
  //   return _firestore.runTransaction((transaction) async {
  //     final productDoc = await transaction.get(productRef);
  //     if (!productDoc.exists) {
  //       throw Exception('Product not found'); // Không tìm thấy sản phẩm
  //     }
  //
  //     final currentStock = productDoc.data()?['stock'] as int;
  //     if (currentStock < quantity) {
  //       throw Exception('Not enough stock'); // Không đủ hàng trong kho
  //     }
  //
  //     transaction.update(productRef, {
  //       'stock': currentStock - quantity,
  //     });
  //   });
  // }

  Future<Map<String, dynamic>> getCustomerDetails(String customerID) async {
    try {
      final doc =
          await _firestore.collection('customers').doc(customerID).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'customerName': data['customerName'] ?? 'Unknown Customer',
          'phoneNumber': data['phoneNumber'],
          'email': data['email'],
        };
      }

      return {
        'customerName': 'Unknown Customer',
        'phoneNumber': '',
        'email': '',
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting customer details: $e');
      } // Lỗi khi lấy thông tin khách hàng
      return {
        'customerName': 'Unknown Customer',
        'phoneNumber': '',
        'email': '',
      };
    }
  }

  Future<Map<String, dynamic>> getProductDetails(String productID) async {
    try {
      final doc = await _firestore.collection('products').doc(productID).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'productName': data['productName'] ?? 'Unknown Product',
          'category': data['category'] ?? '',
          'manufacturer': data['manufacturer'],
          'importPrice': data['importPrice'],
          'sellingPrice': data['sellingPrice'],
          'enDescription': data['enDescription'],
          'viDescription': data['viDescription'],
        };
      }

      if (kDebugMode) {
        print('Product not found: $productID');
      } // Không tìm thấy sản phẩm
      return {
        'productName': 'Unknown Product',
        'category': '',
        'manufacturer': '',
        'importPrice': 0,
        'sellingPrice': 0,
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting product details for $productID: $e');
      } // Lỗi khi lấy thông tin sản phẩm
      return {
        'productName': 'Unknown Product',
        'category': '',
        'manufacturer': '',
        'importPrice': 0,
        'sellingPrice': 0,
      };
    }
  }

  Future<SalesInvoice> getSalesInvoiceWithDetails(String invoiceID) async {
    try {
      // Get the invoice document
      final invoiceDoc =
          await _firestore.collection('sales_invoices').doc(invoiceID).get();

      if (!invoiceDoc.exists) {
        throw Exception('Invoice not found'); // Không tìm thấy hóa đơn
      }

      final data = invoiceDoc.data()!;

      // Get customer details
      final customerDetails =
          await getCustomerDetails(data['customerID'] as String);
      data['customerName'] = customerDetails['customerName'];

      // Create the invoice
      final invoice = SalesInvoice.fromMap(invoiceDoc.id, data);

      // Get and set the details
      final detailsSnapshot = await _firestore
          .collection('sales_invoice_details')
          .where('salesInvoiceID', isEqualTo: invoiceID)
          .get();

      // Process each detail and get product information
      List<SalesInvoiceDetail> details = [];
      for (var detailDoc in detailsSnapshot.docs) {
        final detailData = detailDoc.data();
        final productDetails =
            await getProductDetails(detailData['productID'] as String);

        details.add(SalesInvoiceDetail(
          salesInvoiceID: detailData['salesInvoiceID'] as String,
          productID: detailData['productID'] as String,
          productName: productDetails['productName'],
          category: productDetails['category'],
          quantity: detailData['quantity'] as int,
          sellingPrice: (detailData['sellingPrice'] as num).toInt(),
          subtotal: (detailData['subtotal'] as num).toDouble(),
        ));
      }

      invoice.details = details;
      return invoice;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting sales invoice details: $e');
      } // Lỗi khi lấy chi tiết hóa đơn bán hàng
      rethrow;
    }
  }

  Future<void> updateSalesInvoiceDetail(SalesInvoiceDetail detail) async {
    try {
      // Create a new document reference if needed
      final detailRef = _firestore.collection('sales_invoice_details').doc();

      // Update the detail document
      await detailRef.set(detail.toJson());

      // Update product stock
      final productDoc =
          await _firestore.collection('products').doc(detail.productID).get();

      if (!productDoc.exists) {
        throw Exception('Product not found'); // Không tìm thấy sản phẩm
      }

      // Get the old detail to calculate stock difference
      final oldDetailQuery = await _firestore
          .collection('sales_invoice_details')
          .where('salesInvoiceID', isEqualTo: detail.salesInvoiceID)
          .where('productID', isEqualTo: detail.productID)
          .get();

      if (oldDetailQuery.docs.isNotEmpty) {
        final oldDetail = oldDetailQuery.docs.first;
        final oldQuantity = oldDetail.data()['quantity'] as int;
        final stockChange = oldQuantity - detail.quantity;
        await updateProductStock(detail.productID, stockChange);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating sales invoice detail: $e');
      } // Lỗi khi cập nhật chi tiết hóa đơn bán hàng
      rethrow;
    }
  }

  Future<void> deleteSalesInvoiceDetail(
      String salesInvoiceID, String productID) async {
    try {
      // Find the detail document
      final detailQuery = await _firestore
          .collection('sales_invoice_details')
          .where('salesInvoiceID', isEqualTo: salesInvoiceID)
          .where('productID', isEqualTo: productID)
          .get();

      if (detailQuery.docs.isEmpty) {
        throw Exception(
            'Invoice detail not found'); // Không tìm thấy chi tiết hóa đơn
      }

      final detailDoc = detailQuery.docs.first;
      final quantity = detailDoc.data()['quantity'] as int;

      // Delete the detail document
      await detailDoc.reference.delete();

      // Return stock
      await updateProductStock(productID, quantity);
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting sales invoice detail: $e');
      } // Lỗi khi xóa chi tiết hóa đơn bán hàng
      rethrow;
    }
  }

  Future<void> updateProductStock(String productID, int stockChange) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productID)
          .get();

      if (!doc.exists) {
        throw Exception('Product not found'); // Không tìm thấy sản phẩm
      }

      // Đảm bảo currentStock không null
      final currentStock = doc.data()?['stock'] as int? ?? 0;

      await doc.reference.update({'stock': currentStock + stockChange});
    } catch (e) {
      if (kDebugMode) {
        print('Error updating product stock: $e');
      } // Lỗi khi cập nhật số lượng sản phẩm
      rethrow;
    }
  }

  Future<void> createSalesInvoiceDetail(SalesInvoiceDetail detail) async {
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('sales_invoice_details')
          .add(detail.toMap());

      await docRef.update({
        'salesInvoiceDetailID': docRef.id,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error creating sales invoice detail: $e');
      } // Lỗi khi tạo chi tiết hóa đơn bán hàng
      rethrow;
    }
  }

  Future<void> changeProductStatus(
      String productId, ProductStatusEnum status) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .doc(productId)
          .update({'status': status.getName()});

      List<Product> products = await getProducts();
      Database().updateProductList(products);
    } catch (e) {
      if (kDebugMode) {
        print('Error changing product status: $e');
      } // Lỗi khi thay đổi trạng thái sản phẩm
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    try {
      // Find the document by productID attribute since productID is no longer the document ID
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('productID', isEqualTo: product.productID)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception(
            'Product not found with productID: ${product.productID}');
      }

      final docRef = querySnapshot.docs.first.reference;
      await docRef.update(productToJson(product));

      List<Product> products = await getProducts();
      Database().updateProductList(products);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating product: $e');
      } // Lỗi khi cập nhật sản phẩm
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      await FirebaseFirestore.instance
          .collection('products')
          .add(productToJson(product));
      List<Product> products = await getProducts();
      Database().updateProductList(products);
    } catch (e) {
      if (kDebugMode) {
        print('Error adding product: $e');
      } // Lỗi khi thêm sản phẩm
      rethrow;
    }
  }

  Future<void> updateProductStockAndSales(
      String productID, int stockChange, int salesChange) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('products')
          .doc(productID)
          .get();

      if (!doc.exists) {
        throw Exception('Product not found'); // Không tìm thấy sản phẩm
      }

      // Đảm bảo các giá trị không null
      final currentStock = doc.data()?['stock'] as int? ?? 0;
      final currentSales = doc.data()?['sales'] as int? ?? 0;

      // Cập nhật cả stock và sales
      await doc.reference.update({
        'stock': currentStock + stockChange,
        'sales': currentSales + salesChange
      });

      // Cập nhật danh sách sản phẩm trong Database
      List<Product> products = await getProducts();
      Database().updateProductList(products);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating product stock and sales: $e');
      } // Lỗi khi cập nhật số lượng sản phẩm và doanh số
      rethrow;
    }
  }

  Future<void> changeSalesInvoiceStatus(SalesInvoice salesInvoice) async {
    try {
      await _firestore
          .collection('sales_invoices')
          .doc(salesInvoice.salesInvoiceID)
          .update({
        'salesStatus': SalesStatus.completed.getName(),
      });

      //await Database().fetchSalesInvoice();
    } catch (e) {
      if (kDebugMode) {
        print('Error confirming delivery: $e');
      } // Lỗi khi xác nhận giao hàng
      rethrow;
    }
  }

  Future<List<Address>> getCustomerAddresses(String customerID) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('addresses')
          .where('customerID', isEqualTo: customerID)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Address(
          addressID: doc.id,
          customerID: data['customerID'],
          receiverName: data['receiverName'],
          receiverPhone: data['receiverPhone'],
          province: Database().provinceList.firstWhere(
                (p) => p.code == data['provinceCode'],
                orElse: () => Province.nullProvince,
              ),
          district: Database()
              .provinceList
              .firstWhere(
                (p) => p.code == data['provinceCode'],
                orElse: () => Province.nullProvince,
              )
              .districts
              ?.firstWhere(
                (d) => d.code == data['districtCode'],
                orElse: () => District.nullDistrict,
              ),
          ward: Database()
              .provinceList
              .firstWhere(
                (p) => p.code == data['provinceCode'],
                orElse: () => Province.nullProvince,
              )
              .districts
              ?.firstWhere(
                (d) => d.code == data['districtCode'],
                orElse: () => District.nullDistrict,
              )
              .wards
              ?.firstWhere(
                (w) => w.code == data['wardCode'],
                orElse: () => Ward.nullWard,
              ),
          street: data['street'],
          hidden: data['hidden'],
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting customer addresses: $e');
      } // Lỗi khi lấy danh sách địa chỉ khách hàng
      rethrow;
    }
  }

  // Incoming Invoice Methods
  Stream<List<IncomingInvoice>> incomingInvoicesStream() {
    return _firestore
        .collection('incoming_invoices')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return IncomingInvoice.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  Future<List<IncomingInvoice>> getIncomingInvoices() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('incoming_invoices')
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return IncomingInvoice.fromMap(
            doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading incoming invoices: $e');
      } // Lỗi khi tải danh sách hóa đơn nhập hàng
      rethrow;
    }
  }

  Future<IncomingInvoice> getIncomingInvoiceWithDetails(
      String invoiceId) async {
    try {
      // Get the invoice
      final DocumentSnapshot invoiceDoc =
          await _firestore.collection('incoming_invoices').doc(invoiceId).get();

      if (!invoiceDoc.exists) {
        throw Exception('Invoice not found'); // Không tìm thấy hóa đơn
      }

      // Create invoice object
      IncomingInvoice invoice = IncomingInvoice.fromMap(
        invoiceDoc.id,
        invoiceDoc.data() as Map<String, dynamic>,
      );

      // Get invoice details
      final QuerySnapshot detailsSnapshot = await _firestore
          .collection('incoming_invoice_details')
          .where('incomingInvoiceID', isEqualTo: invoiceId)
          .get();

      // Add details to invoice
      invoice.details = detailsSnapshot.docs.map((doc) {
        return IncomingInvoiceDetail.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      return invoice;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading incoming invoice details: $e');
      } // Lỗi khi tải chi tiết hóa đơn nhập hàng
      rethrow;
    }
  }

  Future<void> updateIncomingInvoice(IncomingInvoice invoice) async {
    try {
      if (invoice.incomingInvoiceID == null) {
        throw Exception(
            'Invoice ID cannot be null'); // ID hóa đơn không thể null
      }

      // Update invoice
      await _firestore
          .collection('incoming_invoices')
          .doc(invoice.incomingInvoiceID)
          .update(invoice.toMap());

      // Update details
      for (var detail in invoice.details) {
        if (detail.incomingInvoiceDetailID != null) {
          await _firestore
              .collection('incoming_invoice_details')
              .doc(detail.incomingInvoiceDetailID)
              .update(detail.toMap());
        } else {
          // Create new detail if it doesn't exist
          final docRef = await _firestore
              .collection('incoming_invoice_details')
              .add(detail.toMap());

          await docRef.update({
            'incomingInvoiceDetailID': docRef.id,
          });
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating incoming invoice: $e');
      } // Lỗi khi cập nhật hóa đơn nhập hàng
      rethrow;
    }
  }

  Future<String> createIncomingInvoice(IncomingInvoice invoice) async {
    try {
      // Create invoice
      final docRef =
          await _firestore.collection('incoming_invoices').add(invoice.toMap());

      // Update invoice with ID
      await docRef.update({
        'incomingInvoiceID': docRef.id,
      });

      // Create details
      for (var detail in invoice.details) {
        detail.incomingInvoiceID = docRef.id;
        final detailRef = await _firestore
            .collection('incoming_invoice_details')
            .add(detail.toMap());

        await detailRef.update({
          'incomingInvoiceDetailID': detailRef.id,
        });
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating incoming invoice: $e');
      } // Lỗi khi tạo hóa đơn nhập hàng
      rethrow;
    }
  }

  Future<void> deleteIncomingInvoice(String invoiceId) async {
    try {
      // Delete invoice details first
      final QuerySnapshot detailsSnapshot = await _firestore
          .collection('incoming_invoice_details')
          .where('incomingInvoiceID', isEqualTo: invoiceId)
          .get();

      for (var doc in detailsSnapshot.docs) {
        await _firestore
            .collection('incoming_invoice_details')
            .doc(doc.id)
            .delete();
      }

      // Delete invoice
      await _firestore.collection('incoming_invoices').doc(invoiceId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting incoming invoice: $e');
      } // Lỗi khi xóa hóa đơn nhập hàng
      rethrow;
    }
  }

  Future<String?> getUserRole([String? userID]) async {
    try {
      final id = userID ?? currentUserId;
      if (id == null) return null;

      final doc = await _firestore.collection('users').doc(id).get();
      if (doc.exists) {
        return doc.data()?['role'] as String?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user role: $e');
      } // Lỗi khi lấy vai trò người dùng
      return null;
    }
  }

  Future<Customer> getCustomer(String customerId) async {
    try {
      final doc =
          await _firestore.collection('customers').doc(customerId).get();

      if (!doc.exists) {
        throw Exception('Customer not found');
      }

      return Customer.fromMap(doc.id, doc.data()!);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting customer: $e');
      } // Lỗi khi lấy thông tin khách hàng
      rethrow;
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      if (kDebugMode) {
        print('Getting product: $productId');
      }

      final doc = await _firestore.collection('products').doc(productId).get();

      if (!doc.exists) {
        if (kDebugMode) {
          print('Product not found: $productId');
        }
        return null;
      }

      final data = Map<String, dynamic>.from(doc.data()!);
      final product = ProductFactory.createProduct(data);
      if (kDebugMode) {
        print('Created product: ${product.productName}');
      }
      return product;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting product $productId: $e');
      }
      return null;
    }
  }

  Future<List<SalesInvoice>> getCustomerSalesInvoices(String customerId) async {
    try {
      final snapshot = await _firestore
          .collection('sales_invoices')
          .where('customerID', isEqualTo: customerId)
          .where('paymentStatus', isEqualTo: PaymentStatus.paid.getName())
          .where('salesStatus', isEqualTo: SalesStatus.completed.getName())
          .orderBy('date', descending: true)
          .get();

      return Future.wait(snapshot.docs.map((doc) async {
        final invoice = SalesInvoice.fromMap(doc.id, doc.data());

        // Load details
        final detailsSnapshot = await _firestore
            .collection('sales_invoice_details')
            .where('salesInvoiceID', isEqualTo: doc.id)
            .get();

        invoice.details = detailsSnapshot.docs
            .map((doc) => SalesInvoiceDetail.fromMap(doc.data()))
            .toList();

        return invoice;
      }));
    } catch (e) {
      if (kDebugMode) {
        print('Error getting customer sales invoices: $e');
      } // Lỗi khi lấy danh sách hóa đơn bán hàng của khách hàng
      rethrow;
    }
  }

  Future<List<WarrantyInvoice>> getWarrantyInvoices() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('warranty_invoices') // Bảo hành
          .get();

      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(doc.data() as Map);
        return WarrantyInvoice.fromMap(doc.id, data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading warranty invoices: $e');
      } // Lỗi khi tải danh sách hóa đơn bảo hành
      rethrow;
    }
  }

  Future<WarrantyInvoice> getWarrantyInvoiceWithDetails(
      String invoiceId) async {
    try {
      // Get the invoice
      final DocumentSnapshot invoiceDoc =
          await _firestore.collection('warranty_invoices').doc(invoiceId).get();

      if (!invoiceDoc.exists) {
        throw Exception(
            'Warranty invoice not found'); // Không tìm thấy hóa đơn bảo hành
      }

      // Create invoice object
      final Map<String, dynamic> invoiceData =
          Map<String, dynamic>.from(invoiceDoc.data() as Map);
      WarrantyInvoice invoice =
          WarrantyInvoice.fromMap(invoiceDoc.id, invoiceData);

      // Get invoice details
      final QuerySnapshot detailsSnapshot = await _firestore
          .collection('warranty_invoice_details')
          .where('warrantyInvoiceID', isEqualTo: invoiceId)
          .get();

      // Add details to invoice
      invoice.details = detailsSnapshot.docs.map((doc) {
        return WarrantyInvoiceDetail.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      return invoice;
    } catch (e) {
      if (kDebugMode) {
        print('Error loading warranty invoice details: $e');
      } // Lỗi khi tải chi tiết hóa đơn bảo hành
      rethrow;
    }
  }

  Stream<List<WarrantyInvoice>> warrantyInvoicesStream() {
    return _firestore
        .collection('warranty_invoices')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(doc.data() as Map);
        return WarrantyInvoice.fromMap(doc.id, data);
      }).toList();
    });
  }

  Future<void> updateWarrantyInvoice(WarrantyInvoice invoice) async {
    try {
      await _firestore
          .collection('warranty_invoices')
          .doc(invoice.warrantyInvoiceID)
          .update(invoice.toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating warranty invoice: $e');
      } // Lỗi khi cập nhật hóa đơn bảo hành
      rethrow;
    }
  }

  Future<String?> createWarrantyInvoice(WarrantyInvoice invoice) async {
    try {
      // Create warranty invoice document
      final docRef = await _firestore.collection('warranty_invoices').add({
        'warrantyInvoiceID': '', // Temporary placeholder
        'salesInvoiceID': invoice.salesInvoiceID,
        'customerName': invoice.customerName,
        'customerID': invoice.customerID,
        'date': Timestamp.fromDate(invoice.date),
        'status': invoice.status.getName(),
        'reason': invoice.reason,
      });

      // Update the document with its own ID
      await docRef.update({
        'warrantyInvoiceID': docRef.id,
      });

      // Create warranty details
      final batch = _firestore.batch();

      for (var detail in invoice.details) {
        final detailRef =
            _firestore.collection('warranty_invoice_details').doc();
        batch.set(detailRef, {
          'warrantyInvoiceID': docRef.id,
          'warrantyInvoiceDetailID': detailRef.id,
          'productID': detail.productID,
          'quantity': detail.quantity,
        });
      }

      await batch.commit();

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating warranty invoice: $e');
      } // Lỗi khi tạo hóa đơn bảo hành
      return null;
    }
  }

  Future<void> createWarrantyInvoiceDetail(WarrantyInvoiceDetail detail) async {
    try {
      final docRef = await _firestore
          .collection('warranty_invoice_details')
          .add(detail.toMap());

      await docRef.update({
        'warrantyInvoiceDetailID': docRef.id,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error creating warranty invoice detail: $e');
      } // Lỗi khi tạo chi tiết hóa đơn bảo hành
      rethrow;
    }
  }

  Future<void> updateManufacturerAndProducts(Manufacturer manufacturer) async {
    try {
      // Update manufacturer in Firebase
      final manufacturerDoc = _firestore
          .collection('manufacturers')
          .doc(manufacturer.manufacturerID);
      await manufacturerDoc.update(_mapManufacturerToJson(manufacturer));

      // Instead of updating the products in Firebase, we only update
      // the local manufacturer list and product list in the Database singleton

      // Update manufacturer in the local list
      int manufacturerIndex = Database()
          .manufacturerList
          .indexWhere((m) => m.manufacturerID == manufacturer.manufacturerID);

      if (manufacturerIndex >= 0) {
        Database().manufacturerList[manufacturerIndex] = manufacturer;
      }

      // Update products in local list without changing them in Firebase
      for (int i = 0; i < Database().productList.length; i++) {
        if (Database().productList[i].manufacturer.manufacturerID ==
            manufacturer.manufacturerID) {
          Database().productList[i].manufacturer = manufacturer;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating manufacturer and products: $e');
      } // Lỗi khi cập nhật nhà sản xuất và sản phẩm
      rethrow;
    }
  }

  Future<void> updateUsername(String newUsername) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('No user logged in'); // Không có người dùng đăng nhập
      }

      // Update username in users collection
      await _firestore.collection('users').doc(user.uid).update({
        'username': newUsername,
      });

      // Get user role to determine if additional updates are needed
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final role = userDoc.data()?['role'] as String?;

      // Update name in respective collection based on role
      if (role == 'customer') {
        final customerDoc = await _firestore
            .collection('customers')
            .where('email', isEqualTo: user.email)
            .get();
        if (customerDoc.docs.isNotEmpty) {
          await _firestore
              .collection('customers')
              .doc(customerDoc.docs.first.id)
              .update({'customerName': newUsername});
        }
      } else if (role == 'admin' || role == 'employee') {
        final employeeDoc = await _firestore
            .collection('employees')
            .where('email', isEqualTo: user.email)
            .get();
        if (employeeDoc.docs.isNotEmpty) {
          await _firestore
              .collection('employees')
              .doc(employeeDoc.docs.first.id)
              .update({'employeeName': newUsername});
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating username: $e');
      } // Lỗi khi cập nhật tên người dùng
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Error sending password reset email: $e');
      } // Lỗi khi gửi email đặt lại mật khẩu
      rethrow;
    }
  }

  Future<void> updateUserProfile(String userID, String newUsername) async {
    try {
      // Cập nhật thông tin trong collection users
      await FirebaseFirestore.instance.collection('users').doc(userID).update({
        'username': newUsername,
      });

      // Kiểm tra và cập nhật thông tin trong collection customers nếu là khách hàng
      QuerySnapshot customerSnapshot = await FirebaseFirestore.instance
          .collection('customers')
          .where('customerID', isEqualTo: userID)
          .get();

      if (customerSnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(customerSnapshot.docs.first.id)
            .update({'customerName': newUsername});
      }

      // Kiểm tra và cập nhật thông tin trong collection employees nếu là nhân viên
      QuerySnapshot employeeSnapshot = await FirebaseFirestore.instance
          .collection('employees')
          .where('employeeID', isEqualTo: userID)
          .get();

      if (employeeSnapshot.docs.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('employees')
            .doc(employeeSnapshot.docs.first.id)
            .update({'employeeName': newUsername});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating user profile: $e');
      } // Lỗi khi cập nhật thông tin người dùng
      rethrow;
    }
  }

  Future<String> getCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return 'employee';

      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return 'employee';

      return userDoc.data()?['role'] ?? 'employee';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user role: $e');
      } // Lỗi khi lấy vai trò người dùng
      return 'employee'; // Default role if there's an error
    }
  }

  Future<String> generateSalesInvoiceID() async {
    final salesRef = _firestore.collection('sales');
    final docRef = salesRef.doc();
    return docRef.id;
  }

  Future<void> updateSalesInvoice(SalesInvoice invoice) async {
    try {
      // Load previous status and existing details to support stock/sales reconciliation
      final prevDoc = await FirebaseFirestore.instance
          .collection('sales_invoices')
          .doc(invoice.salesInvoiceID)
          .get();

      final String prevStatusName =
          (prevDoc.data()?['salesStatus'] as String?) ?? '';
      SalesStatus? prevStatus;
      try {
        prevStatus = SalesStatusExtension.fromName(prevStatusName);
      } catch (_) {
        prevStatus = null;
      }

      final existingDetailsSnapshot = await FirebaseFirestore.instance
          .collection('sales_invoice_details')
          .where('salesInvoiceID', isEqualTo: invoice.salesInvoiceID)
          .get();
      final batch = FirebaseFirestore.instance.batch();

      final docRef = FirebaseFirestore.instance
          .collection('sales_invoices')
          .doc(invoice.salesInvoiceID);

      // Update with only the addressID
      batch.update(docRef, {
        'customerID': invoice.customerID,
        'customerName': invoice.customerName,
        'address': invoice.address.addressID, // Just store the ID
        'paymentStatus': invoice.paymentStatus.getName(),
        'salesStatus': invoice.salesStatus.getName(),
        'totalPrice': invoice.totalPrice,
        'date': invoice.date,
      });

      // Update details...
      for (var doc in existingDetailsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      for (final detail in invoice.details) {
        final detailRef = FirebaseFirestore.instance
            .collection('sales_invoice_details')
            .doc();

        batch.set(detailRef, {
          'salesInvoiceDetailID': detailRef.id,
          'salesInvoiceID': invoice.salesInvoiceID,
          'productID': detail.productID,
          'productName': detail.productName,
          'quantity': detail.quantity,
          'sellingPrice': detail.sellingPrice,
          'subtotal': detail.subtotal,
        });
      }

      await batch.commit();

      // If status edited to cancelled from a non-cancelled state, return stock and sales
      if (invoice.salesStatus == SalesStatus.cancelled &&
          prevStatus != SalesStatus.cancelled) {
        for (final doc in existingDetailsSnapshot.docs) {
          final data = doc.data();
          final String productID = data['productID'] as String;
          final int qty = (data['quantity'] as num?)?.toInt() ?? 0;
          try {
            await updateProductStockAndSales(productID, qty, -qty);
          } catch (_) {
            // continue other items even if one fails
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating sales invoice: $e');
      } // Lỗi khi cập nhật hóa đơn bán hàng
      rethrow;
    }
  }

  Future<List<Voucher>> getVouchers() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('vouchers').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['voucherID'] = doc.id;

        // Convert date strings to DateTime objects and ensure startTime is never null
        if (data['startTime'] is String) {
          data['startTime'] = DateTime.parse(data['startTime']);
        } else if (data['startTime'] == null) {
          data['startTime'] = DateTime.now();
        }

        // Handle endTime for vouchers with end time
        if (data['hasEndTime'] == true) {
          if (data['endTime'] is String) {
            data['endTime'] = DateTime.parse(data['endTime']);
          } else if (data['endTime'] == null) {
            data['endTime'] = DateTime.now()
                .add(const Duration(days: 30)); // Default to 30 days from now
          }
        }

        // Handle required fields with default values
        data['voucherName'] ??= '';
        data['discountValue'] ??= 0.0;
        data['minimumPurchase'] ??= 0;
        data['maxUsagePerPerson'] ??= 1;
        data['isVisible'] ??= true;
        data['isEnabled'] ??= true;
        data['enDescription'] ??= '';
        data['viDescription'] ??= '';
        data['isPercentage'] ??= false;
        data['hasEndTime'] ??= false;
        data['isLimited'] ??= false;

        // Handle fields for limited vouchers
        if (data['isLimited'] == true) {
          data['maximumUsage'] ??= 0;
          data['usageLeft'] ??= 0;
        }

        // Handle fields for percentage vouchers
        if (data['isPercentage'] == true) {
          data['maximumDiscountValue'] ??= 0;
        }

        // Ensure all DateTime fields are properly set
        if (data['startTime'] is! DateTime) {
          data['startTime'] = DateTime.now();
        }
        if (data['hasEndTime'] == true && data['endTime'] is! DateTime) {
          data['endTime'] = DateTime.now().add(const Duration(days: 30));
        }

        return VoucherFactory.fromMap(doc.id, data);
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting vouchers: $e');
      }
      rethrow;
    }
  }

  Future<List<OwnedVoucher>> getOwnedVouchers(String customerID) async {
    final QuerySnapshot snapshot = await _firestore
        .collection('owned_vouchers')
        .where('customerID', isEqualTo: customerID)
        .get();
    return snapshot.docs.map((doc) {
      return OwnedVoucher.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    }).toList();
  }

  Future<void> addVoucher(Voucher voucher) async {
    try {
      final collectionRef = _firestore.collection('vouchers');
      final docRef = await collectionRef.add(voucherToMap(voucher));
      await docRef.update({'voucherID': docRef.id});
    } catch (e) {
      if (kDebugMode) {
        print('Error adding voucher: $e');
      }
      rethrow;
    }
  }

  static Map<String, dynamic> voucherToMap(Voucher voucher) {
    final map = {
      'voucherID': voucher.voucherID,
      'voucherName': voucher.voucherName,
      'enDescription': voucher.enDescription,
      'viDescription': voucher.viDescription,
      'discountValue': voucher.discountValue,
      'minimumPurchase': voucher.minimumPurchase,
      'isPercentage': voucher.isPercentage,
      'isLimited': voucher.isLimited,
      'isVisible': voucher.isVisible,
      'isEnabled': voucher.isEnabled,
      'startTime': voucher.startTime.toIso8601String(),
      'hasEndTime': voucher.hasEndTime,
      'maxUsagePerPerson': voucher.maxUsagePerPerson,
    };

    if (voucher.isPercentage) {
      final dyn = voucher as dynamic;
      map['maximumDiscountValue'] =
          dyn.maximumDiscountValue ?? voucher.discountValue;
    }

    if (voucher.isLimited) {
      final dyn = voucher as dynamic;
      map['maximumUsage'] = dyn.maximumUsage ?? 0;
      map['usageLeft'] = dyn.usageLeft ?? 0;
    }

    if (voucher.hasEndTime) {
      map['endTime'] = (voucher as EndTimeInterface).endTime.toIso8601String();
    }

    return map;
  }

  Future<void> updateVoucher(Voucher voucher) async {
    try {
      if (voucher.voucherID == null) {
        throw Exception('voucherID is required for update');
      }
      final docRef = _firestore.collection('vouchers').doc(voucher.voucherID);
      await docRef.update(voucherToMap(voucher));
    } catch (e) {
      if (kDebugMode) {
        print('Error updating voucher: $e');
      }
      rethrow;
    }
  }

  Future<List<Chat>> getAllUsersAdminMessages() async {
    try {
      final List<Chat> allAdminMessages = [];

      // Get all users collection
      final usersSnapshot = await _firestore.collection('chats').get();

      for (var userDoc in usersSnapshot.docs) {
        // final userId = userDoc.id;
        final data = userDoc.data();

        // Get messages array from user document
        final messages = (data['messages'] as List<dynamic>?) ?? [];

        // Filter admin messages
        final adminMessages = messages
            .where((msg) =>
                msg['receiverId'] == 'admin' && msg['isAIMode'] == false)
            .map((msg) => Chat.fromMap(msg as Map<String, dynamic>))
            .toList();

        allAdminMessages.addAll(adminMessages);
      }

      // Sort all messages by timestamp
      allAdminMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return allAdminMessages;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting all users admin messages: $e');
      }
      return [];
    }
  }

  Future<Map<String, List<Chat>>> getAllUserMessages(String userId) async {
    try {
      final Map<String, List<Chat>> userMessages = {};

      // Get user's document
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final messages = (data['messages'] as List<dynamic>?) ?? [];

        // Group messages by conversation partner
        for (var msg in messages) {
          final message = Chat.fromMap(msg as Map<String, dynamic>);
          final partnerId = message.senderId == userId
              ? message.receiverId
              : message.senderId;

          if (!userMessages.containsKey(partnerId)) {
            userMessages[partnerId] = [];
          }
          userMessages[partnerId]!.add(message);
        }

        // Sort messages in each conversation by timestamp
        userMessages.forEach((key, value) {
          value.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        });
      }

      return userMessages;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user messages: $e');
      }
      return {};
    }
  }

  Future<void> sendAdminMessage(String userId, Chat chat) async {
    try {
      // Add message to user's messages array
      await _firestore.collection('chats').doc(userId).update({
        'messages': FieldValue.arrayUnion([chat.toMap()])
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error sending admin message: $e');
      }
      rethrow;
    }
  }

  Future<void> sendUserChat(
      String senderId, String receiverId, Chat chat) async {
    try {
      // Update sender's messages array
      await _firestore.collection('chats').doc(senderId).update({
        'messages': FieldValue.arrayUnion([chat.toMap()])
      });

      // Update receiver's messages array
      await _firestore.collection('chats').doc(receiverId).update({
        'messages': FieldValue.arrayUnion([chat.toMap()])
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error sending user chat: $e');
      }
      rethrow;
    }
  }

  Future<void> markAdminMessageAsRead(String userId, String messageId) async {
    try {
      final userDoc = await _firestore.collection('chats').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final messages =
            List<Map<String, dynamic>>.from(data['messages'] ?? []);

        // Find and update the specific message
        for (var i = 0; i < messages.length; i++) {
          if (messages[i]['messageId'] == messageId) {
            messages[i]['isRead'] = true;
            break;
          }
        }

        // Update the document with modified messages
        await _firestore
            .collection('chats')
            .doc(userId)
            .update({'messages': messages});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking admin message as read: $e');
      }
      rethrow;
    }
  }

  Future<void> markUserChatAsRead(
      String userId, String senderId, String messageId) async {
    try {
      final userDoc = await _firestore.collection('chats').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final messages =
            List<Map<String, dynamic>>.from(data['messages'] ?? []);

        // Find and update the specific message
        for (var i = 0; i < messages.length; i++) {
          if (messages[i]['messageId'] == messageId) {
            messages[i]['isRead'] = true;
            break;
          }
        }

        // Update the document with modified messages
        await _firestore
            .collection('chats')
            .doc(userId)
            .update({'messages': messages});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error marking user chat as read: $e');
      }
      rethrow;
    }
  }

  Future<int> getUnreadChatsCount() async {
    try {
      final userId = currentUserId;
      if (userId == null) return 0;

      final userDoc = await _firestore.collection('chats').doc(userId).get();
      if (!userDoc.exists) return 0;

      final data = userDoc.data() as Map<String, dynamic>;
      final messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);

      // Count unread messages where user is the receiver
      return messages
          .where(
              (msg) => msg['receiverId'] == 'admin' && msg['isRead'] == false)
          .length;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting unread chats count: $e');
      }
      return 0;
    }
  }

  Future<void> changeVoucherStatus(String voucherId, bool status) async {
    try {
      await FirebaseFirestore.instance
          .collection('vouchers')
          .doc(voucherId)
          .update({'isEnabled': status});

      List<Voucher> vouchers = await getVouchers();
      Database().updateVoucherList(vouchers);
    } catch (e) {
      if (kDebugMode) {
        print('Error changing product status: $e');
      } // Lỗi khi thay đổi trạng thái sản phẩm
      rethrow;
    }
  }

  Future<void> addOwnedVoucher(OwnedVoucher ownedVoucher) async {
    try {
      final collectionRef = _firestore.collection('owned_vouchers');
      final docRef = await collectionRef.add(ownedVoucher.toMap());
      await docRef.update({'ownedVoucherID': docRef.id});
    } catch (e) {
      if (kDebugMode) {
        print('Error adding owned voucher: $e');
      }
      rethrow;
    }
  }

  Future<Customer> getCustomerById(String customerId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(customerId)
          .get();
      if (!doc.exists) {
        throw Exception('Customer not found');
      }
      return Customer.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting customer by ID: $e');
      }
      rethrow;
    }
  }
}

Manufacturer _mapManufacturerFromJson(Map<String, dynamic> json) {
  return Manufacturer(
    manufacturerID: json['manufacturerID'] as String,
    manufacturerName: json['manufacturerName'] as String,
    status: _mapManufacturerStatus(json['status'] as String? ?? 'active'),
  );
}

Map<String, dynamic> _mapManufacturerToJson(Manufacturer manufacturer) {
  return {
    'manufacturerID': manufacturer.manufacturerID,
    'manufacturerName': manufacturer.manufacturerName,
    'status': manufacturer.status.toString().split('.').last,
  };
}

ManufacturerStatus _mapManufacturerStatus(String status) {
  switch (status.toLowerCase()) {
    case 'active':
      return ManufacturerStatus.active;
    case 'inactive':
      return ManufacturerStatus.inactive;
    default:
      return ManufacturerStatus.active;
  }
}
