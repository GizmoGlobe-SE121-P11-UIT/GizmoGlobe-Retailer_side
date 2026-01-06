import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:gizmoglobe_client/enums/voucher_related/distribution_type.dart';
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
import '../../objects/product_related/product_image.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_invoice.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gizmoglobe_client/objects/invoice_related/warranty_invoice.dart';
import 'package:gizmoglobe_client/objects/chat_related/chat.dart';
import '../../objects/invoice_related/rating.dart';
import '../../objects/invoice_related/reply.dart';
import '../../objects/invoice_related/ratings_page.dart';

class Firebase {
  static final Firebase _firebase = Firebase._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  factory Firebase() {
    return _firebase;
  }

  Firebase._internal();

  String? get currentUserId => _auth.currentUser?.uid;

  Future<String> getCurrentUserRoleFromFirebase() async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('employees').doc(currentUserId).get();

      if (!userDoc.exists) return 'unknown';
      final data = userDoc.data() as Map<String, dynamic>?;
      final dynamic roleField = data?['role'];
      if (roleField == null) return 'unknown';

      return roleField is String ? roleField : roleField.toString();
    } catch (e) {
      return 'unknown';
    }
  }

  Future<List<Customer>> getCustomers() async {
    try {
      final QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('customers').get();

      return snapshot.docs.map((doc) {
        return Customer.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
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
          // Error processing product
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
          quantity: (data['quantity'] as num?)?.toInt() ?? 0,
          sellingPrice: (data['sellingPrice'] as num?)?.toInt() ?? 0,
          subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
        );
      }).toList();
    } catch (e) {
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

      // Product not found
      return {
        'productName': 'Unknown Product',
        'category': '',
        'manufacturer': '',
        'importPrice': 0,
        'sellingPrice': 0,
      };
    } catch (e) {
      return {
        'productName': 'Unknown Product',
        'category': '',
        'manufacturer': '',
        'importPrice': 0,
        'sellingPrice': 0,
      };
    }
  }

  Future<List<String>> getProductImages(String productID) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productID)
          .collection('images')
          .orderBy('position')
          .get();

      return snapshot.docs
          .map((doc) {
            final data = doc.data();
            final url = data['url'];
            if (url == null) return null;
            if (url is String) return url;
            return url.toString();
          })
          .whereType<String>()
          .where((url) => url.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Get product images with document IDs for editing
  Future<List<ProductImage>> getProductImagesWithDetails(
      String productID) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .doc(productID)
          .collection('images')
          .orderBy('position')
          .get();

      return snapshot.docs
          .map((doc) => ProductImage.fromMap(doc.id, doc.data()))
          .where((img) => img.url.isNotEmpty)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Save product images to subcollection (Create, Update, Delete)
  Future<void> saveProductImages(
      String productID, List<ProductImage> images) async {
    try {
      final batch = _firestore.batch();
      final imagesRef =
          _firestore.collection('products').doc(productID).collection('images');

      // Process deletions
      final imagesToDelete =
          images.where((img) => img.markedForDeletion && img.id != null);
      for (final img in imagesToDelete) {
        batch.delete(imagesRef.doc(img.id));
      }

      // Process updates and creates
      final activeImages = images.where((img) => !img.markedForDeletion);
      for (final img in activeImages) {
        if (img.id != null) {
          // Update existing
          batch.update(imagesRef.doc(img.id), img.toMap());
        } else {
          // Create new
          batch.set(imagesRef.doc(), img.toMap());
        }
      }

      await batch.commit();
    } catch (e) {
      rethrow;
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
          quantity: (detailData['quantity'] as num?)?.toInt() ?? 0,
          sellingPrice: (detailData['sellingPrice'] as num?)?.toInt() ?? 0,
          subtotal: (detailData['subtotal'] as num?)?.toDouble() ?? 0.0,
        ));
      }

      invoice.details = details;
      return invoice;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSalesInvoiceDetail(SalesInvoiceDetail detail) async {
    try {
      // Create a new document reference if needed
      final detailRef = _firestore.collection('sales_invoice_details').doc();

      // Update the detail document
      await detailRef.set(detail.toJson());

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
      rethrow;
    }
  }

  Future<void> updateProductStock(String productID, int stockChange) async {
    try {
      // Find the document by productID attribute
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('productID', isEqualTo: productID)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Product not found'); // Không tìm thấy sản phẩm
      }

      final docRef = querySnapshot.docs.first.reference;
      final doc = querySnapshot.docs.first;

      // Đảm bảo currentStock không null
      final currentStock = doc.data()['stock'] as int? ?? 0;

      await docRef.update({'stock': currentStock + stockChange});
    } catch (e) {
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
      rethrow;
    }
  }

  Future<void> changeProductStatus(
      String productId, ProductStatusEnum status) async {
    try {
      // Find the document by productID attribute
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('productID', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Product not found with productID: $productId');
      }

      final docRef = querySnapshot.docs.first.reference;
      await docRef.update({'status': status.getName()});

      List<Product> products = await getProducts();
      Database().updateProductList(products);
    } catch (e) {
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
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final collectionRef = _firestore.collection('products');
      final docRef = await collectionRef.add(productToJson(product));
      await docRef.update({'productID': docRef.id});
      List<Product> products = await getProducts();
      Database().updateProductList(products);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProductStockAndSales(
      String productID, int stockChange, int salesChange) async {
    try {
      // Find the document by productID attribute
      final querySnapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('productID', isEqualTo: productID)
          .get();

      if (querySnapshot.docs.isEmpty) {
        throw Exception('Product not found'); // Không tìm thấy sản phẩm
      }

      final docRef = querySnapshot.docs.first.reference;
      final doc = querySnapshot.docs.first;

      // Đảm bảo các giá trị không null
      final currentStock = doc.data()['stock'] as int? ?? 0;
      final currentSales = doc.data()['sales'] as int? ?? 0;

      // Cập nhật cả stock và sales
      await docRef.update({
        'stock': currentStock + stockChange,
        'sales': currentSales + salesChange
      });

      // Cập nhật danh sách sản phẩm trong Database
      List<Product> products = await getProducts();
      Database().updateProductList(products);
    } catch (e) {
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
      rethrow;
    }
  }

  Future<Product?> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();

      if (!doc.exists) {
        return null;
      }

      final data = Map<String, dynamic>.from(doc.data()!);
      final product = ProductFactory.createProduct(data);
      return product;
    } catch (e) {
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
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
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
        data['discountValue'] ??= 0;
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

        final List<String> intKeys = [
          'discountValue',
          'minimumPurchase',
          'maxUsagePerPerson',
          'maximumUsage',
          'usageLeft',
          'maximumDiscountValue',
          'redeemPrice',
        ];
        for (final key in intKeys) {
          final v = data[key];
          if (v == null) continue;
          if (v is num) {
            data[key] = v.toInt();
          } else if (v is String) {
            final parsed = int.tryParse(v);
            if (parsed != null) data[key] = parsed;
          }
        }

        return VoucherFactory.fromMap(doc.id, data);
      }).toList();
    } catch (e) {
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
      'redeemPrice': voucher.redeemPrice,
      'distributionType': voucher.distributionType.name,
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

    if (voucher.distributionType == DistributionType.rewards) {
      map['maxUsagePerPerson'] = 1;
    } else {
      map['redeemPrice'] = 0;
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
      rethrow;
    }
  }

  Future<void> addOwnedVoucher(OwnedVoucher ownedVoucher) async {
    try {
      final collectionRef = _firestore.collection('owned_vouchers');
      final docRef = await collectionRef.add(ownedVoucher.toMap());
      await docRef.update({'ownedVoucherID': docRef.id});
    } catch (e) {
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
      rethrow;
    }
  }

  Future<List<Rating>> getRatings() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('order_ratings').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Rating.fromMap(doc.id, data);
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Rating>> getRatingsByProductWithUsername(String productId) async {
    try {
      if (productId.isEmpty) return [];

      // Avoid server-side ordering that requires a composite index.
      // Fetch ratings for the product and sort locally by timeSent descending.
      final QuerySnapshot snapshot = await _firestore
          .collection('order_ratings')
          .where('productID', isEqualTo: productId)
          .get();

      final List<Rating> ratings = [];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final rating = Rating.fromMap(doc.id, data);

        // Try to fetch username from customers collection using userID
        try {
          if (rating.userID.isNotEmpty) {
            final userDoc = await _firestore
                .collection('customers')
                .doc(rating.userID)
                .get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              final customerName = (userData?['customerName'] as String?) ?? '';
              if (customerName.isNotEmpty) {
                rating.username = customerName;
              }
            }
          }
        } catch (e) {
          // Could not fetch username for rating
        }

        ratings.add(rating);
      }

      // Sort ratings in-memory by timeSent descending (newest first)
      ratings.sort((a, b) => b.timeSent.compareTo(a.timeSent));

      return ratings;
    } catch (e) {
      rethrow;
    }
  }

  Future<RatingsPage> getRatingsPageByProduct(String productId,
      {DocumentSnapshot? startAfter, int limit = 5}) async {
    try {
      if (productId.isEmpty) {
        return RatingsPage(ratings: [], lastDocument: null, hasMore: false);
      }

      Query query = _firestore
          .collection('order_ratings')
          .where('productID', isEqualTo: productId)
          .orderBy('timeSent', descending: true)
          .limit(limit);

      if (startAfter != null) query = query.startAfterDocument(startAfter);

      final QuerySnapshot snapshot = await query.get();

      final List<Rating> ratings = [];
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final rating = Rating.fromMap(doc.id, data);

        // attach username if possible
        try {
          if (rating.userID.isNotEmpty) {
            final userDoc = await _firestore
                .collection('customers')
                .doc(rating.userID)
                .get();
            if (userDoc.exists) {
              final userData = userDoc.data();
              final customerName = (userData?['customerName'] as String?) ?? '';
              if (customerName.isNotEmpty) rating.username = customerName;
            }
          }
        } catch (_) {}

        ratings.add(rating);
      }

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      final hasMore = snapshot.docs.length == limit;

      return RatingsPage(
          ratings: ratings, lastDocument: lastDoc, hasMore: hasMore);
    } catch (e) {
      rethrow; // let caller handle fallback
    }
  }

  Future<void> replyToRating(
      {required String ratingId, required Reply reply}) async {
    try {
      if (ratingId.isEmpty) throw Exception('ratingId is required');

      final Map<String, dynamic> replyMap = reply.toMap();

      await _firestore.collection('order_ratings').doc(ratingId).update({
        'reply': replyMap,
        'replyUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAverageRatingForProduct(
      String productId) async {
    try {
      if (productId.isEmpty) return {'average': 0.0, 'count': 0, 'sum': 0};

      final QuerySnapshot snapshot = await _firestore
          .collection('order_ratings')
          .where('productID', isEqualTo: productId)
          .get();

      int sum = 0;
      int count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final ratingVal = data['rating'];
        int parsed = 0;
        if (ratingVal is int) {
          parsed = ratingVal;
        } else if (ratingVal is num) {
          parsed = ratingVal.toInt();
        } else if (ratingVal is String) {
          parsed = int.tryParse(ratingVal) ?? 0;
        } else {
          parsed = 0;
        }
        sum += parsed;
        count += 1;
      }

      final average = (count > 0) ? (sum / count) : 0.0;
      return {'average': average, 'count': count, 'sum': sum};
    } catch (e) {
      return {'average': 0.0, 'count': 0, 'sum': 0};
    }
  }

  /// Get aggregated product rating from Cloud Functions aggregation
  /// Returns null if no aggregated data exists for this product
  Future<Map<String, dynamic>?> getAggregatedProductRating(
      String productId) async {
    try {
      if (productId.isEmpty) return null;

      final doc = await _firestore
          .collection('aggregations')
          .doc('productRatings')
          .get();

      if (!doc.exists) return null;

      final data = doc.data();
      final products = data?['products'] as Map<String, dynamic>?;

      if (products == null || !products.containsKey(productId)) {
        return null;
      }

      final productRating = products[productId] as Map<String, dynamic>?;
      if (productRating == null) return null;

      return {
        'avgRating': productRating['avgRating'] ?? 0.0,
        'ratingCount': productRating['ratingCount'] ?? 0,
        'lastUpdated': productRating['lastUpdated'],
      };
    } catch (e) {
      return null;
    }
  }

  /// Get precomputed dashboard stats from Cloud Functions aggregation.
  /// Returns a map with: totalRevenue, totalOrders, avgOrderValue, monthlySales.
  /// Falls back to null if document doesn't exist (Cloud Function not deployed yet).
  Future<Map<String, dynamic>?> getDashboardStats() async {
    try {
      final doc =
          await _firestore.collection('aggregations').doc('dashboard').get();
      if (!doc.exists) {
        return null;
      }
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// Manually trigger recalculation of product counts by category.
  /// This calls the recalculateProductCounts Cloud Function.
  Future<Map<String, dynamic>> recalculateProductCounts() async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('recalculateProductCounts');
      final result = await callable.call();
      return result.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  /// Get precomputed product counts by category from Cloud Functions aggregation.
  /// Returns a map with: categoryCounts, totalProducts.
  /// Falls back to null if document doesn't exist (Cloud Function not deployed yet).
  Future<Map<String, dynamic>?> getProductCounts() async {
    try {
      final doc = await _firestore
          .collection('aggregations')
          .doc('productCounts')
          .get();
      if (!doc.exists) {
        return null;
      }
      return doc.data();
    } catch (e) {
      return null;
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
