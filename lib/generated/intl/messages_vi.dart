// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a vi locale. All the
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
  String get localeName => 'vi';

  static String m0(status) =>
      "Bạn có chắc chắn muốn thay đổi trạng thái thành ${status}?";

  static String m1(error) => "Lỗi tạo hóa đơn bảo hành: ${error}";

  static String m2(id) => "Biên lai bảo hành #${id}";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "add": MessageLookupByLibrary.simpleMessage("Thêm"),
    "addProduct": MessageLookupByLibrary.simpleMessage("Thêm sản phẩm"),
    "address": MessageLookupByLibrary.simpleMessage("Địa chỉ"),
    "appTitle": MessageLookupByLibrary.simpleMessage("GizmoGlobe"),
    "areYouSureChangeStatus": m0,
    "availableStock": MessageLookupByLibrary.simpleMessage("Hàng tồn kho"),
    "avgIncome": MessageLookupByLibrary.simpleMessage("Thu nhập trung bình"),
    "cancel": MessageLookupByLibrary.simpleMessage("Hủy"),
    "confirm": MessageLookupByLibrary.simpleMessage("Xác nhận"),
    "confirmStatusUpdate": MessageLookupByLibrary.simpleMessage(
      "Xác nhận cập nhật trạng thái",
    ),
    "createInvoice": MessageLookupByLibrary.simpleMessage("Tạo hóa đơn"),
    "customer": MessageLookupByLibrary.simpleMessage("Khách hàng"),
    "customerInformation": MessageLookupByLibrary.simpleMessage(
      "Thông tin khách hàng",
    ),
    "customers": MessageLookupByLibrary.simpleMessage("Khách hàng"),
    "dateNewestFirst": MessageLookupByLibrary.simpleMessage(
      "Ngày (Mới nhất trước)",
    ),
    "dateOldestFirst": MessageLookupByLibrary.simpleMessage(
      "Ngày (Cũ nhất trước)",
    ),
    "editPayment": MessageLookupByLibrary.simpleMessage("Chỉnh sửa thanh toán"),
    "editProductDetail": MessageLookupByLibrary.simpleMessage(
      "Chỉnh sửa chi tiết sản phẩm",
    ),
    "errorCreatingWarrantyInvoice": m1,
    "errorOccurred": MessageLookupByLibrary.simpleMessage("Có lỗi xảy ra"),
    "importPrice": MessageLookupByLibrary.simpleMessage("Giá nhập"),
    "invoiceDetails": MessageLookupByLibrary.simpleMessage("Chi tiết hóa đơn"),
    "last12Months": MessageLookupByLibrary.simpleMessage("12 tháng qua"),
    "last3Months": MessageLookupByLibrary.simpleMessage("3 tháng qua"),
    "markAsPaidQuestion": MessageLookupByLibrary.simpleMessage(
      "Đánh dấu hóa đơn này là đã thanh toán?",
    ),
    "monthlySales": MessageLookupByLibrary.simpleMessage("Doanh số hàng tháng"),
    "newIncomingInvoice": MessageLookupByLibrary.simpleMessage(
      "Tạo hóa đơn nhập mới",
    ),
    "newInvoice": MessageLookupByLibrary.simpleMessage("Hóa đơn mới"),
    "noEligibleSalesInvoices": MessageLookupByLibrary.simpleMessage(
      "Khách hàng này không có hóa đơn bán hàng nào hợp lệ để yêu cầu bảo hành.",
    ),
    "noIncomingInvoicesFound": MessageLookupByLibrary.simpleMessage(
      "Không tìm thấy hóa đơn nhập",
    ),
    "noProductsAddedYet": MessageLookupByLibrary.simpleMessage(
      "Chưa thêm sản phẩm nào",
    ),
    "noSalesInvoicesAvailable": MessageLookupByLibrary.simpleMessage(
      "Không có hóa đơn bán hàng",
    ),
    "noSalesInvoicesFound": MessageLookupByLibrary.simpleMessage(
      "Không tìm thấy hóa đơn bán hàng",
    ),
    "onlyUnpaidCanBeMarkedPaid": MessageLookupByLibrary.simpleMessage(
      "Chỉ hóa đơn chưa thanh toán mới có thể đánh dấu là đã thanh toán",
    ),
    "overview": MessageLookupByLibrary.simpleMessage("Tổng quan"),
    "paymentStatus": MessageLookupByLibrary.simpleMessage(
      "Trạng thái thanh toán",
    ),
    "pleaseSelectAddress": MessageLookupByLibrary.simpleMessage(
      "Vui lòng chọn địa chỉ",
    ),
    "pleaseSelectCustomer": MessageLookupByLibrary.simpleMessage(
      "Vui lòng chọn khách hàng",
    ),
    "pleaseSelectCustomerFirst": MessageLookupByLibrary.simpleMessage(
      "Vui lòng chọn khách hàng trước",
    ),
    "pleaseSelectSalesInvoice": MessageLookupByLibrary.simpleMessage(
      "Vui lòng chọn hóa đơn bán hàng",
    ),
    "price": MessageLookupByLibrary.simpleMessage("Giá"),
    "priceHighestFirst": MessageLookupByLibrary.simpleMessage(
      "Giá (Cao nhất trước)",
    ),
    "priceLowestFirst": MessageLookupByLibrary.simpleMessage(
      "Giá (Thấp nhất trước)",
    ),
    "products": MessageLookupByLibrary.simpleMessage("Sản phẩm"),
    "productsUnderWarranty": MessageLookupByLibrary.simpleMessage(
      "Sản phẩm được bảo hành",
    ),
    "quantity": MessageLookupByLibrary.simpleMessage("Số lượng"),
    "reasonForWarranty": MessageLookupByLibrary.simpleMessage("Lý do bảo hành"),
    "reasonForWarrantyLabel": MessageLookupByLibrary.simpleMessage(
      "Lý do bảo hành",
    ),
    "revenue": MessageLookupByLibrary.simpleMessage("Doanh thu"),
    "salesStatus": MessageLookupByLibrary.simpleMessage("Trạng thái bán hàng"),
    "save": MessageLookupByLibrary.simpleMessage("Lưu"),
    "searchIncomingInvoices": MessageLookupByLibrary.simpleMessage(
      "Tìm hóa đơn nhập...",
    ),
    "searchSalesInvoices": MessageLookupByLibrary.simpleMessage(
      "Tìm hóa đơn bán hàng...",
    ),
    "selectCustomer": MessageLookupByLibrary.simpleMessage("Chọn khách hàng"),
    "selectManufacturer": MessageLookupByLibrary.simpleMessage(
      "Chọn nhà sản xuất",
    ),
    "selectProductsForWarranty": MessageLookupByLibrary.simpleMessage(
      "Chọn sản phẩm để bảo hành",
    ),
    "sortBy": MessageLookupByLibrary.simpleMessage("Sắp xếp theo..."),
    "status": MessageLookupByLibrary.simpleMessage("Trạng thái"),
    "totalAmount": MessageLookupByLibrary.simpleMessage("Tổng số tiền"),
    "totalPrice": MessageLookupByLibrary.simpleMessage("Tổng giá: "),
    "unknownCategory": MessageLookupByLibrary.simpleMessage("Không xác định"),
    "update": MessageLookupByLibrary.simpleMessage("Cập nhật"),
    "updateStatus": MessageLookupByLibrary.simpleMessage("Cập nhật trạng thái"),
    "updateWarrantyStatus": MessageLookupByLibrary.simpleMessage(
      "Cập nhật trạng thái bảo hành",
    ),
    "view": MessageLookupByLibrary.simpleMessage("Xem"),
    "warrantyInformation": MessageLookupByLibrary.simpleMessage(
      "Thông tin bảo hành",
    ),
    "warrantyInvoiceCreated": MessageLookupByLibrary.simpleMessage(
      "Tạo hóa đơn bảo hành thành công",
    ),
    "warrantyReceipt": m2,
    "welcomeBack": MessageLookupByLibrary.simpleMessage("Chào mừng trở lại,"),
  };
}
