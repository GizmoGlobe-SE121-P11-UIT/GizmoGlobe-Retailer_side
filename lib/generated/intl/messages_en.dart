// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(status) =>
      "Are you sure you want to change the status to ${status}?";

  static String m1(error) => "Error creating warranty invoice: ${error}";

  static String m2(id) => "Warranty #${id}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "add": MessageLookupByLibrary.simpleMessage("Add"),
    "addProduct": MessageLookupByLibrary.simpleMessage("Add Product"),
    "address": MessageLookupByLibrary.simpleMessage("Address"),
    "appTitle": MessageLookupByLibrary.simpleMessage("GizmoGlobe"),
    "areYouSureChangeStatus": m0,
    "availableStock": MessageLookupByLibrary.simpleMessage("Available stock"),
    "avgIncome": MessageLookupByLibrary.simpleMessage("Avg. Income"),
    "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
    "confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "confirmStatusUpdate": MessageLookupByLibrary.simpleMessage(
      "Confirm Status Update",
    ),
    "createInvoice": MessageLookupByLibrary.simpleMessage("Create Invoice"),
    "customer": MessageLookupByLibrary.simpleMessage("Customer"),
    "customerInformation": MessageLookupByLibrary.simpleMessage(
      "Customer Information",
    ),
    "customers": MessageLookupByLibrary.simpleMessage("Customers"),
    "dateNewestFirst": MessageLookupByLibrary.simpleMessage(
      "Date (Newest First)",
    ),
    "dateOldestFirst": MessageLookupByLibrary.simpleMessage(
      "Date (Oldest First)",
    ),
    "editPayment": MessageLookupByLibrary.simpleMessage("Edit Payment"),
    "editProductDetail": MessageLookupByLibrary.simpleMessage(
      "Edit Product Detail",
    ),
    "errorCreatingWarrantyInvoice": m1,
    "errorOccurred": MessageLookupByLibrary.simpleMessage("Error occurred"),
    "importPrice": MessageLookupByLibrary.simpleMessage("Import Price"),
    "invoiceDetails": MessageLookupByLibrary.simpleMessage("Invoice Details"),
    "last12Months": MessageLookupByLibrary.simpleMessage("Last 12 months"),
    "last3Months": MessageLookupByLibrary.simpleMessage("Last 3 months"),
    "markAsPaidQuestion": MessageLookupByLibrary.simpleMessage(
      "Mark this invoice as paid?",
    ),
    "monthlySales": MessageLookupByLibrary.simpleMessage("Monthly Sales"),
    "newIncomingInvoice": MessageLookupByLibrary.simpleMessage(
      "New Incoming Invoice",
    ),
    "newInvoice": MessageLookupByLibrary.simpleMessage("New Invoice"),
    "noEligibleSalesInvoices": MessageLookupByLibrary.simpleMessage(
      "This customer has no eligible sales invoices for warranty claims.",
    ),
    "noIncomingInvoicesFound": MessageLookupByLibrary.simpleMessage(
      "No incoming invoices found",
    ),
    "noProductsAddedYet": MessageLookupByLibrary.simpleMessage(
      "No products added yet",
    ),
    "noSalesInvoicesAvailable": MessageLookupByLibrary.simpleMessage(
      "No sales invoices available",
    ),
    "noSalesInvoicesFound": MessageLookupByLibrary.simpleMessage(
      "No sales invoices found",
    ),
    "onlyUnpaidCanBeMarkedPaid": MessageLookupByLibrary.simpleMessage(
      "Only unpaid invoices can be marked as paid",
    ),
    "overview": MessageLookupByLibrary.simpleMessage("Overview"),
    "paymentStatus": MessageLookupByLibrary.simpleMessage("Payment Status"),
    "pleaseSelectAddress": MessageLookupByLibrary.simpleMessage(
      "Please select an address",
    ),
    "pleaseSelectCustomer": MessageLookupByLibrary.simpleMessage(
      "Please select a customer",
    ),
    "pleaseSelectCustomerFirst": MessageLookupByLibrary.simpleMessage(
      "Please select a customer first",
    ),
    "pleaseSelectSalesInvoice": MessageLookupByLibrary.simpleMessage(
      "Please select a sales invoice",
    ),
    "price": MessageLookupByLibrary.simpleMessage("Price"),
    "priceHighestFirst": MessageLookupByLibrary.simpleMessage(
      "Price (Highest First)",
    ),
    "priceLowestFirst": MessageLookupByLibrary.simpleMessage(
      "Price (Lowest First)",
    ),
    "products": MessageLookupByLibrary.simpleMessage("Products"),
    "productsUnderWarranty": MessageLookupByLibrary.simpleMessage(
      "Products Under Warranty",
    ),
    "quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "reasonForWarranty": MessageLookupByLibrary.simpleMessage(
      "Reason for Warranty",
    ),
    "reasonForWarrantyLabel": MessageLookupByLibrary.simpleMessage(
      "Reason for Warranty",
    ),
    "revenue": MessageLookupByLibrary.simpleMessage("Revenue"),
    "salesStatus": MessageLookupByLibrary.simpleMessage("Sales Status"),
    "save": MessageLookupByLibrary.simpleMessage("Save"),
    "searchIncomingInvoices": MessageLookupByLibrary.simpleMessage(
      "Find incoming invoices...",
    ),
    "searchSalesInvoices": MessageLookupByLibrary.simpleMessage(
      "Find sales invoices...",
    ),
    "selectCustomer": MessageLookupByLibrary.simpleMessage("Select customer"),
    "selectManufacturer": MessageLookupByLibrary.simpleMessage(
      "Select Manufacturer",
    ),
    "selectProductsForWarranty": MessageLookupByLibrary.simpleMessage(
      "Select Products for Warranty",
    ),
    "sortBy": MessageLookupByLibrary.simpleMessage("Sort By"),
    "status": MessageLookupByLibrary.simpleMessage("Status"),
    "totalAmount": MessageLookupByLibrary.simpleMessage("Total Amount"),
    "totalPrice": MessageLookupByLibrary.simpleMessage("Total Price: "),
    "unknownCategory": MessageLookupByLibrary.simpleMessage("Unknown Category"),
    "update": MessageLookupByLibrary.simpleMessage("Update"),
    "updateStatus": MessageLookupByLibrary.simpleMessage("Update Status"),
    "updateWarrantyStatus": MessageLookupByLibrary.simpleMessage(
      "Update Warranty Status",
    ),
    "view": MessageLookupByLibrary.simpleMessage("View"),
    "warrantyInformation": MessageLookupByLibrary.simpleMessage(
      "Warranty Information",
    ),
    "warrantyInvoiceCreated": MessageLookupByLibrary.simpleMessage(
      "Warranty invoice created successfully",
    ),
    "warrantyReceipt": m2,
    "welcomeBack": MessageLookupByLibrary.simpleMessage("Welcome back,"),
  };
}
