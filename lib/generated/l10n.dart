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
    return Intl.message(
      'GizmoGlobe',
      name: 'appTitle',
      desc: 'The title of the application.',
      args: [],
    );
  }

  /// `Welcome back,`
  String get welcomeBack {
    return Intl.message(
      'Welcome back,',
      name: 'welcomeBack',
      desc: 'Welcome message for returning users.',
      args: [],
    );
  }

  /// `Overview`
  String get overview {
    return Intl.message(
      'Overview',
      name: 'overview',
      desc: 'Overview section title.',
      args: [],
    );
  }

  /// `Products`
  String get products {
    return Intl.message(
      'Products',
      name: 'products',
      desc: 'Products section title.',
      args: [],
    );
  }

  /// `Customers`
  String get customers {
    return Intl.message(
      'Customers',
      name: 'customers',
      desc: 'Customers section title.',
      args: [],
    );
  }

  /// `Revenue`
  String get revenue {
    return Intl.message(
      'Revenue',
      name: 'revenue',
      desc: 'Revenue section title.',
      args: [],
    );
  }

  /// `Avg. Income`
  String get avgIncome {
    return Intl.message(
      'Avg. Income',
      name: 'avgIncome',
      desc: 'Average income label.',
      args: [],
    );
  }

  /// `Monthly Sales`
  String get monthlySales {
    return Intl.message(
      'Monthly Sales',
      name: 'monthlySales',
      desc: 'Monthly sales label.',
      args: [],
    );
  }

  /// `Last 12 months`
  String get last12Months {
    return Intl.message(
      'Last 12 months',
      name: 'last12Months',
      desc: 'Label for last 12 months.',
      args: [],
    );
  }

  /// `Last 3 months`
  String get last3Months {
    return Intl.message(
      'Last 3 months',
      name: 'last3Months',
      desc: 'Label for last 3 months.',
      args: [],
    );
  }

  /// `New Incoming Invoice`
  String get newIncomingInvoice {
    return Intl.message(
      'New Incoming Invoice',
      name: 'newIncomingInvoice',
      desc: 'Button or title for creating a new incoming invoice.',
      args: [],
    );
  }

  /// `Select Manufacturer`
  String get selectManufacturer {
    return Intl.message(
      'Select Manufacturer',
      name: 'selectManufacturer',
      desc: 'Prompt to select a manufacturer.',
      args: [],
    );
  }

  /// `Add Product`
  String get addProduct {
    return Intl.message(
      'Add Product',
      name: 'addProduct',
      desc: 'Button or label to add a product.',
      args: [],
    );
  }

  /// `Invoice Details`
  String get invoiceDetails {
    return Intl.message(
      'Invoice Details',
      name: 'invoiceDetails',
      desc: 'Section title for invoice details.',
      args: [],
    );
  }

  /// `Import Price`
  String get importPrice {
    return Intl.message(
      'Import Price',
      name: 'importPrice',
      desc: 'Label for import price.',
      args: [],
    );
  }

  /// `Quantity`
  String get quantity {
    return Intl.message(
      'Quantity',
      name: 'quantity',
      desc: 'Label for quantity.',
      args: [],
    );
  }

  /// `Total Price: `
  String get totalPrice {
    return Intl.message(
      'Total Price: ',
      name: 'totalPrice',
      desc: 'Label for total price.',
      args: [],
    );
  }

  /// `Payment Status`
  String get paymentStatus {
    return Intl.message(
      'Payment Status',
      name: 'paymentStatus',
      desc: 'Label for payment status.',
      args: [],
    );
  }

  /// `Create Invoice`
  String get createInvoice {
    return Intl.message(
      'Create Invoice',
      name: 'createInvoice',
      desc: 'Button or title for creating an invoice.',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: 'Cancel button label.',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: 'Add button label.',
      args: [],
    );
  }

  /// `Edit Product Detail`
  String get editProductDetail {
    return Intl.message(
      'Edit Product Detail',
      name: 'editProductDetail',
      desc: 'Button or title for editing product details.',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: 'Update button label.',
      args: [],
    );
  }

  /// `Find incoming invoices...`
  String get searchIncomingInvoices {
    return Intl.message(
      'Find incoming invoices...',
      name: 'searchIncomingInvoices',
      desc: 'Search field placeholder for incoming invoices.',
      args: [],
    );
  }

  /// `No incoming invoices found`
  String get noIncomingInvoicesFound {
    return Intl.message(
      'No incoming invoices found',
      name: 'noIncomingInvoicesFound',
      desc: 'Message when no incoming invoices are found.',
      args: [],
    );
  }

  /// `View`
  String get view {
    return Intl.message(
      'View',
      name: 'view',
      desc: 'View button label.',
      args: [],
    );
  }

  /// `Edit Payment`
  String get editPayment {
    return Intl.message(
      'Edit Payment',
      name: 'editPayment',
      desc: 'Button or title for editing payment.',
      args: [],
    );
  }

  /// `Only unpaid invoices can be marked as paid`
  String get onlyUnpaidCanBeMarkedPaid {
    return Intl.message(
      'Only unpaid invoices can be marked as paid',
      name: 'onlyUnpaidCanBeMarkedPaid',
      desc: 'Message explaining only unpaid invoices can be marked as paid.',
      args: [],
    );
  }

  /// `Mark this invoice as paid?`
  String get markAsPaidQuestion {
    return Intl.message(
      'Mark this invoice as paid?',
      name: 'markAsPaidQuestion',
      desc: 'Prompt to mark invoice as paid.',
      args: [],
    );
  }

  /// `OK`
  String get confirm {
    return Intl.message(
      'OK',
      name: 'confirm',
      desc: 'Confirm button label.',
      args: [],
    );
  }

  /// `Sort By`
  String get sortBy {
    return Intl.message(
      'Sort By',
      name: 'sortBy',
      desc: 'Label for sort by options.',
      args: [],
    );
  }

  /// `Date (Newest First)`
  String get dateNewestFirst {
    return Intl.message(
      'Date (Newest First)',
      name: 'dateNewestFirst',
      desc: 'Sort option for newest date first.',
      args: [],
    );
  }

  /// `Date (Oldest First)`
  String get dateOldestFirst {
    return Intl.message(
      'Date (Oldest First)',
      name: 'dateOldestFirst',
      desc: 'Sort option for oldest date first.',
      args: [],
    );
  }

  /// `Price (Highest First)`
  String get priceHighestFirst {
    return Intl.message(
      'Price (Highest First)',
      name: 'priceHighestFirst',
      desc: 'Sort option for highest price first.',
      args: [],
    );
  }

  /// `Price (Lowest First)`
  String get priceLowestFirst {
    return Intl.message(
      'Price (Lowest First)',
      name: 'priceLowestFirst',
      desc: 'Sort option for lowest price first.',
      args: [],
    );
  }

  /// `Error occurred`
  String get errorOccurred {
    return Intl.message(
      'Error occurred',
      name: 'errorOccurred',
      desc: 'Generic error message.',
      args: [],
    );
  }

  /// `New Invoice`
  String get newInvoice {
    return Intl.message(
      'New Invoice',
      name: 'newInvoice',
      desc: 'Button or title for new invoice.',
      args: [],
    );
  }

  /// `Customer Information`
  String get customerInformation {
    return Intl.message(
      'Customer Information',
      name: 'customerInformation',
      desc: 'Section title for customer information.',
      args: [],
    );
  }

  /// `Select customer`
  String get selectCustomer {
    return Intl.message(
      'Select customer',
      name: 'selectCustomer',
      desc: 'Prompt to select a customer.',
      args: [],
    );
  }

  /// `Customer`
  String get customer {
    return Intl.message(
      'Customer',
      name: 'customer',
      desc: 'Label for customer.',
      args: [],
    );
  }

  /// `Please select a customer`
  String get pleaseSelectCustomer {
    return Intl.message(
      'Please select a customer',
      name: 'pleaseSelectCustomer',
      desc: 'Validation message to select a customer.',
      args: [],
    );
  }

  /// `Address`
  String get address {
    return Intl.message(
      'Address',
      name: 'address',
      desc: 'Label for address.',
      args: [],
    );
  }

  /// `Please select an address`
  String get pleaseSelectAddress {
    return Intl.message(
      'Please select an address',
      name: 'pleaseSelectAddress',
      desc: 'Validation message to select an address.',
      args: [],
    );
  }

  /// `Sales Status`
  String get salesStatus {
    return Intl.message(
      'Sales Status',
      name: 'salesStatus',
      desc: 'Label for sales status.',
      args: [],
    );
  }

  /// `Total Amount`
  String get totalAmount {
    return Intl.message(
      'Total Amount',
      name: 'totalAmount',
      desc: 'Label for total amount.',
      args: [],
    );
  }

  /// `No products added yet`
  String get noProductsAddedYet {
    return Intl.message(
      'No products added yet',
      name: 'noProductsAddedYet',
      desc: 'Message when no products have been added yet.',
      args: [],
    );
  }

  /// `Price`
  String get price {
    return Intl.message(
      'Price',
      name: 'price',
      desc: 'Label for price field.',
      args: [],
    );
  }

  /// `Available stock`
  String get availableStock {
    return Intl.message(
      'Available stock',
      name: 'availableStock',
      desc: 'Label for available stock.',
      args: [],
    );
  }

  /// `Please select a customer first`
  String get pleaseSelectCustomerFirst {
    return Intl.message(
      'Please select a customer first',
      name: 'pleaseSelectCustomerFirst',
      desc: 'Validation message to select a customer first.',
      args: [],
    );
  }

  /// `Find sales invoices...`
  String get searchSalesInvoices {
    return Intl.message(
      'Find sales invoices...',
      name: 'searchSalesInvoices',
      desc: 'Search field placeholder for sales invoices.',
      args: [],
    );
  }

  /// `No sales invoices found`
  String get noSalesInvoicesFound {
    return Intl.message(
      'No sales invoices found',
      name: 'noSalesInvoicesFound',
      desc: 'Message when no sales invoices are found.',
      args: [],
    );
  }

  /// `Warranty #{id}`
  String warrantyReceipt(String id) {
    return Intl.message(
      'Warranty #$id',
      name: 'warrantyReceipt',
      desc: 'Label for warranty receipt with id placeholder.',
      args: [id],
    );
  }

  /// `Warranty Information`
  String get warrantyInformation {
    return Intl.message(
      'Warranty Information',
      name: 'warrantyInformation',
      desc: 'Section title for warranty information.',
      args: [],
    );
  }

  /// `Status`
  String get status {
    return Intl.message(
      'Status',
      name: 'status',
      desc: 'Label for status toggle.',
      args: [],
    );
  }

  /// `Reason for Warranty`
  String get reasonForWarranty {
    return Intl.message(
      'Reason for Warranty',
      name: 'reasonForWarranty',
      desc: 'Label for reason for warranty.',
      args: [],
    );
  }

  /// `Products Under Warranty`
  String get productsUnderWarranty {
    return Intl.message(
      'Products Under Warranty',
      name: 'productsUnderWarranty',
      desc: 'Label for products under warranty.',
      args: [],
    );
  }

  /// `Unknown Category`
  String get unknownCategory {
    return Intl.message(
      'Unknown Category',
      name: 'unknownCategory',
      desc: 'Label for unknown category.',
      args: [],
    );
  }

  /// `Update Warranty Status`
  String get updateWarrantyStatus {
    return Intl.message(
      'Update Warranty Status',
      name: 'updateWarrantyStatus',
      desc: 'Button or title for updating warranty status.',
      args: [],
    );
  }

  /// `Confirm Status Update`
  String get confirmStatusUpdate {
    return Intl.message(
      'Confirm Status Update',
      name: 'confirmStatusUpdate',
      desc: 'Prompt to confirm status update.',
      args: [],
    );
  }

  /// `Are you sure you want to change the status to {status}?`
  String areYouSureChangeStatus(String status) {
    return Intl.message(
      'Are you sure you want to change the status to $status?',
      name: 'areYouSureChangeStatus',
      desc: 'Prompt to confirm changing status with status placeholder.',
      args: [status],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: 'Save button label.',
      args: [],
    );
  }

  /// `Update Status`
  String get updateStatus {
    return Intl.message(
      'Update Status',
      name: 'updateStatus',
      desc: 'Button or title for updating status.',
      args: [],
    );
  }

  /// `No sales invoices available`
  String get noSalesInvoicesAvailable {
    return Intl.message(
      'No sales invoices available',
      name: 'noSalesInvoicesAvailable',
      desc: 'Message when no sales invoices are available.',
      args: [],
    );
  }

  /// `This customer has no eligible sales invoices for warranty claims.`
  String get noEligibleSalesInvoices {
    return Intl.message(
      'This customer has no eligible sales invoices for warranty claims.',
      name: 'noEligibleSalesInvoices',
      desc:
          'Message when customer has no eligible sales invoices for warranty claims.',
      args: [],
    );
  }

  /// `Please select a sales invoice`
  String get pleaseSelectSalesInvoice {
    return Intl.message(
      'Please select a sales invoice',
      name: 'pleaseSelectSalesInvoice',
      desc: 'Validation message to select a sales invoice.',
      args: [],
    );
  }

  /// `Reason for Warranty`
  String get reasonForWarrantyLabel {
    return Intl.message(
      'Reason for Warranty',
      name: 'reasonForWarrantyLabel',
      desc: 'Label for reason for warranty field.',
      args: [],
    );
  }

  /// `Select Products for Warranty`
  String get selectProductsForWarranty {
    return Intl.message(
      'Select Products for Warranty',
      name: 'selectProductsForWarranty',
      desc: 'Label for selecting products for warranty.',
      args: [],
    );
  }

  /// `Warranty invoice created successfully`
  String get warrantyInvoiceCreated {
    return Intl.message(
      'Warranty invoice created successfully',
      name: 'warrantyInvoiceCreated',
      desc: 'Message when warranty invoice is created successfully.',
      args: [],
    );
  }

  /// `Error creating warranty invoice: {error}`
  String errorCreatingWarrantyInvoice(String error) {
    return Intl.message(
      'Error creating warranty invoice: $error',
      name: 'errorCreatingWarrantyInvoice',
      desc: 'Error message when creating warranty invoice fails.',
      args: [error],
    );
  }

  /// `Product`
  String get product {
    return Intl.message(
      'Product',
      name: 'product',
      desc: 'Label for product.',
      args: [],
    );
  }

  /// `Select product`
  String get selectProduct {
    return Intl.message(
      'Select product',
      name: 'selectProduct',
      desc: 'Prompt to select a product.',
      args: [],
    );
  }

  /// `Please select a product`
  String get pleaseSelectProduct {
    return Intl.message(
      'Please select a product',
      name: 'pleaseSelectProduct',
      desc: 'Validation message to select a product.',
      args: [],
    );
  }

  /// `Quantity must be greater than 0`
  String get quantityGreaterThanZero {
    return Intl.message(
      'Quantity must be greater than 0',
      name: 'quantityGreaterThanZero',
      desc: 'Validation message for quantity greater than zero.',
      args: [],
    );
  }

  /// `Not enough stock`
  String get notEnoughStock {
    return Intl.message(
      'Not enough stock',
      name: 'notEnoughStock',
      desc: 'Message when there is not enough stock.',
      args: [],
    );
  }

  /// `No address found`
  String get noAddressFound {
    return Intl.message(
      'No address found',
      name: 'noAddressFound',
      desc: 'Message when no address is found.',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: 'Label for date.',
      args: [],
    );
  }

  /// `Subtotal`
  String get subtotal {
    return Intl.message(
      'Subtotal',
      name: 'subtotal',
      desc: 'Label for subtotal.',
      args: [],
    );
  }

  /// `Edit Invoice`
  String get editInvoice {
    return Intl.message(
      'Edit Invoice',
      name: 'editInvoice',
      desc: 'Button or title for editing invoice.',
      args: [],
    );
  }

  /// `Change Address`
  String get changeAddress {
    return Intl.message(
      'Change Address',
      name: 'changeAddress',
      desc: 'Button or label for changing address.',
      args: [],
    );
  }

  /// `Unknown Product`
  String get unknownProduct {
    return Intl.message(
      'Unknown Product',
      name: 'unknownProduct',
      desc: 'Label for unknown product.',
      args: [],
    );
  }

  /// `Error: {error}`
  String errorWithMessage(String error) {
    return Intl.message(
      'Error: $error',
      name: 'errorWithMessage',
      desc: 'Generic error message with error placeholder.',
      args: [error],
    );
  }

  /// `Error loading invoice details: {error}`
  String errorLoadingInvoiceDetails(String error) {
    return Intl.message(
      'Error loading invoice details: $error',
      name: 'errorLoadingInvoiceDetails',
      desc: 'Error message when loading invoice details fails.',
      args: [error],
    );
  }

  /// `Sales Invoice`
  String get salesInvoice {
    return Intl.message(
      'Sales Invoice',
      name: 'salesInvoice',
      desc: 'Label for sales invoice.',
      args: [],
    );
  }

  /// `Loading...`
  String get loading {
    return Intl.message(
      'Loading...',
      name: 'loading',
      desc: 'Label for loading state.',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: 'Label for category field.',
      args: [],
    );
  }

  /// `Enter Address`
  String get enterAddress {
    return Intl.message(
      'Enter Address',
      name: 'enterAddress',
      desc: 'Label for the field or button to enter an address.',
      args: [],
    );
  }

  /// `Find warranty invoices...`
  String get findWarrantyInvoices {
    return Intl.message(
      'Find warranty invoices...',
      name: 'findWarrantyInvoices',
      desc: 'Search field placeholder for warranty invoices.',
      args: [],
    );
  }

  /// `No warranty invoices found`
  String get noWarrantyInvoicesFound {
    return Intl.message(
      'No warranty invoices found',
      name: 'noWarrantyInvoicesFound',
      desc: 'Message when no warranty invoices are found.',
      args: [],
    );
  }

  /// `Mark as Completed`
  String get markAsCompleted {
    return Intl.message(
      'Mark as Completed',
      name: 'markAsCompleted',
      desc: 'Button or label to mark as completed.',
      args: [],
    );
  }

  /// `Error loading warranty invoice details: {error}`
  String errorLoadingWarrantyInvoiceDetails(String error) {
    return Intl.message(
      'Error loading warranty invoice details: $error',
      name: 'errorLoadingWarrantyInvoiceDetails',
      desc: 'Error message when loading warranty invoice details fails.',
      args: [error],
    );
  }

  /// `Sales`
  String get sales {
    return Intl.message(
      'Sales',
      name: 'sales',
      desc: 'Tab label for sales invoices.',
      args: [],
    );
  }

  /// `Incoming`
  String get incoming {
    return Intl.message(
      'Incoming',
      name: 'incoming',
      desc: 'Tab label for incoming invoices.',
      args: [],
    );
  }

  /// `Warranty`
  String get warranty {
    return Intl.message(
      'Warranty',
      name: 'warranty',
      desc: 'Tab label for warranty invoices.',
      args: [],
    );
  }

  /// `Hello!`
  String get hello {
    return Intl.message(
      'Hello!',
      name: 'hello',
      desc: 'Greeting for the user in the drawer.',
      args: [],
    );
  }

  /// `Contact Us:`
  String get contactUs {
    return Intl.message(
      'Contact Us:',
      name: 'contactUs',
      desc: 'Label for contact information section in the drawer.',
      args: [],
    );
  }

  /// `Log out`
  String get logOut {
    return Intl.message(
      'Log out',
      name: 'logOut',
      desc: 'Button label for logging out.',
      args: [],
    );
  }

  /// `Home`
  String get home {
    return Intl.message(
      'Home',
      name: 'home',
      desc: 'Bottom navigation label for home screen.',
      args: [],
    );
  }

  /// `Invoice`
  String get invoice {
    return Intl.message(
      'Invoice',
      name: 'invoice',
      desc: 'Bottom navigation label for invoice screen.',
      args: [],
    );
  }

  /// `Stakeholder`
  String get stakeholder {
    return Intl.message(
      'Stakeholder',
      name: 'stakeholder',
      desc: 'Bottom navigation label for stakeholder screen.',
      args: [],
    );
  }

  /// `Voucher`
  String get voucher {
    return Intl.message(
      'Voucher',
      name: 'voucher',
      desc: 'Bottom navigation label for voucher screen.',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: 'Bottom navigation label for profile screen.',
      args: [],
    );
  }

  /// `Add New Address`
  String get addNewAddress {
    return Intl.message(
      'Add New Address',
      name: 'addNewAddress',
      desc: 'Dialog title for adding a new address.',
      args: [],
    );
  }

  /// `Receiver Name`
  String get receiverName {
    return Intl.message(
      'Receiver Name',
      name: 'receiverName',
      desc: 'Label for receiver name field.',
      args: [],
    );
  }

  /// `Enter receiver name`
  String get enterReceiverName {
    return Intl.message(
      'Enter receiver name',
      name: 'enterReceiverName',
      desc: 'Hint for entering receiver name.',
      args: [],
    );
  }

  /// `Receiver Phone`
  String get receiverPhone {
    return Intl.message(
      'Receiver Phone',
      name: 'receiverPhone',
      desc: 'Label for receiver phone field.',
      args: [],
    );
  }

  /// `Enter phone number`
  String get enterPhoneNumber {
    return Intl.message(
      'Enter phone number',
      name: 'enterPhoneNumber',
      desc: 'Hint for entering phone number.',
      args: [],
    );
  }

  /// `Location`
  String get location {
    return Intl.message(
      'Location',
      name: 'location',
      desc: 'Label for location/address picker.',
      args: [],
    );
  }

  /// `Street Address`
  String get streetAddress {
    return Intl.message(
      'Street Address',
      name: 'streetAddress',
      desc: 'Label for street address field.',
      args: [],
    );
  }

  /// `Street name, building, house no.`
  String get streetNameBuildingHouseNo {
    return Intl.message(
      'Street name, building, house no.',
      name: 'streetNameBuildingHouseNo',
      desc: 'Hint for street address field.',
      args: [],
    );
  }

  /// `Add Address`
  String get addAddress {
    return Intl.message(
      'Add Address',
      name: 'addAddress',
      desc: 'Button label for adding address.',
      args: [],
    );
  }

  /// `Customer Detail`
  String get customerDetail {
    return Intl.message(
      'Customer Detail',
      name: 'customerDetail',
      desc: 'Title for customer detail screen.',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: 'Button label for editing.',
      args: [],
    );
  }

  /// `Name`
  String get name {
    return Intl.message(
      'Name',
      name: 'name',
      desc: 'Label for name field.',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: 'Label for email field.',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: 'Label for phone field.',
      args: [],
    );
  }

  /// `Addresses`
  String get addresses {
    return Intl.message(
      'Addresses',
      name: 'addresses',
      desc: 'Label for addresses section.',
      args: [],
    );
  }

  /// `Please fill in all required fields`
  String get pleaseFillInAllRequiredFields {
    return Intl.message(
      'Please fill in all required fields',
      name: 'pleaseFillInAllRequiredFields',
      desc: 'Validation message for required fields.',
      args: [],
    );
  }

  /// `Discard Changes?`
  String get discardChanges {
    return Intl.message(
      'Discard Changes?',
      name: 'discardChanges',
      desc: 'Dialog title for discarding changes.',
      args: [],
    );
  }

  /// `You have unsaved changes. Do you want to discard them?`
  String get unsavedChangesDiscard {
    return Intl.message(
      'You have unsaved changes. Do you want to discard them?',
      name: 'unsavedChangesDiscard',
      desc: 'Dialog content for unsaved changes.',
      args: [],
    );
  }

  /// `DISCARD`
  String get discard {
    return Intl.message(
      'DISCARD',
      name: 'discard',
      desc: 'Button label for discarding changes.',
      args: [],
    );
  }

  /// `Edit Customer`
  String get editCustomer {
    return Intl.message(
      'Edit Customer',
      name: 'editCustomer',
      desc: 'Title for edit customer screen.',
      args: [],
    );
  }

  /// `Full Name`
  String get fullName {
    return Intl.message(
      'Full Name',
      name: 'fullName',
      desc: 'Label for full name field.',
      args: [],
    );
  }

  /// `Name is required`
  String get nameIsRequired {
    return Intl.message(
      'Name is required',
      name: 'nameIsRequired',
      desc: 'Validation message for required name.',
      args: [],
    );
  }

  /// `Name must be at least 2 characters`
  String get nameMin2Chars {
    return Intl.message(
      'Name must be at least 2 characters',
      name: 'nameMin2Chars',
      desc: 'Validation message for name minimum length.',
      args: [],
    );
  }

  /// `Phone Number`
  String get phoneNumber {
    return Intl.message(
      'Phone Number',
      name: 'phoneNumber',
      desc: 'Label for phone number field.',
      args: [],
    );
  }

  /// `Phone number is required`
  String get phoneNumberIsRequired {
    return Intl.message(
      'Phone number is required',
      name: 'phoneNumberIsRequired',
      desc: 'Validation message for required phone number.',
      args: [],
    );
  }

  /// `Please enter a valid phone number`
  String get pleaseEnterValidPhoneNumber {
    return Intl.message(
      'Please enter a valid phone number',
      name: 'pleaseEnterValidPhoneNumber',
      desc: 'Validation message for valid phone number.',
      args: [],
    );
  }

  /// `Add New Customer`
  String get addNewCustomer {
    return Intl.message(
      'Add New Customer',
      name: 'addNewCustomer',
      desc: 'Dialog title for adding a new customer.',
      args: [],
    );
  }

  /// `Add Customer`
  String get addCustomer {
    return Intl.message(
      'Add Customer',
      name: 'addCustomer',
      desc: 'Button label for adding a customer.',
      args: [],
    );
  }

  /// `Please fill in all fields`
  String get pleaseFillInAllFields {
    return Intl.message(
      'Please fill in all fields',
      name: 'pleaseFillInAllFields',
      desc: 'Validation message for required fields.',
      args: [],
    );
  }

  /// `Customer added successfully`
  String get customerAddedSuccessfully {
    return Intl.message(
      'Customer added successfully',
      name: 'customerAddedSuccessfully',
      desc: 'Message when a customer is added successfully.',
      args: [],
    );
  }

  /// `Find customers...`
  String get findCustomers {
    return Intl.message(
      'Find customers...',
      name: 'findCustomers',
      desc: 'Search field placeholder for customers.',
      args: [],
    );
  }

  /// `No matching customers found`
  String get noMatchingCustomersFound {
    return Intl.message(
      'No matching customers found',
      name: 'noMatchingCustomersFound',
      desc: 'Message when no matching customers are found.',
      args: [],
    );
  }

  /// `Employee Detail`
  String get employeeDetail {
    return Intl.message(
      'Employee Detail',
      name: 'employeeDetail',
      desc: 'Title for employee detail screen.',
      args: [],
    );
  }

  /// `Employee Information`
  String get employeeInformation {
    return Intl.message(
      'Employee Information',
      name: 'employeeInformation',
      desc: 'Section title for employee information.',
      args: [],
    );
  }

  /// `Role`
  String get role {
    return Intl.message(
      'Role',
      name: 'role',
      desc: 'Label for role field.',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: 'Button label for deleting.',
      args: [],
    );
  }

  /// `Delete Employee`
  String get deleteEmployee {
    return Intl.message(
      'Delete Employee',
      name: 'deleteEmployee',
      desc: 'Dialog title for deleting an employee.',
      args: [],
    );
  }

  /// `Are you sure you want to delete this employee?`
  String get areYouSureDeleteEmployee {
    return Intl.message(
      'Are you sure you want to delete this employee?',
      name: 'areYouSureDeleteEmployee',
      desc: 'Confirmation message for deleting an employee.',
      args: [],
    );
  }

  /// `Edit Employee`
  String get editEmployee {
    return Intl.message(
      'Edit Employee',
      name: 'editEmployee',
      desc: 'Title for edit employee screen.',
      args: [],
    );
  }

  /// `Please enter a name`
  String get pleaseEnterName {
    return Intl.message(
      'Please enter a name',
      name: 'pleaseEnterName',
      desc: 'Validation message for required employee name.',
      args: [],
    );
  }

  /// `Please enter a phone number`
  String get pleaseEnterPhoneNumber {
    return Intl.message(
      'Please enter a phone number',
      name: 'pleaseEnterPhoneNumber',
      desc: 'Validation message for required employee phone number.',
      args: [],
    );
  }

  /// `Please select a role`
  String get pleaseSelectRole {
    return Intl.message(
      'Please select a role',
      name: 'pleaseSelectRole',
      desc: 'Validation message for required employee role.',
      args: [],
    );
  }

  /// `Add New Employee`
  String get addNewEmployee {
    return Intl.message(
      'Add New Employee',
      name: 'addNewEmployee',
      desc: 'Dialog title for adding a new employee.',
      args: [],
    );
  }

  /// `Please enter email address`
  String get pleaseEnterEmail {
    return Intl.message(
      'Please enter email address',
      name: 'pleaseEnterEmail',
      desc: 'Validation message for required employee email.',
      args: [],
    );
  }

  /// `Filter by Role`
  String get filterByRole {
    return Intl.message(
      'Filter by Role',
      name: 'filterByRole',
      desc: 'Dialog title for filtering employees by role.',
      args: [],
    );
  }

  /// `Clear Filter`
  String get clearFilter {
    return Intl.message(
      'Clear Filter',
      name: 'clearFilter',
      desc: 'Button label to clear the role filter.',
      args: [],
    );
  }

  /// `Find employees...`
  String get findEmployees {
    return Intl.message(
      'Find employees...',
      name: 'findEmployees',
      desc: 'Search field placeholder for employees.',
      args: [],
    );
  }

  /// `No employees found`
  String get noEmployeesFound {
    return Intl.message(
      'No employees found',
      name: 'noEmployeesFound',
      desc: 'Message when no employees are found.',
      args: [],
    );
  }

  /// `Employee added successfully.`
  String get employeeAddedSuccessfully {
    return Intl.message(
      'Employee added successfully.',
      name: 'employeeAddedSuccessfully',
      desc: 'Message when an employee is added successfully.',
      args: [],
    );
  }

  /// `Manufacturer Detail`
  String get manufacturerDetail {
    return Intl.message(
      'Manufacturer Detail',
      name: 'manufacturerDetail',
      desc: 'Title for manufacturer detail screen.',
      args: [],
    );
  }

  /// `Deactivate`
  String get deactivate {
    return Intl.message(
      'Deactivate',
      name: 'deactivate',
      desc: 'Button label to deactivate manufacturer.',
      args: [],
    );
  }

  /// `Activate`
  String get activate {
    return Intl.message(
      'Activate',
      name: 'activate',
      desc: 'Button label to activate manufacturer.',
      args: [],
    );
  }

  /// `Deactivate Manufacturer`
  String get deactivateManufacturer {
    return Intl.message(
      'Deactivate Manufacturer',
      name: 'deactivateManufacturer',
      desc: 'Dialog title for deactivating manufacturer.',
      args: [],
    );
  }

  /// `Activate Manufacturer`
  String get activateManufacturer {
    return Intl.message(
      'Activate Manufacturer',
      name: 'activateManufacturer',
      desc: 'Dialog title for activating manufacturer.',
      args: [],
    );
  }

  /// `Are you sure you want to deactivate this manufacturer?`
  String get deactivateManufacturerConfirm {
    return Intl.message(
      'Are you sure you want to deactivate this manufacturer?',
      name: 'deactivateManufacturerConfirm',
      desc: 'Confirmation message for deactivating manufacturer.',
      args: [],
    );
  }

  /// `Are you sure you want to activate this manufacturer?`
  String get activateManufacturerConfirm {
    return Intl.message(
      'Are you sure you want to activate this manufacturer?',
      name: 'activateManufacturerConfirm',
      desc: 'Confirmation message for activating manufacturer.',
      args: [],
    );
  }

  /// `Inactive`
  String get inactive {
    return Intl.message(
      'Inactive',
      name: 'inactive',
      desc: 'Tab label for inactive vouchers.',
      args: [],
    );
  }

  /// `Manufacturer Information`
  String get manufacturerInformation {
    return Intl.message(
      'Manufacturer Information',
      name: 'manufacturerInformation',
      desc: 'Section title for manufacturer information.',
      args: [],
    );
  }

  /// `Name`
  String get manufacturerName {
    return Intl.message(
      'Name',
      name: 'manufacturerName',
      desc: 'Label for manufacturer name field.',
      args: [],
    );
  }

  /// `Edit Manufacturer`
  String get editManufacturer {
    return Intl.message(
      'Edit Manufacturer',
      name: 'editManufacturer',
      desc: 'Title for edit manufacturer screen.',
      args: [],
    );
  }

  /// `Add New Manufacturer`
  String get addNewManufacturer {
    return Intl.message(
      'Add New Manufacturer',
      name: 'addNewManufacturer',
      desc: 'Dialog title for adding a new manufacturer.',
      args: [],
    );
  }

  /// `Add Manufacturer`
  String get addManufacturer {
    return Intl.message(
      'Add Manufacturer',
      name: 'addManufacturer',
      desc: 'Button label for adding a manufacturer.',
      args: [],
    );
  }

  /// `Find manufacturers...`
  String get findManufacturers {
    return Intl.message(
      'Find manufacturers...',
      name: 'findManufacturers',
      desc: 'Search field placeholder for manufacturers.',
      args: [],
    );
  }

  /// `No matching manufacturers found`
  String get noMatchingManufacturersFound {
    return Intl.message(
      'No matching manufacturers found',
      name: 'noMatchingManufacturersFound',
      desc: 'Message when no matching manufacturers are found.',
      args: [],
    );
  }

  /// `Are you sure you want to deactivate {name}?`
  String deactivateManufacturerConfirmName(String name) {
    return Intl.message(
      'Are you sure you want to deactivate $name?',
      name: 'deactivateManufacturerConfirmName',
      desc: 'Confirmation message for deactivating a manufacturer with name.',
      args: [name],
    );
  }

  /// `Are you sure you want to activate {name}?`
  String activateManufacturerConfirmName(String name) {
    return Intl.message(
      'Are you sure you want to activate $name?',
      name: 'activateManufacturerConfirmName',
      desc: 'Confirmation message for activating a manufacturer with name.',
      args: [name],
    );
  }

  /// `Employees`
  String get employees {
    return Intl.message(
      'Employees',
      name: 'employees',
      desc: 'Tab label for employees.',
      args: [],
    );
  }

  /// `Vendors`
  String get vendors {
    return Intl.message(
      'Vendors',
      name: 'vendors',
      desc: 'Tab label for vendors.',
      args: [],
    );
  }

  /// `App Avatar`
  String get appAvatar {
    return Intl.message(
      'App Avatar',
      name: 'appAvatar',
      desc: 'Label for the app avatar in the loading screen.',
      args: [],
    );
  }

  /// `Create new account`
  String get createNewAccount {
    return Intl.message(
      'Create new account',
      name: 'createNewAccount',
      desc: 'Button label for creating a new account.',
      args: [],
    );
  }

  /// `Already have an account?`
  String get alreadyHaveAccount {
    return Intl.message(
      'Already have an account?',
      name: 'alreadyHaveAccount',
      desc: 'Button label for users who already have an account.',
      args: [],
    );
  }

  /// `Information`
  String get informationTitle {
    return Intl.message(
      'Information',
      name: 'informationTitle',
      desc: 'Title for the information screen.',
      args: [],
    );
  }

  /// `About GizmoGlobe`
  String get aboutGizmoGlobe {
    return Intl.message(
      'About GizmoGlobe',
      name: 'aboutGizmoGlobe',
      desc: 'Section title: About GizmoGlobe.',
      args: [],
    );
  }

  /// `About Us`
  String get aboutUsTitle {
    return Intl.message(
      'About Us',
      name: 'aboutUsTitle',
      desc: 'Section title: About Us.',
      args: [],
    );
  }

  /// `GizmoGlobe is your trusted provider for computer hardware solutions.`
  String get aboutUsContent {
    return Intl.message(
      'GizmoGlobe is your trusted provider for computer hardware solutions.',
      name: 'aboutUsContent',
      desc: 'Content for About Us section.',
      args: [],
    );
  }

  /// `Our Mission`
  String get ourMissionTitle {
    return Intl.message(
      'Our Mission',
      name: 'ourMissionTitle',
      desc: 'Section title: Our Mission.',
      args: [],
    );
  }

  /// `To provide excellent service and quality products to you, our beloved customers.`
  String get ourMissionContent {
    return Intl.message(
      'To provide excellent service and quality products to you, our beloved customers.',
      name: 'ourMissionContent',
      desc: 'Content for Our Mission section.',
      args: [],
    );
  }

  /// `Contact Information`
  String get contactInformationTitle {
    return Intl.message(
      'Contact Information',
      name: 'contactInformationTitle',
      desc: 'Section title: Contact Information.',
      args: [],
    );
  }

  /// `Address: UIT`
  String get contactInformationContent {
    return Intl.message(
      'Address: UIT',
      name: 'contactInformationContent',
      desc: 'Content for Contact Information section.',
      args: [],
    );
  }

  /// `Business Hours`
  String get businessHoursTitle {
    return Intl.message(
      'Business Hours',
      name: 'businessHoursTitle',
      desc: 'Section title: Business Hours.',
      args: [],
    );
  }

  /// `Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 4:00 PM\nSunday: Closed`
  String get businessHoursContent {
    return Intl.message(
      'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 4:00 PM\nSunday: Closed',
      name: 'businessHoursContent',
      desc: 'Content for Business Hours section.',
      args: [],
    );
  }

  /// `Support`
  String get supportTitle {
    return Intl.message(
      'Support',
      name: 'supportTitle',
      desc: 'Title for the support screen.',
      args: [],
    );
  }

  /// `Members of teams`
  String get supportMembers {
    return Intl.message(
      'Members of teams',
      name: 'supportMembers',
      desc: 'Section title for team members.',
      args: [],
    );
  }

  /// `Developer`
  String get supportRoleDeveloper {
    return Intl.message(
      'Developer',
      name: 'supportRoleDeveloper',
      desc: 'Role: Developer.',
      args: [],
    );
  }

  /// `Student ID: {id}`
  String supportStudentId(String id) {
    return Intl.message(
      'Student ID: $id',
      name: 'supportStudentId',
      desc: 'Label for student ID with placeholder.',
      args: [id],
    );
  }

  /// `Role: {role}`
  String supportRole(String role) {
    return Intl.message(
      'Role: $role',
      name: 'supportRole',
      desc: 'Label for role with placeholder.',
      args: [role],
    );
  }

  /// `Email: {email}`
  String supportEmail(String email) {
    return Intl.message(
      'Email: $email',
      name: 'supportEmail',
      desc: 'Label for email with placeholder.',
      args: [email],
    );
  }

  /// `Account Settings`
  String get accountSettings {
    return Intl.message(
      'Account Settings',
      name: 'accountSettings',
      desc: 'Title for account settings section.',
      args: [],
    );
  }

  /// `Edit Profile`
  String get editProfile {
    return Intl.message(
      'Edit Profile',
      name: 'editProfile',
      desc: 'Button or title for editing profile.',
      args: [],
    );
  }

  /// `Update your personal information`
  String get updatePersonalInfo {
    return Intl.message(
      'Update your personal information',
      name: 'updatePersonalInfo',
      desc: 'Subtitle for updating personal information.',
      args: [],
    );
  }

  /// `Change Password`
  String get changePassword {
    return Intl.message(
      'Change Password',
      name: 'changePassword',
      desc: 'Button or title for changing password.',
      args: [],
    );
  }

  /// `Manage your account security`
  String get manageAccountSecurity {
    return Intl.message(
      'Manage your account security',
      name: 'manageAccountSecurity',
      desc: 'Subtitle for managing account security.',
      args: [],
    );
  }

  /// `Sign Out`
  String get signOut {
    return Intl.message(
      'Sign Out',
      name: 'signOut',
      desc: 'Button label for signing out.',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: 'Label for username field.',
      args: [],
    );
  }

  /// `Save changes`
  String get saveChanges {
    return Intl.message(
      'Save changes',
      name: 'saveChanges',
      desc: 'Button label for saving changes.',
      args: [],
    );
  }

  /// `Update profile successfully`
  String get updateProfileSuccess {
    return Intl.message(
      'Update profile successfully',
      name: 'updateProfileSuccess',
      desc: 'Message when profile is updated successfully.',
      args: [],
    );
  }

  /// `A password reset email will be sent to {email}`
  String passwordResetEmailWillBeSent(String email) {
    return Intl.message(
      'A password reset email will be sent to $email',
      name: 'passwordResetEmailWillBeSent',
      desc: 'Message for password reset email with placeholder.',
      args: [email],
    );
  }

  /// `Password reset email sent successfully`
  String get passwordResetEmailSentSuccess {
    return Intl.message(
      'Password reset email sent successfully',
      name: 'passwordResetEmailSentSuccess',
      desc: 'Message when password reset email is sent successfully.',
      args: [],
    );
  }

  /// `Send Password Reset Email`
  String get sendPasswordResetEmail {
    return Intl.message(
      'Send Password Reset Email',
      name: 'sendPasswordResetEmail',
      desc: 'Button label for sending password reset email.',
      args: [],
    );
  }

  /// `No user is currently signed in`
  String get noUserSignedIn {
    return Intl.message(
      'No user is currently signed in',
      name: 'noUserSignedIn',
      desc: 'Message when no user is signed in.',
      args: [],
    );
  }

  /// `Add Voucher`
  String get addVoucher {
    return Intl.message(
      'Add Voucher',
      name: 'addVoucher',
      desc: 'Title for add voucher screen.',
      args: [],
    );
  }

  /// `Basic Information`
  String get basicInformation {
    return Intl.message(
      'Basic Information',
      name: 'basicInformation',
      desc: 'Section title for basic information.',
      args: [],
    );
  }

  /// `Voucher Name`
  String get voucherName {
    return Intl.message(
      'Voucher Name',
      name: 'voucherName',
      desc: 'Label for voucher name field.',
      args: [],
    );
  }

  /// `Discount Value`
  String get discountValue {
    return Intl.message(
      'Discount Value',
      name: 'discountValue',
      desc: 'Label for discount value field.',
      args: [],
    );
  }

  /// `Minimum Purchase`
  String get minimumPurchase {
    return Intl.message(
      'Minimum Purchase',
      name: 'minimumPurchase',
      desc: 'Label for minimum purchase field.',
      args: [],
    );
  }

  /// `Start Time`
  String get startTime {
    return Intl.message(
      'Start Time',
      name: 'startTime',
      desc: 'Label for start time field.',
      args: [],
    );
  }

  /// `Max Usage Per Person`
  String get maxUsagePerPerson {
    return Intl.message(
      'Max Usage Per Person',
      name: 'maxUsagePerPerson',
      desc: 'Label for max usage per person field.',
      args: [],
    );
  }

  /// `Description`
  String get description {
    return Intl.message(
      'Description',
      name: 'description',
      desc: 'Label for description field.',
      args: [],
    );
  }

  /// `Voucher Settings`
  String get voucherSettings {
    return Intl.message(
      'Voucher Settings',
      name: 'voucherSettings',
      desc: 'Section title for voucher settings.',
      args: [],
    );
  }

  /// `Discount Type`
  String get discountType {
    return Intl.message(
      'Discount Type',
      name: 'discountType',
      desc: 'Label for discount type toggle.',
      args: [],
    );
  }

  /// `Fixed Amount`
  String get fixedAmount {
    return Intl.message(
      'Fixed Amount',
      name: 'fixedAmount',
      desc: 'Label for fixed amount option.',
      args: [],
    );
  }

  /// `Percentage`
  String get percentage {
    return Intl.message(
      'Percentage',
      name: 'percentage',
      desc: 'Label for percentage option.',
      args: [],
    );
  }

  /// `Maximum Discount Value`
  String get maximumDiscountValue {
    return Intl.message(
      'Maximum Discount Value',
      name: 'maximumDiscountValue',
      desc: 'Label for maximum discount value field.',
      args: [],
    );
  }

  /// `Usage Limit`
  String get usageLimit {
    return Intl.message(
      'Usage Limit',
      name: 'usageLimit',
      desc: 'Label for usage limit toggle.',
      args: [],
    );
  }

  /// `Unlimited`
  String get unlimited {
    return Intl.message(
      'Unlimited',
      name: 'unlimited',
      desc: 'Label for unlimited option.',
      args: [],
    );
  }

  /// `Limited`
  String get limited {
    return Intl.message(
      'Limited',
      name: 'limited',
      desc: 'Label for limited option.',
      args: [],
    );
  }

  /// `Maximum Usage`
  String get maximumUsage {
    return Intl.message(
      'Maximum Usage',
      name: 'maximumUsage',
      desc: 'Label for maximum usage field.',
      args: [],
    );
  }

  /// `Usage Left`
  String get usageLeft {
    return Intl.message(
      'Usage Left',
      name: 'usageLeft',
      desc: 'Label for usage left field.',
      args: [],
    );
  }

  /// `Time Limit`
  String get timeLimit {
    return Intl.message(
      'Time Limit',
      name: 'timeLimit',
      desc: 'Label for time limit toggle.',
      args: [],
    );
  }

  /// `No End Time`
  String get noEndTime {
    return Intl.message(
      'No End Time',
      name: 'noEndTime',
      desc: 'Label for no end time option.',
      args: [],
    );
  }

  /// `Has End Time`
  String get hasEndTime {
    return Intl.message(
      'Has End Time',
      name: 'hasEndTime',
      desc: 'Label for has end time option.',
      args: [],
    );
  }

  /// `End Time`
  String get endTime {
    return Intl.message(
      'End Time',
      name: 'endTime',
      desc: 'Label for end time field.',
      args: [],
    );
  }

  /// `This voucher will not expire`
  String get voucherWillNotExpire {
    return Intl.message(
      'This voucher will not expire',
      name: 'voucherWillNotExpire',
      desc: 'Message for voucher with no expiration.',
      args: [],
    );
  }

  /// `Visibility`
  String get visibility {
    return Intl.message(
      'Visibility',
      name: 'visibility',
      desc: 'Label for visibility toggle.',
      args: [],
    );
  }

  /// `Hidden`
  String get hidden {
    return Intl.message(
      'Hidden',
      name: 'hidden',
      desc: 'Label for hidden option.',
      args: [],
    );
  }

  /// `Visible`
  String get visible {
    return Intl.message(
      'Visible',
      name: 'visible',
      desc: 'Label for visible option.',
      args: [],
    );
  }

  /// `Disabled`
  String get disabled {
    return Intl.message(
      'Disabled',
      name: 'disabled',
      desc: 'Label for disabled option.',
      args: [],
    );
  }

  /// `Enabled`
  String get enabled {
    return Intl.message(
      'Enabled',
      name: 'enabled',
      desc: 'Label for enabled option.',
      args: [],
    );
  }

  /// `Select {field}`
  String selectField(String field) {
    return Intl.message(
      'Select $field',
      name: 'selectField',
      desc: 'Hint for selecting a field.',
      args: [field],
    );
  }

  /// `Enter {field}`
  String enterField(String field) {
    return Intl.message(
      'Enter $field',
      name: 'enterField',
      desc: 'Hint for entering a field.',
      args: [field],
    );
  }

  /// `All`
  String get all {
    return Intl.message(
      'All',
      name: 'all',
      desc: 'Tab label for all vouchers.',
      args: [],
    );
  }

  /// `Ongoing`
  String get ongoing {
    return Intl.message(
      'Ongoing',
      name: 'ongoing',
      desc: 'Tab label for ongoing vouchers.',
      args: [],
    );
  }

  /// `Upcoming`
  String get upcoming {
    return Intl.message(
      'Upcoming',
      name: 'upcoming',
      desc: 'Tab label for upcoming vouchers.',
      args: [],
    );
  }

  /// `No vouchers available`
  String get noVouchersAvailable {
    return Intl.message(
      'No vouchers available',
      name: 'noVouchersAvailable',
      desc: 'Message when no vouchers are available.',
      args: [],
    );
  }

  /// `Filter`
  String get filter {
    return Intl.message(
      'Filter',
      name: 'filter',
      desc: 'Title for filter screen.',
      args: [],
    );
  }

  /// `From`
  String get from {
    return Intl.message(
      'From',
      name: 'from',
      desc: 'Label for minimum value in range filter.',
      args: [],
    );
  }

  /// `To`
  String get to {
    return Intl.message(
      'To',
      name: 'to',
      desc: 'Label for maximum value in range filter.',
      args: [],
    );
  }

  /// `Min`
  String get min {
    return Intl.message(
      'Min',
      name: 'min',
      desc: 'Hint for minimum value in range filter.',
      args: [],
    );
  }

  /// `Max`
  String get max {
    return Intl.message(
      'Max',
      name: 'max',
      desc: 'Hint for maximum value in range filter.',
      args: [],
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
