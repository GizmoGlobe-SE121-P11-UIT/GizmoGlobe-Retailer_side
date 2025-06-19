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

  /// `Discount`
  String get discount {
    return Intl.message(
      'Discount',
      name: 'discount',
      desc: 'Label for discount field.',
      args: [],
    );
  }

  /// `Minimum purchase`
  String get minimumPurchase {
    return Intl.message(
      'Minimum purchase',
      name: 'minimumPurchase',
      desc: 'Label for minimum purchase amount.',
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

  /// `Usage left`
  String get usageLeft {
    return Intl.message(
      'Usage left',
      name: 'usageLeft',
      desc: 'Label for remaining usage count.',
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
      desc: 'Label for hidden voucher status.',
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
      desc: 'Label for disabled voucher status.',
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

  /// `Paid`
  String get paid {
    return Intl.message(
      'Paid',
      name: 'paid',
      desc: 'Label for paid status.',
      args: [],
    );
  }

  /// `Unpaid`
  String get unpaid {
    return Intl.message(
      'Unpaid',
      name: 'unpaid',
      desc: 'Label for unpaid status.',
      args: [],
    );
  }

  /// `Pending`
  String get pending {
    return Intl.message(
      'Pending',
      name: 'pending',
      desc: 'Label for pending status.',
      args: [],
    );
  }

  /// `Preparing`
  String get preparing {
    return Intl.message(
      'Preparing',
      name: 'preparing',
      desc: 'Label for preparing status.',
      args: [],
    );
  }

  /// `Shipping`
  String get shipping {
    return Intl.message(
      'Shipping',
      name: 'shipping',
      desc: 'Label for shipping status.',
      args: [],
    );
  }

  /// `Shipped`
  String get shipped {
    return Intl.message(
      'Shipped',
      name: 'shipped',
      desc: 'Label for shipped status.',
      args: [],
    );
  }

  /// `Completed`
  String get completed {
    return Intl.message(
      'Completed',
      name: 'completed',
      desc: 'Label for completed status.',
      args: [],
    );
  }

  /// `Cancelled`
  String get cancelled {
    return Intl.message(
      'Cancelled',
      name: 'cancelled',
      desc: 'Label for cancelled status.',
      args: [],
    );
  }

  /// `Pending`
  String get warrantyStatus_pending {
    return Intl.message(
      'Pending',
      name: 'warrantyStatus_pending',
      desc: 'Label for pending warranty status.',
      args: [],
    );
  }

  /// `Processing`
  String get warrantyStatus_processing {
    return Intl.message(
      'Processing',
      name: 'warrantyStatus_processing',
      desc: 'Label for processing warranty status.',
      args: [],
    );
  }

  /// `Completed`
  String get warrantyStatus_completed {
    return Intl.message(
      'Completed',
      name: 'warrantyStatus_completed',
      desc: 'Label for completed warranty status.',
      args: [],
    );
  }

  /// `Denied`
  String get warrantyStatus_denied {
    return Intl.message(
      'Denied',
      name: 'warrantyStatus_denied',
      desc: 'Label for denied warranty status.',
      args: [],
    );
  }

  /// `Success`
  String get success {
    return Intl.message(
      'Success',
      name: 'success',
      desc: 'Success dialog title.',
      args: [],
    );
  }

  /// `Failure`
  String get failure {
    return Intl.message(
      'Failure',
      name: 'failure',
      desc: 'Failure dialog title.',
      args: [],
    );
  }

  /// `Signed in successfully.`
  String get signInSuccess {
    return Intl.message(
      'Signed in successfully.',
      name: 'signInSuccess',
      desc: 'Message shown when sign in is successful.',
      args: [],
    );
  }

  /// `Failed to sign in. Please try again.`
  String get signInFailed {
    return Intl.message(
      'Failed to sign in. Please try again.',
      name: 'signInFailed',
      desc: 'Message shown when sign in fails.',
      args: [],
    );
  }

  /// `Failed to send verification link. Please try again.`
  String get verificationLinkFailed {
    return Intl.message(
      'Failed to send verification link. Please try again.',
      name: 'verificationLinkFailed',
      desc: 'Message shown when sending verification link fails.',
      args: [],
    );
  }

  /// `Error changing password. Please try again.`
  String get changePasswordFailed {
    return Intl.message(
      'Error changing password. Please try again.',
      name: 'changePasswordFailed',
      desc: 'Message shown when changing password fails.',
      args: [],
    );
  }

  /// `Passwords do not match.`
  String get passwordsDoNotMatch {
    return Intl.message(
      'Passwords do not match.',
      name: 'passwordsDoNotMatch',
      desc: 'Message shown when passwords do not match.',
      args: [],
    );
  }

  /// `A verification email has been sent to your email address. Please verify your email to complete signing up.`
  String get verificationEmailSent {
    return Intl.message(
      'A verification email has been sent to your email address. Please verify your email to complete signing up.',
      name: 'verificationEmailSent',
      desc: 'Message shown when verification email is sent.',
      args: [],
    );
  }

  /// `Failed to sign up. Please try again.`
  String get signUpFailed {
    return Intl.message(
      'Failed to sign up. Please try again.',
      name: 'signUpFailed',
      desc: 'Message shown when sign up fails.',
      args: [],
    );
  }

  /// `A verification link has been sent to your email address. Please verify your email to reset your password.`
  String get resetPasswordLinkSent {
    return Intl.message(
      'A verification link has been sent to your email address. Please verify your email to reset your password.',
      name: 'resetPasswordLinkSent',
      desc: 'Message shown when reset password link is sent.',
      args: [],
    );
  }

  /// `Failed to sign out. Please try again.`
  String get signOutFailed {
    return Intl.message(
      'Failed to sign out. Please try again.',
      name: 'signOutFailed',
      desc: 'Message shown when sign out fails.',
      args: [],
    );
  }

  /// `Email not verified. Please verify your email.`
  String get emailNotVerified {
    return Intl.message(
      'Email not verified. Please verify your email.',
      name: 'emailNotVerified',
      desc: 'Message shown when email is not verified.',
      args: [],
    );
  }

  /// `Invalid email or password`
  String get invalidEmailOrPassword {
    return Intl.message(
      'Invalid email or password',
      name: 'invalidEmailOrPassword',
      desc: 'Message shown when email or password is invalid.',
      args: [],
    );
  }

  /// `This email is not registered in the system`
  String get emailNotRegistered {
    return Intl.message(
      'This email is not registered in the system',
      name: 'emailNotRegistered',
      desc: 'Message shown when email is not registered.',
      args: [],
    );
  }

  /// `Product added successfully.`
  String get productAddedSuccess {
    return Intl.message(
      'Product added successfully.',
      name: 'productAddedSuccess',
      desc: 'Message shown when product is added successfully.',
      args: [],
    );
  }

  /// `Failed to add product. Please try again.`
  String get productAddFailed {
    return Intl.message(
      'Failed to add product. Please try again.',
      name: 'productAddFailed',
      desc: 'Message shown when adding product fails.',
      args: [],
    );
  }

  /// `Product updated successfully.`
  String get productUpdatedSuccess {
    return Intl.message(
      'Product updated successfully.',
      name: 'productUpdatedSuccess',
      desc: 'Message shown when product is updated successfully.',
      args: [],
    );
  }

  /// `Failed to update product. Please try again.`
  String get productUpdateFailed {
    return Intl.message(
      'Failed to update product. Please try again.',
      name: 'productUpdateFailed',
      desc: 'Message shown when updating product fails.',
      args: [],
    );
  }

  /// `An unexpected error occurred. Please try again.`
  String get unexpectedError {
    return Intl.message(
      'An unexpected error occurred. Please try again.',
      name: 'unexpectedError',
      desc: 'Message shown when an unexpected error occurs.',
      args: [],
    );
  }

  /// `Choose from Gallery`
  String get chooseFromGallery {
    return Intl.message(
      'Choose from Gallery',
      name: 'chooseFromGallery',
      desc: 'Option to choose image from gallery.',
      args: [],
    );
  }

  /// `Take a Photo`
  String get takePhoto {
    return Intl.message(
      'Take a Photo',
      name: 'takePhoto',
      desc: 'Option to take a photo with camera.',
      args: [],
    );
  }

  /// `Enter URL`
  String get enterUrl {
    return Intl.message(
      'Enter URL',
      name: 'enterUrl',
      desc: 'Option to enter image URL.',
      args: [],
    );
  }

  /// `Enter Image URL`
  String get enterImageUrl {
    return Intl.message(
      'Enter Image URL',
      name: 'enterImageUrl',
      desc: 'Prompt to enter image URL.',
      args: [],
    );
  }

  /// `Add Product Image`
  String get addProductImage {
    return Intl.message(
      'Add Product Image',
      name: 'addProductImage',
      desc: 'Title for adding product image section.',
      args: [],
    );
  }

  /// `Search manufacturer...`
  String get searchManufacturer {
    return Intl.message(
      'Search manufacturer...',
      name: 'searchManufacturer',
      desc: 'Placeholder text for manufacturer search field.',
      args: [],
    );
  }

  /// `Active`
  String get active {
    return Intl.message(
      'Active',
      name: 'active',
      desc: 'Status indicating product is active.',
      args: [],
    );
  }

  /// `Out of Stock`
  String get outOfStock {
    return Intl.message(
      'Out of Stock',
      name: 'outOfStock',
      desc: 'Status indicating product is out of stock.',
      args: [],
    );
  }

  /// `Discontinued`
  String get discontinued {
    return Intl.message(
      'Discontinued',
      name: 'discontinued',
      desc: 'Status indicating product is discontinued.',
      args: [],
    );
  }

  /// `Specifications for`
  String get categorySpecifications {
    return Intl.message(
      'Specifications for',
      name: 'categorySpecifications',
      desc: 'Title for category specifications section.',
      args: [],
    );
  }

  /// `RAM Bus`
  String get ramBus {
    return Intl.message(
      'RAM Bus',
      name: 'ramBus',
      desc: 'Label for RAM bus speed specification.',
      args: [],
    );
  }

  /// `RAM Capacity`
  String get ramCapacity {
    return Intl.message(
      'RAM Capacity',
      name: 'ramCapacity',
      desc: 'Label for RAM capacity specification.',
      args: [],
    );
  }

  /// `RAM Type`
  String get ramType {
    return Intl.message(
      'RAM Type',
      name: 'ramType',
      desc: 'Label for RAM type specification.',
      args: [],
    );
  }

  /// `CPU Family`
  String get cpuFamily {
    return Intl.message(
      'CPU Family',
      name: 'cpuFamily',
      desc: 'Label for CPU family specification.',
      args: [],
    );
  }

  /// `CPU Core`
  String get cpuCore {
    return Intl.message(
      'CPU Core',
      name: 'cpuCore',
      desc: 'Label for CPU core count specification.',
      args: [],
    );
  }

  /// `CPU Thread`
  String get cpuThread {
    return Intl.message(
      'CPU Thread',
      name: 'cpuThread',
      desc: 'Label for CPU thread count specification.',
      args: [],
    );
  }

  /// `CPU Clock Speed`
  String get cpuClockSpeed {
    return Intl.message(
      'CPU Clock Speed',
      name: 'cpuClockSpeed',
      desc: 'Label for CPU clock speed specification.',
      args: [],
    );
  }

  /// `PSU Wattage`
  String get psuWattage {
    return Intl.message(
      'PSU Wattage',
      name: 'psuWattage',
      desc: 'Label for PSU wattage specification.',
      args: [],
    );
  }

  /// `PSU Efficiency`
  String get psuEfficiency {
    return Intl.message(
      'PSU Efficiency',
      name: 'psuEfficiency',
      desc: 'Label for PSU efficiency rating specification.',
      args: [],
    );
  }

  /// `PSU Modular`
  String get psuModular {
    return Intl.message(
      'PSU Modular',
      name: 'psuModular',
      desc: 'Label for PSU modular type specification.',
      args: [],
    );
  }

  /// `GPU Series`
  String get gpuSeries {
    return Intl.message(
      'GPU Series',
      name: 'gpuSeries',
      desc: 'Label for GPU series specification.',
      args: [],
    );
  }

  /// `GPU Capacity`
  String get gpuCapacity {
    return Intl.message(
      'GPU Capacity',
      name: 'gpuCapacity',
      desc: 'Label for GPU memory capacity specification.',
      args: [],
    );
  }

  /// `GPU Bus`
  String get gpuBus {
    return Intl.message(
      'GPU Bus',
      name: 'gpuBus',
      desc: 'Label for GPU bus interface specification.',
      args: [],
    );
  }

  /// `GPU Clock Speed`
  String get gpuClockSpeed {
    return Intl.message(
      'GPU Clock Speed',
      name: 'gpuClockSpeed',
      desc: 'Label for GPU clock speed specification.',
      args: [],
    );
  }

  /// `Form Factor`
  String get formFactor {
    return Intl.message(
      'Form Factor',
      name: 'formFactor',
      desc: 'Label for motherboard form factor specification.',
      args: [],
    );
  }

  /// `Series`
  String get series {
    return Intl.message(
      'Series',
      name: 'series',
      desc: 'Label for product series specification.',
      args: [],
    );
  }

  /// `Compatibility`
  String get compatibility {
    return Intl.message(
      'Compatibility',
      name: 'compatibility',
      desc: 'Label for compatibility specification.',
      args: [],
    );
  }

  /// `Drive Type`
  String get driveType {
    return Intl.message(
      'Drive Type',
      name: 'driveType',
      desc: 'Label for drive type specification.',
      args: [],
    );
  }

  /// `Drive Capacity`
  String get driveCapacity {
    return Intl.message(
      'Drive Capacity',
      name: 'driveCapacity',
      desc: 'Label for drive capacity specification.',
      args: [],
    );
  }

  /// `Product Name`
  String get productName {
    return Intl.message(
      'Product Name',
      name: 'productName',
      desc: 'Label for product name field.',
      args: [],
    );
  }

  /// `Selling Price`
  String get sellingPrice {
    return Intl.message(
      'Selling Price',
      name: 'sellingPrice',
      desc: 'Label for selling price field.',
      args: [],
    );
  }

  /// `Stock`
  String get stock {
    return Intl.message(
      'Stock',
      name: 'stock',
      desc: 'Label for stock quantity field.',
      args: [],
    );
  }

  /// `Additional Information`
  String get additionalInformation {
    return Intl.message(
      'Additional Information',
      name: 'additionalInformation',
      desc: 'Label for additional product information field.',
      args: [],
    );
  }

  /// `Release Date`
  String get releaseDate {
    return Intl.message(
      'Release Date',
      name: 'releaseDate',
      desc: 'Label for product release date field.',
      args: [],
    );
  }

  /// `Manufacturer`
  String get manufacturer {
    return Intl.message(
      'Manufacturer',
      name: 'manufacturer',
      desc: 'Label for product manufacturer field.',
      args: [],
    );
  }

  /// `Drive`
  String get drive {
    return Intl.message(
      'Drive',
      name: 'drive',
      desc: 'Label for drive category.',
      args: [],
    );
  }

  /// `Mainboard`
  String get mainboard {
    return Intl.message(
      'Mainboard',
      name: 'mainboard',
      desc: 'Label for mainboard category.',
      args: [],
    );
  }

  /// `Find your item...`
  String get findProducts {
    return Intl.message(
      'Find your item...',
      name: 'findProducts',
      desc: 'Search field placeholder for products.',
      args: [],
    );
  }

  /// `No products found`
  String get noProductsFound {
    return Intl.message(
      'No products found',
      name: 'noProductsFound',
      desc: 'Message shown when no products are found.',
      args: [],
    );
  }

  /// `Release date: Latest`
  String get releaseLatest {
    return Intl.message(
      'Release date: Latest',
      name: 'releaseLatest',
      desc: 'Label for sorting by latest release date.',
      args: [],
    );
  }

  /// `Release date: Oldest`
  String get releaseOldest {
    return Intl.message(
      'Release date: Oldest',
      name: 'releaseOldest',
      desc: 'Label for sorting by oldest release date.',
      args: [],
    );
  }

  /// `Stock: Highest`
  String get stockHighest {
    return Intl.message(
      'Stock: Highest',
      name: 'stockHighest',
      desc: 'Label for sorting by highest stock.',
      args: [],
    );
  }

  /// `Stock: Lowest`
  String get stockLowest {
    return Intl.message(
      'Stock: Lowest',
      name: 'stockLowest',
      desc: 'Label for sorting by lowest stock.',
      args: [],
    );
  }

  /// `Sale: Highest`
  String get salesHighest {
    return Intl.message(
      'Sale: Highest',
      name: 'salesHighest',
      desc: 'Label for sorting by highest sales.',
      args: [],
    );
  }

  /// `Sale: Lowest`
  String get salesLowest {
    return Intl.message(
      'Sale: Lowest',
      name: 'salesLowest',
      desc: 'Label for sorting by lowest sales.',
      args: [],
    );
  }

  /// `Voucher added successfully.`
  String get voucherAddedSuccess {
    return Intl.message(
      'Voucher added successfully.',
      name: 'voucherAddedSuccess',
      desc: 'Success message when a voucher is added.',
      args: [],
    );
  }

  /// `Failed to add voucher. Please try again.`
  String get voucherAddFailed {
    return Intl.message(
      'Failed to add voucher. Please try again.',
      name: 'voucherAddFailed',
      desc: 'Error message when voucher addition fails.',
      args: [],
    );
  }

  /// `Voucher deleted successfully.`
  String get voucherDeletedSuccess {
    return Intl.message(
      'Voucher deleted successfully.',
      name: 'voucherDeletedSuccess',
      desc: 'Success message when a voucher is deleted.',
      args: [],
    );
  }

  /// `Failed to delete voucher. Please try again.`
  String get voucherDeleteFailed {
    return Intl.message(
      'Failed to delete voucher. Please try again.',
      name: 'voucherDeleteFailed',
      desc: 'Error message when voucher deletion fails.',
      args: [],
    );
  }

  /// `Failed to load vouchers. Please try again.`
  String get errorLoadingVouchers {
    return Intl.message(
      'Failed to load vouchers. Please try again.',
      name: 'errorLoadingVouchers',
      desc: 'Error message when loading vouchers fails.',
      args: [],
    );
  }

  /// `Failed to update voucher. Please try again.`
  String get errorUpdatingVoucher {
    return Intl.message(
      'Failed to update voucher. Please try again.',
      name: 'errorUpdatingVoucher',
      desc: 'Error message when updating voucher fails.',
      args: [],
    );
  }

  /// `Generate description`
  String get generateDescriptionButton {
    return Intl.message(
      'Generate description',
      name: 'generateDescriptionButton',
      desc: 'Button label for generating product description.',
      args: [],
    );
  }

  /// `Translate description`
  String get translateDescriptionButton {
    return Intl.message(
      'Translate description',
      name: 'translateDescriptionButton',
      desc: 'Button label for translating product description.',
      args: [],
    );
  }

  /// `English description`
  String get enDescription {
    return Intl.message(
      'English description',
      name: 'enDescription',
      desc: 'Label for English description.',
      args: [],
    );
  }

  /// `Vietnamese description`
  String get viDescription {
    return Intl.message(
      'Vietnamese description',
      name: 'viDescription',
      desc: 'Label for Vietnamese description.',
      args: [],
    );
  }

  /// `Description generated successfully.`
  String get descriptionGenerated {
    return Intl.message(
      'Description generated successfully.',
      name: 'descriptionGenerated',
      desc: 'Success message when a description is generated successfully.',
      args: [],
    );
  }

  /// `Voucher edited successfully.`
  String get voucherEditSuccess {
    return Intl.message(
      'Voucher edited successfully.',
      name: 'voucherEditSuccess',
      desc: 'Success message when a voucher message is edited successfully.',
      args: [],
    );
  }

  /// `Product description`
  String get productDescription {
    return Intl.message(
      'Product description',
      name: 'productDescription',
      desc: 'Label for product description field.',
      args: [],
    );
  }

  /// `Type a message...`
  String get typeMessage {
    return Intl.message(
      'Type a message...',
      name: 'typeMessage',
      desc: 'Placeholder text for message input field.',
      args: [],
    );
  }

  /// `Select a conversation`
  String get selectConversation {
    return Intl.message(
      'Select a conversation',
      name: 'selectConversation',
      desc: 'Label for selecting a conversation.',
      args: [],
    );
  }

  /// `Messages`
  String get messages {
    return Intl.message(
      'Messages',
      name: 'messages',
      desc: 'Label for messages.',
      args: [],
    );
  }

  /// `No messages yet`
  String get noMessages {
    return Intl.message(
      'No messages yet',
      name: 'noMessages',
      desc: 'Message shown when there are no messages.',
      args: [],
    );
  }

  /// `Re-activate`
  String get reactivate {
    return Intl.message(
      'Re-activate',
      name: 'reactivate',
      desc: 'Button label for reactivating a product.',
      args: [],
    );
  }

  /// `Discontinue`
  String get discontinue {
    return Intl.message(
      'Discontinue',
      name: 'discontinue',
      desc: 'Button label for discontinuing a product.',
      args: [],
    );
  }

  /// `Please fill in all required fields`
  String get pleaseFillRequiredFields {
    return Intl.message(
      'Please fill in all required fields',
      name: 'pleaseFillRequiredFields',
      desc: 'Error message when required fields are not filled.',
      args: [],
    );
  }

  /// `Owner`
  String get roleOwner {
    return Intl.message(
      'Owner',
      name: 'roleOwner',
      desc: 'Label for owner role.',
      args: [],
    );
  }

  /// `Manager`
  String get roleManager {
    return Intl.message(
      'Manager',
      name: 'roleManager',
      desc: 'Label for manager role.',
      args: [],
    );
  }

  /// `Employee`
  String get roleEmployee {
    return Intl.message(
      'Employee',
      name: 'roleEmployee',
      desc: 'Label for employee role.',
      args: [],
    );
  }

  /// `App Settings`
  String get appSettings {
    return Intl.message(
      'App Settings',
      name: 'appSettings',
      desc: 'Title for app settings section',
      args: [],
    );
  }

  /// `Customize your app preferences`
  String get customizeAppPreferences {
    return Intl.message(
      'Customize your app preferences',
      name: 'customizeAppPreferences',
      desc: 'Description for app settings section',
      args: [],
    );
  }

  /// `Theme Mode`
  String get themeMode {
    return Intl.message(
      'Theme Mode',
      name: 'themeMode',
      desc: 'Label for theme mode setting',
      args: [],
    );
  }

  /// `Switch between light and dark mode`
  String get switchBetweenLightAndDark {
    return Intl.message(
      'Switch between light and dark mode',
      name: 'switchBetweenLightAndDark',
      desc: 'Description for theme mode setting',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: 'Label for language setting',
      args: [],
    );
  }

  /// `Change the app language`
  String get changeAppLanguage {
    return Intl.message(
      'Change the app language',
      name: 'changeAppLanguage',
      desc: 'Description for language setting',
      args: [],
    );
  }

  /// `English`
  String get english {
    return Intl.message(
      'English',
      name: 'english',
      desc: 'Label for English language option',
      args: [],
    );
  }

  /// `Vietnamese`
  String get vietnamese {
    return Intl.message(
      'Vietnamese',
      name: 'vietnamese',
      desc: 'Label for Vietnamese language option',
      args: [],
    );
  }

  /// `Sign in`
  String get signIn {
    return Intl.message(
      'Sign in',
      name: 'signIn',
      desc: 'Button label and title for sign in screen.',
      args: [],
    );
  }

  /// `Sign up`
  String get signUp {
    return Intl.message(
      'Sign up',
      name: 'signUp',
      desc: 'Button label for sign up.',
      args: [],
    );
  }

  /// `Forgot password?`
  String get forgotPassword {
    return Intl.message(
      'Forgot password?',
      name: 'forgotPassword',
      desc: 'Button label for forgot password.',
      args: [],
    );
  }

  /// `Your email`
  String get yourEmail {
    return Intl.message(
      'Your email',
      name: 'yourEmail',
      desc: 'Hint text for email field.',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: 'Hint text for password field.',
      args: [],
    );
  }

  /// `Authorized by admin?`
  String get authorizedByAdmin {
    return Intl.message(
      'Authorized by admin?',
      name: 'authorizedByAdmin',
      desc: 'Label for authorized by admin.',
      args: [],
    );
  }

  /// `Password confirmation`
  String get passwordConfirmation {
    return Intl.message(
      'Password confirmation',
      name: 'passwordConfirmation',
      desc: 'Hint text for password confirmation field.',
      args: [],
    );
  }

  /// `Forget Password`
  String get forgetPasswordTitle {
    return Intl.message(
      'Forget Password',
      name: 'forgetPasswordTitle',
      desc: 'Title for forget password screen.',
      args: [],
    );
  }

  /// `Don't worry! It happens. Please enter the email associated with your account.`
  String get forgetPasswordDescription {
    return Intl.message(
      'Don\'t worry! It happens. Please enter the email associated with your account.',
      name: 'forgetPasswordDescription',
      desc: 'Description for forget password screen.',
      args: [],
    );
  }

  /// `Email address`
  String get emailAddress {
    return Intl.message(
      'Email address',
      name: 'emailAddress',
      desc: 'Label for email address field.',
      args: [],
    );
  }

  /// `Enter your email address`
  String get enterYourEmailAddress {
    return Intl.message(
      'Enter your email address',
      name: 'enterYourEmailAddress',
      desc: 'Hint for entering email address.',
      args: [],
    );
  }

  /// `Send Verification Link`
  String get sendVerificationLink {
    return Intl.message(
      'Send Verification Link',
      name: 'sendVerificationLink',
      desc: 'Button label for sending verification link.',
      args: [],
    );
  }

  /// `Ran out`
  String get ranOut {
    return Intl.message(
      'Ran out',
      name: 'ranOut',
      desc: 'Label for when voucher has run out.',
      args: [],
    );
  }

  /// `Maximum discount`
  String get maximumDiscount {
    return Intl.message(
      'Maximum discount',
      name: 'maximumDiscount',
      desc: 'Label for maximum discount amount.',
      args: [],
    );
  }

  /// `Discount value`
  String get discountValue {
    return Intl.message(
      'Discount value',
      name: 'discountValue',
      desc: 'Label for discount value.',
      args: [],
    );
  }

  /// `Voucher updated successfully.`
  String get voucherUpdateSuccess {
    return Intl.message(
      'Voucher updated successfully.',
      name: 'voucherUpdateSuccess',
      desc: 'Success message when a voucher is updated successfully.',
      args: [],
    );
  }

  /// `Failed to update voucher. Please try again.`
  String get voucherUpdateFailed {
    return Intl.message(
      'Failed to update voucher. Please try again.',
      name: 'voucherUpdateFailed',
      desc: 'Error message when updating voucher fails.',
      args: [],
    );
  }

  /// `Gift Vouchers`
  String get giftVouchers {
    return Intl.message(
      'Gift Vouchers',
      name: 'giftVouchers',
      desc: 'Label for gift vouchers.',
      args: [],
    );
  }

  /// `Confirmation`
  String get confirmation {
    return Intl.message(
      'Confirmation',
      name: 'confirmation',
      desc: 'Title for confirmation dialog.',
      args: [],
    );
  }

  /// `Gift this voucher to customer? This action cannot be undone.`
  String get confirmGiftVoucher {
    return Intl.message(
      'Gift this voucher to customer? This action cannot be undone.',
      name: 'confirmGiftVoucher',
      desc: 'Message for confirming gift voucher action.',
      args: [],
    );
  }

  /// `Gift voucher successfully.`
  String get giveVoucherSuccess {
    return Intl.message(
      'Gift voucher successfully.',
      name: 'giveVoucherSuccess',
      desc: 'Success message when a voucher is gifted.',
      args: [],
    );
  }

  /// `Failed to gift voucher. Please try again.`
  String get giveVoucherFailed {
    return Intl.message(
      'Failed to gift voucher. Please try again.',
      name: 'giveVoucherFailed',
      desc: 'Error message when gifting voucher fails.',
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
