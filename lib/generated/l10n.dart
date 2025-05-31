// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `GizmoGlobe`
  String get appTitle {
    return Intl.message('GizmoGlobe', name: 'appTitle', desc: '', args: []);
  }

  /// `Welcome back,`
  String get welcomeBack {
    return Intl.message(
      'Welcome back,',
      name: 'welcomeBack',
      desc: '',
      args: [],
    );
  }

  /// `Overview`
  String get overview {
    return Intl.message('Overview', name: 'overview', desc: '', args: []);
  }

  /// `Products`
  String get products {
    return Intl.message('Products', name: 'products', desc: '', args: []);
  }

  /// `Customers`
  String get customers {
    return Intl.message('Customers', name: 'customers', desc: '', args: []);
  }

  /// `Revenue`
  String get revenue {
    return Intl.message('Revenue', name: 'revenue', desc: '', args: []);
  }

  /// `Avg. Income`
  String get avgIncome {
    return Intl.message('Avg. Income', name: 'avgIncome', desc: '', args: []);
  }

  /// `Monthly Sales`
  String get monthlySales {
    return Intl.message(
      'Monthly Sales',
      name: 'monthlySales',
      desc: '',
      args: [],
    );
  }

  /// `Last 12 months`
  String get last12Months {
    return Intl.message(
      'Last 12 months',
      name: 'last12Months',
      desc: '',
      args: [],
    );
  }

  /// `Last 3 months`
  String get last3Months {
    return Intl.message(
      'Last 3 months',
      name: 'last3Months',
      desc: '',
      args: [],
    );
  }

  /// `New Incoming Invoice`
  String get newIncomingInvoice {
    return Intl.message(
      'New Incoming Invoice',
      name: 'newIncomingInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Select Manufacturer`
  String get selectManufacturer {
    return Intl.message(
      'Select Manufacturer',
      name: 'selectManufacturer',
      desc: '',
      args: [],
    );
  }

  /// `Add Product`
  String get addProduct {
    return Intl.message('Add Product', name: 'addProduct', desc: '', args: []);
  }

  /// `Invoice Details`
  String get invoiceDetails {
    return Intl.message(
      'Invoice Details',
      name: 'invoiceDetails',
      desc: '',
      args: [],
    );
  }

  /// `Import Price`
  String get importPrice {
    return Intl.message(
      'Import Price',
      name: 'importPrice',
      desc: '',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message('Quantity', name: 'quantity', desc: '', args: []);
  }

  /// `Total Price: `
  String get totalPrice {
    return Intl.message(
      'Total Price: ',
      name: 'totalPrice',
      desc: '',
      args: [],
    );
  }

  /// `Payment Status`
  String get paymentStatus {
    return Intl.message(
      'Payment Status',
      name: 'paymentStatus',
      desc: '',
      args: [],
    );
  }

  /// `Create Invoice`
  String get createInvoice {
    return Intl.message(
      'Create Invoice',
      name: 'createInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message('Cancel', name: 'cancel', desc: '', args: []);
  }

  /// `Add`
  String get add {
    return Intl.message('Add', name: 'add', desc: '', args: []);
  }

  /// `Edit Product Detail`
  String get editProductDetail {
    return Intl.message(
      'Edit Product Detail',
      name: 'editProductDetail',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message('Update', name: 'update', desc: '', args: []);
  }

  /// `Find incoming invoices...`
  String get searchIncomingInvoices {
    return Intl.message(
      'Find incoming invoices...',
      name: 'searchIncomingInvoices',
      desc: '',
      args: [],
    );
  }

  /// `No incoming invoices found`
  String get noIncomingInvoicesFound {
    return Intl.message(
      'No incoming invoices found',
      name: 'noIncomingInvoicesFound',
      desc: '',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message('View', name: 'view', desc: '', args: []);
  }

  /// `Edit Payment`
  String get editPayment {
    return Intl.message(
      'Edit Payment',
      name: 'editPayment',
      desc: '',
      args: [],
    );
  }

  /// `Only unpaid invoices can be marked as paid`
  String get onlyUnpaidCanBeMarkedPaid {
    return Intl.message(
      'Only unpaid invoices can be marked as paid',
      name: 'onlyUnpaidCanBeMarkedPaid',
      desc: '',
      args: [],
    );
  }

  /// `Mark this invoice as paid?`
  String get markAsPaidQuestion {
    return Intl.message(
      'Mark this invoice as paid?',
      name: 'markAsPaidQuestion',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message('Confirm', name: 'confirm', desc: '', args: []);
  }

  /// `Sort By`
  String get sortBy {
    return Intl.message('Sort By', name: 'sortBy', desc: '', args: []);
  }

  /// `Date (Newest First)`
  String get dateNewestFirst {
    return Intl.message(
      'Date (Newest First)',
      name: 'dateNewestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Date (Oldest First)`
  String get dateOldestFirst {
    return Intl.message(
      'Date (Oldest First)',
      name: 'dateOldestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Price (Highest First)`
  String get priceHighestFirst {
    return Intl.message(
      'Price (Highest First)',
      name: 'priceHighestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Price (Lowest First)`
  String get priceLowestFirst {
    return Intl.message(
      'Price (Lowest First)',
      name: 'priceLowestFirst',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred`
  String get errorOccurred {
    return Intl.message(
      'Error occurred',
      name: 'errorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `New Invoice`
  String get newInvoice {
    return Intl.message('New Invoice', name: 'newInvoice', desc: '', args: []);
  }

  /// `Customer Information`
  String get customerInformation {
    return Intl.message(
      'Customer Information',
      name: 'customerInformation',
      desc: '',
      args: [],
    );
  }

  /// `Select customer`
  String get selectCustomer {
    return Intl.message(
      'Select customer',
      name: 'selectCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Customer`
  String get customer {
    return Intl.message('Customer', name: 'customer', desc: '', args: []);
  }

  /// `Please select a customer`
  String get pleaseSelectCustomer {
    return Intl.message(
      'Please select a customer',
      name: 'pleaseSelectCustomer',
      desc: '',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message('Address', name: 'address', desc: '', args: []);
  }

  /// `Please select an address`
  String get pleaseSelectAddress {
    return Intl.message(
      'Please select an address',
      name: 'pleaseSelectAddress',
      desc: '',
      args: [],
    );
  }

  /// `Sales Status`
  String get salesStatus {
    return Intl.message(
      'Sales Status',
      name: 'salesStatus',
      desc: '',
      args: [],
    );
  }

  /// `Total Amount`
  String get totalAmount {
    return Intl.message(
      'Total Amount',
      name: 'totalAmount',
      desc: '',
      args: [],
    );
  }

  /// `No products added yet`
  String get noProductsAddedYet {
    return Intl.message(
      'No products added yet',
      name: 'noProductsAddedYet',
      desc: '',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message('Price', name: 'price', desc: '', args: []);
  }

  /// `Available stock`
  String get availableStock {
    return Intl.message(
      'Available stock',
      name: 'availableStock',
      desc: '',
      args: [],
    );
  }

  /// `Please select a customer first`
  String get pleaseSelectCustomerFirst {
    return Intl.message(
      'Please select a customer first',
      name: 'pleaseSelectCustomerFirst',
      desc: '',
      args: [],
    );
  }

  /// `Find sales invoices...`
  String get searchSalesInvoices {
    return Intl.message(
      'Find sales invoices...',
      name: 'searchSalesInvoices',
      desc: '',
      args: [],
    );
  }

  /// `No sales invoices found`
  String get noSalesInvoicesFound {
    return Intl.message(
      'No sales invoices found',
      name: 'noSalesInvoicesFound',
      desc: '',
      args: [],
    );
  }

  /// `Warranty #{id}`
  String warrantyReceipt(Object id) {
    return Intl.message(
      'Warranty #$id',
      name: 'warrantyReceipt',
      desc: '',
      args: [id],
    );
  }

  /// `Warranty Information`
  String get warrantyInformation {
    return Intl.message(
      'Warranty Information',
      name: 'warrantyInformation',
      desc: '',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message('Status', name: 'status', desc: '', args: []);
  }

  /// `Reason for Warranty`
  String get reasonForWarranty {
    return Intl.message(
      'Reason for Warranty',
      name: 'reasonForWarranty',
      desc: '',
      args: [],
    );
  }

  /// `Products Under Warranty`
  String get productsUnderWarranty {
    return Intl.message(
      'Products Under Warranty',
      name: 'productsUnderWarranty',
      desc: '',
      args: [],
    );
  }

  /// `Unknown Category`
  String get unknownCategory {
    return Intl.message(
      'Unknown Category',
      name: 'unknownCategory',
      desc: '',
      args: [],
    );
  }

  /// `Update Warranty Status`
  String get updateWarrantyStatus {
    return Intl.message(
      'Update Warranty Status',
      name: 'updateWarrantyStatus',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Status Update`
  String get confirmStatusUpdate {
    return Intl.message(
      'Confirm Status Update',
      name: 'confirmStatusUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to change the status to {status}?`
  String areYouSureChangeStatus(Object status) {
    return Intl.message(
      'Are you sure you want to change the status to $status?',
      name: 'areYouSureChangeStatus',
      desc: '',
      args: [status],
    );
  }

  /// `Save`
  String get save {
    return Intl.message('Save', name: 'save', desc: '', args: []);
  }

  /// `Update Status`
  String get updateStatus {
    return Intl.message(
      'Update Status',
      name: 'updateStatus',
      desc: '',
      args: [],
    );
  }

  /// `No sales invoices available`
  String get noSalesInvoicesAvailable {
    return Intl.message(
      'No sales invoices available',
      name: 'noSalesInvoicesAvailable',
      desc: '',
      args: [],
    );
  }

  /// `This customer has no eligible sales invoices for warranty claims.`
  String get noEligibleSalesInvoices {
    return Intl.message(
      'This customer has no eligible sales invoices for warranty claims.',
      name: 'noEligibleSalesInvoices',
      desc: '',
      args: [],
    );
  }

  /// `Please select a sales invoice`
  String get pleaseSelectSalesInvoice {
    return Intl.message(
      'Please select a sales invoice',
      name: 'pleaseSelectSalesInvoice',
      desc: '',
      args: [],
    );
  }

  /// `Reason for Warranty`
  String get reasonForWarrantyLabel {
    return Intl.message(
      'Reason for Warranty',
      name: 'reasonForWarrantyLabel',
      desc: '',
      args: [],
    );
  }

  /// `Select Products for Warranty`
  String get selectProductsForWarranty {
    return Intl.message(
      'Select Products for Warranty',
      name: 'selectProductsForWarranty',
      desc: '',
      args: [],
    );
  }

  /// `Warranty invoice created successfully`
  String get warrantyInvoiceCreated {
    return Intl.message(
      'Warranty invoice created successfully',
      name: 'warrantyInvoiceCreated',
      desc: '',
      args: [],
    );
  }

  /// `Error creating warranty invoice: {error}`
  String errorCreatingWarrantyInvoice(Object error) {
    return Intl.message(
      'Error creating warranty invoice: $error',
      name: 'errorCreatingWarrantyInvoice',
      desc: '',
      args: [error],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
