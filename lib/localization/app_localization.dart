import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // English translations
  static const Map<String, String> _en = {
    'appTitle': 'GizmoGlobe',
    'welcomeBack': 'Welcome back,',
    'overview': 'Overview',
    'products': 'Products',
    'customers': 'Customers',
    'revenue': 'Revenue',
    'avgIncome': 'Avg. Income',
    'monthlySales': 'Monthly Sales',
    'last12Months': 'Last 12 months',
    'last3Months': 'Last 3 months',
    'newIncomingInvoice': 'New Incoming Invoice',
    'selectManufacturer': 'Select Manufacturer',
    'addProduct': 'Add Product',
    'invoiceDetails': 'Invoice Details',
    'importPrice': 'Import Price',
    'quantity': 'Quantity',
    'totalPrice': 'Total Price: ',
    'paymentStatus': 'Payment Status',
    'createInvoice': 'Create Invoice',
    'cancel': 'Cancel',
    'add': 'Add',
    'editProductDetail': 'Edit Product Detail',
    'update': 'Update',
    'searchIncomingInvoices': 'Find incoming invoices...',
    'noIncomingInvoicesFound': 'No incoming invoices found',
    'view': 'View',
    'editPayment': 'Edit Payment',
    'onlyUnpaidCanBeMarkedPaid': 'Only unpaid invoices can be marked as paid',
    'markAsPaidQuestion': 'Mark this invoice as paid?',
    'confirm': 'OK',
    'sortBy': 'Sort By ',
    'dateNewestFirst': 'Date (Newest First)',
    'dateOldestFirst': 'Date (Oldest First)',
    'priceHighestFirst': 'Price (Highest First)',
    'priceLowestFirst': 'Price (Lowest First)',
    'errorOccurred': 'Error occurred',
    'newInvoice': 'New Invoice',
    'customerInformation': 'Customer Information',
    'selectCustomer': 'Select customer',
    'customer': 'Customer',
    'pleaseSelectCustomer': 'Please select a customer',
    'address': 'Address',
    'pleaseSelectAddress': 'Please select an address',
    'salesStatus': 'Sales Status',
    'totalAmount': 'Total Amount',
    'noProductsAddedYet': 'No products added yet',
    'price': 'Price',
    'availableStock': 'Available stock',
    'pleaseSelectCustomerFirst': 'Please select a customer first',
    'searchSalesInvoices': 'Find sales invoices...',
    'noSalesInvoicesFound': 'No sales invoices found',
    'warrantyReceipt': 'Warranty #{id}',
    'warrantyInformation': 'Warranty Information',
    'status': 'Status',
    'reasonForWarranty': 'Reason for Warranty',
    'productsUnderWarranty': 'Products Under Warranty',
    'unknownCategory': 'Unknown Category',
    'updateWarrantyStatus': 'Update Warranty Status',
    'confirmStatusUpdate': 'Confirm Status Update',
    'areYouSureChangeStatus':
        'Are you sure you want to change the status to {status}?',
    'save': 'Save',
    'updateStatus': 'Update Status',
    'noSalesInvoicesAvailable': 'No sales invoices available',
    'noEligibleSalesInvoices':
        'This customer has no eligible sales invoices for warranty claims.',
    'pleaseSelectSalesInvoice': 'Please select a sales invoice',
    'reasonForWarrantyLabel': 'Reason for Warranty',
    'selectProductsForWarranty': 'Select Products for Warranty',
    'warrantyInvoiceCreated': 'Warranty invoice created successfully',
    'errorCreatingWarrantyInvoice': 'Error creating warranty invoice: {error}',
    'product': 'Product',
    'selectProduct': 'Select product',
    'pleaseSelectProduct': 'Please select a product',
    'quantityGreaterThanZero': 'Quantity must be greater than 0',
    'notEnoughStock': 'Not enough stock',
    'noAddressFound': 'No address found',
    'date': 'Date',
    'subtotal': 'Subtotal',
    'editInvoice': 'Edit Invoice',
    'changeAddress': 'Change Address',
    'unknownProduct': 'Unknown Product',
    'errorWithMessage': 'Error: {error}',
    'errorLoadingInvoiceDetails': 'Error loading invoice details: {error}',
    'salesInvoice': 'Sales Invoice',
    'loading': 'Loading...',
    'category': 'Category',
    'enterAddress': 'Enter Address',
    'findWarrantyInvoices': 'Find warranty invoices...',
    'noWarrantyInvoicesFound': 'No warranty invoices found',
    'markAsCompleted': 'Mark as Completed',
    'errorLoadingWarrantyInvoiceDetails':
        'Error loading warranty invoice details: {error}',
    'sales': 'Sales',
    'incoming': 'Incoming',
    'warranty': 'Warranty',
    'hello': 'Hello!',
    'contactUs': 'Contact Us:',
    'logOut': 'Log out',
    'home': 'Home',
    'invoice': 'Invoice',
    'stakeholder': 'Stakeholder',
    'voucher': 'Voucher',
    'profile': 'Profile',
    'addNewAddress': 'Add New Address',
    'receiverName': 'Receiver Name',
    'enterReceiverName': 'Enter receiver name',
    'receiverPhone': 'Receiver Phone',
    'enterPhoneNumber': 'Enter phone number',
    'location': 'Location',
    'streetAddress': 'Street Address',
    'streetNameBuildingHouseNo': 'Street name, building, house no.',
    'addAddress': 'Add Address',
    'customerDetail': 'Customer Detail',
    'edit': 'Edit',
    'name': 'Name',
    'email': 'Email',
    'phone': 'Phone',
    'addresses': 'Addresses',
    'pleaseFillInAllRequiredFields': 'Please fill in all required fields',
    'discardChanges': 'Discard Changes?',
    'unsavedChangesDiscard':
        'You have unsaved changes. Do you want to discard them?',
    'discard': 'DISCARD',
    'editCustomer': 'Edit Customer',
    'fullName': 'Full Name',
    'nameIsRequired': 'Name is required',
    'nameMin2Chars': 'Name must be at least 2 characters',
    'phoneNumber': 'Phone Number',
    'phoneNumberIsRequired': 'Phone number is required',
    'pleaseEnterValidPhoneNumber': 'Please enter a valid phone number',
    'addNewCustomer': 'Add New Customer',
    'addCustomer': 'Add Customer',
    'pleaseFillInAllFields': 'Please fill in all fields',
    'customerAddedSuccessfully': 'Customer added successfully',
    'findCustomers': 'Find customers...',
    'noMatchingCustomersFound': 'No matching customers found',
    'employeeDetail': 'Employee Detail',
    'employeeInformation': 'Employee Information',
    'role': 'Role',
    'delete': 'Delete',
    'deleteEmployee': 'Delete Employee',
    'areYouSureDeleteEmployee':
        'Are you sure you want to delete this employee?',
    'editEmployee': 'Edit Employee',
    'pleaseEnterName': 'Please enter a name',
    'pleaseEnterPhoneNumber': 'Please enter a phone number',
    'pleaseSelectRole': 'Please select a role',
    'addNewEmployee': 'Add New Employee',
    'pleaseEnterEmail': 'Please enter email address',
    'filterByRole': 'Filter by Role',
    'clearFilter': 'Clear Filter',
    'findEmployees': 'Find employees...',
    'noEmployeesFound': 'No employees found',
    'employeeAddedSuccessfully': 'Employee added successfully.',
    'manufacturerDetail': 'Manufacturer Detail',
    'deactivate': 'Deactivate',
    'activate': 'Activate',
    'deactivateManufacturer': 'Deactivate Manufacturer',
    'activateManufacturer': 'Activate Manufacturer',
    'deactivateManufacturerConfirm':
        'Are you sure you want to deactivate this manufacturer?',
    'activateManufacturerConfirm':
        'Are you sure you want to activate this manufacturer?',
    'inactive': 'Inactive',
    'manufacturerInformation': 'Manufacturer Information',
    'manufacturerName': 'Name',
    'editManufacturer': 'Edit Manufacturer',
    'addNewManufacturer': 'Add New Manufacturer',
    'addManufacturer': 'Add Manufacturer',
    'findManufacturers': 'Find manufacturers...',
    'noMatchingManufacturersFound': 'No matching manufacturers found',
    'deactivateManufacturerConfirmName':
        'Are you sure you want to deactivate {name}?',
    'activateManufacturerConfirmName':
        'Are you sure you want to activate {name}?',
    'employees': 'Employees',
    'vendors': 'Vendors',
    'appAvatar': 'App Avatar',
    'createNewAccount': 'Create new account',
    'alreadyHaveAccount': 'Already have an account?',
    'informationTitle': 'Information',
    'aboutGizmoGlobe': 'About GizmoGlobe',
    'aboutUsTitle': 'About Us',
    'aboutUsContent':
        'GizmoGlobe is your trusted provider for computer hardware solutions.',
    'ourMissionTitle': 'Our Mission',
    'ourMissionContent':
        'To provide excellent service and quality products to you, our beloved customers.',
    'contactInformationTitle': 'Contact Information',
    'contactInformationContent': 'Address: UIT',
    'businessHoursTitle': 'Business Hours',
    'businessHoursContent':
        'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 4:00 PM\nSunday: Closed',
    'supportTitle': 'Support',
    'supportMembers': 'Members of teams',
    'supportRoleDeveloper': 'Developer',
    'supportStudentId': 'Student ID: {id}',
    'supportRole': 'Role: {role}',
    'supportEmail': 'Email: {email}',
    'accountSettings': 'Account Settings',
    'editProfile': 'Edit Profile',
    'updatePersonalInfo': 'Update your personal information',
    'changePassword': 'Change Password',
    'manageAccountSecurity': 'Manage your account security',
    'signOut': 'Sign Out',
    'username': 'Username',
    'saveChanges': 'Save changes',
    'updateProfileSuccess': 'Update profile successfully',
    'passwordResetEmailWillBeSent':
        'A password reset email will be sent to {email}',
    'passwordResetEmailSentSuccess': 'Password reset email sent successfully',
    'sendPasswordResetEmail': 'Send Password Reset Email',
    'noUserSignedIn': 'No user is currently signed in',
    'addVoucher': 'Add Voucher',
    'basicInformation': 'Basic Information',
    'voucherName': 'Voucher Name',
    'minimumPurchase': 'Minimum purchase',
    'startTime': 'Start Time',
    'maxUsagePerPerson': 'Max Usage Per Person',
    'description': 'Description',
    'voucherSettings': 'Voucher Settings',
    'discountType': 'Discount Type',
    'fixedAmount': 'Fixed Amount',
    'percentage': 'Percentage',
    'maximumDiscountValue': 'Maximum Discount Value',
    'usageLimit': 'Usage Limit',
    'unlimited': 'Unlimited',
    'limited': 'Limited',
    'maximumUsage': 'Maximum Usage',
    'usageLeft': 'Usage left',
    'timeLimit': 'Time Limit',
    'noEndTime': 'No End Time',
    'hasEndTime': 'Has End Time',
    'endTime': 'End Time',
    'voucherWillNotExpire': 'This voucher will not expire',
    'visibility': 'Visibility',
    'hidden': 'Hidden',
    'visible': 'Visible',
    'disabled': 'Disabled',
    'enabled': 'Enabled',
    'selectField': 'Select {field}',
    'enterField': 'Enter {field}',
    'all': 'All',
    'ongoing': 'Ongoing',
    'upcoming': 'Upcoming',
    'noVouchersAvailable': 'No vouchers available',
    'filter': 'Filter',
    'from': 'From',
    'to': 'To',
    'min': 'Min',
    'max': 'Max',
    'paid': 'Paid',
    'unpaid': 'Unpaid',
    'pending': 'Pending',
    'preparing': 'Preparing',
    'shipping': 'Shipping',
    'shipped': 'Shipped',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'warrantyStatus_pending': 'Pending',
    'warrantyStatus_processing': 'Processing',
    'warrantyStatus_completed': 'Completed',
    'warrantyStatus_denied': 'Denied',
    'success': 'Success',
    'failure': 'Failure',
    'signInSuccess': 'Signed in successfully.',
    'signInFailed': 'Failed to sign in. Please try again.',
    'verificationLinkFailed':
        'Failed to send verification link. Please try again.',
    'changePasswordFailed': 'Error changing password. Please try again.',
    'passwordsDoNotMatch': 'Passwords do not match.',
    'verificationEmailSent':
        'A verification email has been sent to your email address. Please verify your email to complete signing up.',
    'signUpFailed': 'Failed to sign up. Please try again.',
    'resetPasswordLinkSent':
        'A verification link has been sent to your email address. Please verify your email to reset your password.',
    'signOutFailed': 'Failed to sign out. Please try again.',
    'emailNotVerified': 'Email not verified. Please verify your email.',
    'invalidEmailOrPassword': 'Invalid email or password',
    'emailNotRegistered': 'This email is not registered in the system',
    'productAddedSuccess': 'Product added successfully.',
    'productAddFailed': 'Failed to add product. Please try again.',
    'productUpdatedSuccess': 'Product updated successfully.',
    'productUpdateFailed': 'Failed to update product. Please try again.',
    'unexpectedError': 'An unexpected error occurred. Please try again.',
    'chooseFromGallery': 'Choose from Gallery',
    'takePhoto': 'Take a Photo',
    'enterUrl': 'Enter URL',
    'enterImageUrl': 'Enter Image URL',
    'addProductImage': 'Add Product Image',
    'searchManufacturer': 'Search manufacturer...',
    'active': 'Active',
    'outOfStock': 'Out of Stock',
    'discontinued': 'Discontinued',
    'categorySpecifications': 'Specifications for',
    'ramBus': 'RAM Bus',
    'ramCapacity': 'RAM Capacity',
    'ramType': 'RAM Type',
    'cpuFamily': 'CPU Family',
    'cpuCore': 'CPU Core',
    'cpuThread': 'CPU Thread',
    'cpuClockSpeed': 'CPU Clock Speed',
    'psuWattage': 'PSU Wattage',
    'psuEfficiency': 'PSU Efficiency',
    'psuModular': 'PSU Modular',
    'gpuSeries': 'GPU Series',
    'gpuCapacity': 'GPU Capacity',
    'gpuBus': 'GPU Bus',
    'gpuClockSpeed': 'GPU Clock Speed',
    'formFactor': 'Form Factor',
    'series': 'Series',
    'compatibility': 'Compatibility',
    'driveType': 'Drive Type',
    'driveCapacity': 'Drive Capacity',
    'productName': 'Product Name',
    'sellingPrice': 'Selling Price',
    'discount': 'Discount',
    'stock': 'Stock',
    'additionalInformation': 'Additional Information',
    'releaseDate': 'Release Date',
    'manufacturer': 'Manufacturer',
    'drive': 'Drive',
    'mainboard': 'Mainboard',
    'findProducts': 'Find your item...',
    'noProductsFound': 'No products found',
    'releaseLatest': 'Release date: Latest',
    'releaseOldest': 'Release date: Oldest',
    'stockHighest': 'Stock: Highest',
    'stockLowest': 'Stock: Lowest',
    'salesHighest': 'Sale: Highest',
    'salesLowest': 'Sale: Lowest',
    'voucherAddedSuccess': 'Voucher added successfully.',
    'voucherAddFailed': 'Failed to add voucher. Please try again.',
    'voucherDeletedSuccess': 'Voucher deleted successfully.',
    'voucherDeleteFailed': 'Failed to delete voucher. Please try again.',
    'errorLoadingVouchers': 'Failed to load vouchers. Please try again.',
    'errorUpdatingVoucher': 'Failed to update voucher. Please try again.',
    'generateDescriptionButton': 'Generate description',
    'translateDescriptionButton': 'Translate description',
    'enDescription': 'English description',
    'viDescription': 'Vietnamese description',
    'descriptionGenerated': 'Description generated successfully.',
    'voucherEditSuccess': 'Voucher edited successfully.',
    'productDescription': 'Product description',
    'typeMessage': 'Type a message...',
    'selectConversation': 'Select a conversation',
    'messages': 'Messages',
    'noMessages': 'No messages yet',
    'reactivate': 'Re-activate',
    'discontinue': 'Discontinue',
    'pleaseFillRequiredFields': 'Please fill in all required fields',
    'roleOwner': 'Owner',
    'roleManager': 'Manager',
    'roleEmployee': 'Employee',
    'appSettings': 'App Settings',
    'customizeAppPreferences': 'Customize your app preferences',
    'themeMode': 'Theme Mode',
    'switchBetweenLightAndDark': 'Switch between light and dark mode',
    'language': 'Language',
    'changeAppLanguage': 'Change the app language',
    'english': 'English',
    'vietnamese': 'Vietnamese',
    'signIn': 'Sign in',
    'signUp': 'Sign up',
    'forgotPassword': 'Forgot password?',
    'yourEmail': 'Your email',
    'password': 'Password',
    'authorizedByAdmin': 'Authorized by admin?',
    'passwordConfirmation': 'Password confirmation',
    'forgetPasswordTitle': 'Forget Password',
    'forgetPasswordDescription':
        'Don\'t worry! It happens. Please enter the email associated with your account.',
    'emailAddress': 'Email address',
    'enterYourEmailAddress': 'Enter your email address',
    'sendVerificationLink': 'Send Verification Link',
    'rememberYourPassword': 'Remember your password?',
    'ranOut': 'Ran out',
    'maximumDiscount': 'Maximum discount',
    'discountValue': 'Discount value',
    'voucherUpdateSuccess': 'Voucher updated successfully.',
    'voucherUpdateFailed': 'Failed to update voucher. Please try again.',
    'giftVouchers': 'Gift Vouchers',
    'confirmation': 'Confirmation',
    'confirmGiftVoucher':
        'Gift this voucher to customer? This action cannot be undone.',
    'giveVoucherSuccess': 'Gift voucher successfully.',
    'giveVoucherFailed': 'Failed to gift voucher. Please try again.',
    'starts': 'Starts',
    'expires': 'Expires',
    'expired': 'Expired',
    'addressAddedSuccess': 'Address added successfully.',
    'addressAddFailed': 'Failed to add address. Please try again.',
    'addressUpdatedSuccess': 'Address updated successfully.',
    'addressUpdateFailed': 'Failed to update address. Please try again.',
    'editAddress': 'Edit Address',
    'saveAddress': 'Save Address',
  };

  // Vietnamese translations
  static const Map<String, String> _vi = {
    'appTitle': 'GizmoGlobe',
    'welcomeBack': 'Chào mừng trở lại,',
    'overview': 'Tổng quan',
    'products': 'Sản phẩm',
    'customers': 'Khách hàng',
    'revenue': 'Doanh thu',
    'avgIncome': 'Thu nhập trung bình',
    'monthlySales': 'Doanh số hàng tháng',
    'last12Months': '12 tháng qua',
    'last3Months': '3 tháng qua',
    'newIncomingInvoice': 'Tạo hóa đơn nhập mới',
    'selectManufacturer': 'Chọn nhà sản xuất',
    'addProduct': 'Thêm sản phẩm',
    'invoiceDetails': 'Chi tiết hóa đơn',
    'importPrice': 'Giá nhập',
    'quantity': 'Số lượng',
    'totalPrice': 'Tổng giá: ',
    'paymentStatus': 'Trạng thái thanh toán',
    'createInvoice': 'Tạo hóa đơn',
    'cancel': 'Hủy',
    'add': 'Thêm',
    'editProductDetail': 'Chỉnh sửa chi tiết sản phẩm',
    'update': 'Cập nhật',
    'searchIncomingInvoices': 'Tìm hóa đơn nhập...',
    'noIncomingInvoicesFound': 'Không tìm thấy hóa đơn nhập',
    'view': 'Xem',
    'editPayment': 'Chỉnh sửa thanh toán',
    'onlyUnpaidCanBeMarkedPaid':
        'Chỉ hóa đơn chưa thanh toán mới có thể đánh dấu là đã thanh toán',
    'markAsPaidQuestion': 'Đánh dấu hóa đơn này là đã thanh toán?',
    'confirm': 'Xác nhận',
    'sortBy': 'Sắp xếp theo ',
    'dateNewestFirst': 'Ngày (Mới nhất trước)',
    'dateOldestFirst': 'Ngày (Cũ nhất trước)',
    'priceHighestFirst': 'Giá (Cao nhất trước)',
    'priceLowestFirst': 'Giá (Thấp nhất trước)',
    'errorOccurred': 'Có lỗi xảy ra',
    'newInvoice': 'Hóa đơn mới',
    'customerInformation': 'Thông tin khách hàng',
    'selectCustomer': 'Chọn khách hàng',
    'customer': 'Khách hàng',
    'pleaseSelectCustomer': 'Vui lòng chọn khách hàng',
    'address': 'Địa chỉ',
    'pleaseSelectAddress': 'Vui lòng chọn địa chỉ',
    'salesStatus': 'Trạng thái bán hàng',
    'totalAmount': 'Tổng số tiền',
    'noProductsAddedYet': 'Chưa thêm sản phẩm nào',
    'price': 'Giá',
    'availableStock': 'Hàng tồn kho',
    'pleaseSelectCustomerFirst': 'Vui lòng chọn khách hàng trước',
    'searchSalesInvoices': 'Tìm hóa đơn bán hàng...',
    'noSalesInvoicesFound': 'Không tìm thấy hóa đơn bán hàng',
    'warrantyReceipt': 'Biên lai bảo hành #{id}',
    'warrantyInformation': 'Thông tin bảo hành',
    'status': 'Trạng thái',
    'reasonForWarranty': 'Lý do bảo hành',
    'productsUnderWarranty': 'Sản phẩm được bảo hành',
    'unknownCategory': 'Không xác định',
    'updateWarrantyStatus': 'Cập nhật trạng thái bảo hành',
    'confirmStatusUpdate': 'Xác nhận cập nhật trạng thái',
    'areYouSureChangeStatus':
        'Bạn có chắc chắn muốn thay đổi trạng thái thành {status}?',
    'save': 'Lưu',
    'updateStatus': 'Cập nhật trạng thái',
    'noSalesInvoicesAvailable': 'Không có hóa đơn bán hàng',
    'noEligibleSalesInvoices':
        'Khách hàng này không có hóa đơn bán hàng nào hợp lệ để yêu cầu bảo hành.',
    'pleaseSelectSalesInvoice': 'Vui lòng chọn hóa đơn bán hàng',
    'reasonForWarrantyLabel': 'Lý do bảo hành',
    'selectProductsForWarranty': 'Chọn sản phẩm để bảo hành',
    'warrantyInvoiceCreated': 'Tạo hóa đơn bảo hành thành công',
    'errorCreatingWarrantyInvoice': 'Lỗi tạo hóa đơn bảo hành: {error}',
    'product': 'Sản phẩm',
    'selectProduct': 'Chọn sản phẩm',
    'pleaseSelectProduct': 'Vui lòng chọn sản phẩm',
    'quantityGreaterThanZero': 'Số lượng phải lớn hơn 0',
    'notEnoughStock': 'Không đủ hàng tồn',
    'noAddressFound': 'Không tìm thấy địa chỉ nào',
    'date': 'Ngày',
    'subtotal': 'Tổng phụ',
    'editInvoice': 'Chỉnh sửa hóa đơn',
    'changeAddress': 'Thay đổi địa chỉ',
    'unknownProduct': 'Sản phẩm không xác định',
    'errorWithMessage': 'Lỗi: {error}',
    'errorLoadingInvoiceDetails': 'Lỗi tải chi tiết hóa đơn: {error}',
    'salesInvoice': 'Hóa đơn bán hàng',
    'loading': 'Đang tải...',
    'category': 'Danh mục',
    'enterAddress': 'Nhập địa chỉ',
    'findWarrantyInvoices': 'Tìm hóa đơn bảo hành...',
    'noWarrantyInvoicesFound': 'Không tìm thấy hóa đơn bảo hành',
    'markAsCompleted': 'Đánh dấu là đã hoàn thành',
    'errorLoadingWarrantyInvoiceDetails':
        'Lỗi khi tải chi tiết hóa đơn bảo hành: {error}',
    'sales': 'Bán hàng',
    'incoming': 'Nhập hàng',
    'warranty': 'Bảo hành',
    'hello': 'Xin chào!',
    'contactUs': 'Liên hệ:',
    'logOut': 'Đăng xuất',
    'home': 'Trang chủ',
    'invoice': 'Hóa đơn',
    'stakeholder': 'Đối tác',
    'voucher': 'Phiếu giảm giá',
    'profile': 'Hồ sơ',
    'addNewAddress': 'Thêm địa chỉ mới',
    'receiverName': 'Tên người nhận',
    'enterReceiverName': 'Nhập tên người nhận',
    'receiverPhone': 'Số điện thoại người nhận',
    'enterPhoneNumber': 'Nhập số điện thoại',
    'location': 'Địa chỉ',
    'streetAddress': 'Địa chỉ cụ thể',
    'streetNameBuildingHouseNo': 'Tên đường, tòa nhà, số nhà',
    'addAddress': 'Thêm địa chỉ',
    'customerDetail': 'Chi tiết khách hàng',
    'edit': 'Chỉnh sửa',
    'name': 'Tên',
    'email': 'Email',
    'phone': 'Số điện thoại',
    'addresses': 'Địa chỉ',
    'pleaseFillInAllRequiredFields': 'Vui lòng điền tất cả các trường bắt buộc',
    'discardChanges': 'Hủy bỏ thay đổi?',
    'unsavedChangesDiscard':
        'Bạn có thay đổi chưa lưu. Bạn có muốn hủy bỏ chúng?',
    'discard': 'BỎ QUA',
    'editCustomer': 'Chỉnh sửa khách hàng',
    'fullName': 'Họ và tên',
    'nameIsRequired': 'Tên là bắt buộc',
    'nameMin2Chars': 'Tên phải có ít nhất 2 ký tự',
    'phoneNumber': 'Số điện thoại',
    'phoneNumberIsRequired': 'Số điện thoại là bắt buộc',
    'pleaseEnterValidPhoneNumber': 'Vui lòng nhập số điện thoại hợp lệ',
    'addNewCustomer': 'Thêm khách hàng mới',
    'addCustomer': 'Thêm khách hàng',
    'pleaseFillInAllFields': 'Vui lòng điền tất cả các trường',
    'customerAddedSuccessfully': 'Khách hàng đã được thêm thành công',
    'findCustomers': 'Tìm kiếm khách hàng...',
    'noMatchingCustomersFound': 'Không tìm thấy khách hàng nào phù hợp',
    'employeeDetail': 'Chi tiết nhân viên',
    'employeeInformation': 'Thông tin nhân viên',
    'role': 'Chức vụ',
    'delete': 'Xóa',
    'deleteEmployee': 'Xóa nhân viên',
    'areYouSureDeleteEmployee': 'Bạn có chắc chắn muốn xóa nhân viên này?',
    'editEmployee': 'Chỉnh sửa nhân viên',
    'pleaseEnterName': 'Vui lòng nhập tên',
    'pleaseEnterPhoneNumber': 'Vui lòng nhập số điện thoại',
    'pleaseSelectRole': 'Vui lòng chọn vai trò',
    'addNewEmployee': 'Thêm nhân viên mới',
    'pleaseEnterEmail': 'Vui lòng nhập địa chỉ email',
    'filterByRole': 'Lọc theo vai trò',
    'clearFilter': 'Xóa bộ lọc',
    'findEmployees': 'Tìm kiếm nhân viên...',
    'noEmployeesFound': 'Không tìm thấy nhân viên nào',
    'employeeAddedSuccessfully': 'Nhân viên đã được thêm thành công',
    'manufacturerDetail': 'Chi tiết nhà cung cấp',
    'deactivate': 'Vô hiệu hóa',
    'activate': 'Kích hoạt',
    'deactivateManufacturer': 'Vô hiệu hóa nhà cung cấp',
    'activateManufacturer': 'Kích hoạt nhà cung cấp',
    'deactivateManufacturerConfirm':
        'Bạn có chắc chắn muốn vô hiệu hóa nhà cung cấp này?',
    'activateManufacturerConfirm':
        'Bạn có chắc chắn muốn kích hoạt nhà cung cấp này?',
    'inactive': 'Vô hiệu hóa',
    'manufacturerInformation': 'Thông tin nhà cung cấp',
    'manufacturerName': 'Tên nhà cung cấp',
    'editManufacturer': 'Chỉnh sửa nhà sản xuất',
    'addNewManufacturer': 'Thêm nhà sản xuất mới',
    'addManufacturer': 'Thêm nhà sản xuất',
    'findManufacturers': 'Tìm kiếm nhà sản xuất...',
    'noMatchingManufacturersFound': 'Không tìm thấy nhà sản xuất nào phù hợp',
    'deactivateManufacturerConfirmName':
        'Bạn có chắc chắn muốn vô hiệu hóa {name}?',
    'activateManufacturerConfirmName':
        'Bạn có chắc chắn muốn kích hoạt {name}?',
    'employees': 'Nhân viên',
    'vendors': 'Nhà cung cấp',
    'appAvatar': 'Biểu tượng ứng dụng',
    'createNewAccount': 'Tạo tài khoản mới',
    'alreadyHaveAccount': 'Đã có tài khoản?',
    'informationTitle': 'Thông tin',
    'aboutGizmoGlobe': 'Về GizmoGlobe',
    'aboutUsTitle': 'Về chúng tôi',
    'aboutUsContent':
        'GizmoGlobe là giải pháp phần cứng máy tính đáng tin cậy của bạn.',
    'ourMissionTitle': 'Sứ mệnh của chúng tôi',
    'ourMissionContent':
        'Cung cấp dịch vụ xuất sắc và sản phẩm chất lượng cho bạn, khách hàng thân yêu của chúng tôi.',
    'contactInformationTitle': 'Thông tin liên hệ',
    'contactInformationContent': 'Địa chỉ: UIT',
    'businessHoursTitle': 'Giờ làm việc',
    'businessHoursContent':
        'Thứ Hai - Thứ Sáu: 9:00 sáng - 6:00 chiều\nThứ Bảy: 10:00 sáng - 4:00 chiều\nChủ Nhật: Đóng cửa',
    'supportTitle': 'Hỗ trợ',
    'supportMembers': 'Thành viên nhóm',
    'supportRoleDeveloper': 'Lập trình viên',
    'supportStudentId': 'Mã số sinh viên: {id}',
    'supportRole': 'Vai trò: {role}',
    'supportEmail': 'Email: {email}',
    'accountSettings': 'Cài đặt tài khoản',
    'editProfile': 'Chỉnh sửa hồ sơ',
    'updatePersonalInfo': 'Cập nhật thông tin cá nhân',
    'changePassword': 'Đổi mật khẩu',
    'manageAccountSecurity': 'Quản lý bảo mật tài khoản của bạn',
    'signOut': 'Đăng xuất',
    'username': 'Tên người dùng',
    'saveChanges': 'Lưu thay đổi',
    'updateProfileSuccess': 'Cập nhật hồ sơ thành công',
    'passwordResetEmailWillBeSent':
        'Email đặt lại mật khẩu sẽ được gửi đến địa chỉ email của bạn',
    'passwordResetEmailSentSuccess':
        'Email đặt lại mật khẩu đã được gửi thành công',
    'sendPasswordResetEmail': 'Gửi email đặt lại mật khẩu',
    'noUserSignedIn': 'Không có người dùng đăng nhập',
    'addVoucher': 'Thêm voucher',
    'basicInformation': 'Thông tin cơ bản',
    'voucherName': 'Tên voucher',
    'minimumPurchase': 'Giá trị tối thiểu',
    'startTime': 'Thời gian bắt đầu',
    'maxUsagePerPerson': 'Số lần sử dụng tối đa mỗi người',
    'description': 'Mô tả',
    'voucherSettings': 'Cài đặt voucher',
    'discountType': 'Loại giảm giá',
    'fixedAmount': 'Số tiền cố định',
    'percentage': 'Phần trăm',
    'maximumDiscountValue': 'Giá trị giảm giá tối đa',
    'usageLimit': 'Giới hạn sử dụng',
    'unlimited': 'Không giới hạn',
    'limited': 'Có giới hạn',
    'maximumUsage': 'Số lần sử dụng tối đa',
    'usageLeft': 'Số lần còn lại',
    'timeLimit': 'Giới hạn thời gian',
    'noEndTime': 'Không có thời gian kết thúc',
    'hasEndTime': 'Có thời gian kết thúc',
    'endTime': 'Thời gian kết thúc',
    'voucherWillNotExpire': 'Voucher này sẽ không hết hạn',
    'visibility': 'Hiển thị',
    'hidden': 'Ẩn',
    'visible': 'Hiển thị',
    'disabled': 'Vô hiệu hóa',
    'enabled': 'Kích hoạt',
    'selectField': 'Chọn {field}',
    'enterField': 'Nhập {field}',
    'all': 'Tất cả',
    'ongoing': 'Khả dụng',
    'upcoming': 'Sắp đến',
    'noVouchersAvailable': 'Không có phiếu giảm giá nào khả dụng',
    'filter': 'Lọc',
    'from': 'Từ',
    'to': 'Đến',
    'min': 'Tối thiểu',
    'max': 'Tối đa',
    'paid': 'Đã thanh toán',
    'unpaid': 'Chưa thanh toán',
    'pending': 'Chờ xử lý',
    'preparing': 'Đang chuẩn bị',
    'shipping': 'Đang giao',
    'shipped': 'Đã giao',
    'completed': 'Đã hoàn thành',
    'cancelled': 'Đã hủy',
    'warrantyStatus_pending': 'Chờ xử lý',
    'warrantyStatus_processing': 'Đang xử lý',
    'warrantyStatus_completed': 'Đã hoàn thành',
    'warrantyStatus_denied': 'Từ chối',
    'success': 'Thành công',
    'failure': 'Thất bại',
    'signInSuccess': 'Đăng nhập thành công.',
    'signInFailed': 'Đăng nhập thất bại. Vui lòng thử lại.',
    'verificationLinkFailed':
        'Gửi liên kết xác minh thất bại. Vui lòng thử lại.',
    'changePasswordFailed': 'Lỗi thay đổi mật khẩu. Vui lòng thử lại.',
    'passwordsDoNotMatch': 'Mật khẩu không khớp.',
    'verificationEmailSent':
        'Một email xác minh đã được gửi đến địa chỉ email của bạn. Vui lòng xác minh email của bạn để hoàn tất việc đăng ký.',
    'signUpFailed': 'Đăng ký thất bại. Vui lòng thử lại.',
    'resetPasswordLinkSent':
        'Một liên kết xác minh đã được gửi đến địa chỉ email của bạn. Vui lòng xác minh email của bạn để đặt lại mật khẩu.',
    'signOutFailed': 'Đăng xuất thất bại. Vui lòng thử lại.',
    'emailNotVerified':
        'Email chưa được xác minh. Vui lòng xác minh email của bạn.',
    'invalidEmailOrPassword': 'Email hoặc mật khẩu không hợp lệ',
    'emailNotRegistered': 'Email này không được đăng ký trong hệ thống',
    'productAddedSuccess': 'Sản phẩm đã được thêm thành công.',
    'productAddFailed': 'Không thể thêm sản phẩm. Vui lòng thử lại.',
    'productUpdatedSuccess': 'Sản phẩm đã được cập nhật thành công.',
    'productUpdateFailed': 'Không thể cập nhật sản phẩm. Vui lòng thử lại.',
    'unexpectedError': 'Đã xảy ra lỗi không mong muốn. Vui lòng thử lại.',
    'chooseFromGallery': 'Chọn từ thư viện',
    'takePhoto': 'Chụp ảnh',
    'enterUrl': 'Nhập URL',
    'enterImageUrl': 'Nhập URL hình ảnh',
    'addProductImage': 'Thêm hình sản phẩm',
    'searchManufacturer': 'Tìm kiếm nhà sản xuất...',
    'active': 'Đang hoạt động',
    'outOfStock': 'Hết hàng',
    'discontinued': 'Ngừng kinh doanh',
    'categorySpecifications': 'Thông số cho',
    'ramBus': 'Bus RAM',
    'ramCapacity': 'Dung lượng RAM',
    'ramType': 'Loại RAM',
    'cpuFamily': 'Dòng CPU',
    'cpuCore': 'Số nhân CPU',
    'cpuThread': 'Số luồng CPU',
    'cpuClockSpeed': 'Tốc độ CPU',
    'psuWattage': 'Công suất PSU',
    'psuEfficiency': 'Hiệu suất PSU',
    'psuModular': 'PSU Modular',
    'gpuSeries': 'Dòng GPU',
    'gpuCapacity': 'Dung lượng GPU',
    'gpuBus': 'Bus GPU',
    'gpuClockSpeed': 'Tốc độ GPU',
    'formFactor': 'Kiểu dáng',
    'series': 'Dòng sản phẩm',
    'compatibility': 'Tương thích',
    'driveType': 'Loại ổ đĩa',
    'driveCapacity': 'Dung lượng ổ đĩa',
    'productName': 'Tên sản phẩm',
    'sellingPrice': 'Giá bán',
    'discount': 'Giảm giá',
    'stock': 'Tồn kho',
    'additionalInformation': 'Thông tin bổ sung',
    'releaseDate': 'Ngày phát hành',
    'manufacturer': 'Nhà sản xuất',
    'drive': 'Ổ cứng',
    'mainboard': 'Bo mạch chủ',
    'findProducts': 'Tìm kiếm sản phẩm...',
    'noProductsFound': 'Không tìm thấy sản phẩm nào',
    'releaseLatest': 'Ngày phát hành: Mới nhất',
    'releaseOldest': 'Ngày phát hành: Cũ nhất',
    'stockHighest': 'Hàng tồn kho: Cao nhất',
    'stockLowest': 'Hàng tồn kho: Thấp nhất',
    'salesHighest': 'Số lượng bán: Cao nhất',
    'salesLowest': 'Số lượng bán: Thấp nhất',
    'voucherAddedSuccess': 'Thêm phiếu giảm giá thành công.',
    'voucherAddFailed': 'Thêm phiếu giảm giá thất bại. Vui lòng thử lại.',
    'voucherDeletedSuccess': 'Xóa phiếu giảm giá thành công.',
    'voucherDeleteFailed': 'Xóa phiếu giảm giá thất bại. Vui lòng thử lại.',
    'errorLoadingVouchers': 'Không thể tải voucher. Vui lòng thử lại.',
    'errorUpdatingVoucher':
        'Cập nhật phiếu giảm giá thất bại. Vui lòng thử lại.',
    'generateDescriptionButton': 'Tạo mô tả',
    'translateDescriptionButton': 'Dịch mô tả',
    'enDescription': 'Mô tả tiếng Anh',
    'viDescription': 'Mô tả tiếng Việt',
    'descriptionGenerated': 'Mô tả được tạo thành công.',
    'voucherEditSuccess': 'Sửa phiếu giảm giá thành công.',
    'productDescription': 'Mô tả sản phẩm',
    'typeMessage': 'Nhập tin nhắn...',
    'selectConversation': 'Chọn cuộc trò chuyện',
    'messages': 'Tin nhắn',
    'noMessages': 'Không có tin nhắn',
    'reactivate': 'Kích hoạt lại',
    'discontinue': 'Ngừng kinh doanh',
    'pleaseFillRequiredFields': 'Vui lòng điền đầy đủ các trường bắt buộc',
    'roleOwner': 'Chủ sở hữu',
    'roleManager': 'Quản lý',
    'roleEmployee': 'Nhân viên',
    'appSettings': 'Cài đặt ứng dụng',
    'customizeAppPreferences': 'Tùy chỉnh cài đặt ứng dụng của bạn',
    'themeMode': 'Chế độ giao diện',
    'switchBetweenLightAndDark': 'Chuyển đổi giữa chế độ sáng và tối',
    'language': 'Ngôn ngữ',
    'changeAppLanguage': 'Thay đổi ngôn ngữ ứng dụng',
    'english': 'Tiếng Anh',
    'vietnamese': 'Tiếng Việt',
    'signIn': 'Đăng nhập',
    'signUp': 'Đăng ký',
    'forgotPassword': 'Quên mật khẩu?',
    'yourEmail': 'Email của bạn',
    'password': 'Mật khẩu',
    'authorizedByAdmin': 'Được phê duyệt bởi admin?',
    'passwordConfirmation': 'Xác nhận mật khẩu',
    'forgetPasswordTitle': 'Quên mật khẩu',
    'forgetPasswordDescription':
        'Đừng lo lắng! Điều này xảy ra. Vui lòng nhập email liên kết với tài khoản của bạn.',
    'emailAddress': 'Địa chỉ email',
    'enterYourEmailAddress': 'Nhập địa chỉ email của bạn',
    'sendVerificationLink': 'Gửi liên kết xác minh',
    'rememberYourPassword': 'Nhớ mật khẩu?',
    'ranOut': 'Đã hết',
    'maximumDiscount': 'Giảm giá tối đa',
    'discountValue': 'Giá trị giảm giá',
    'voucherUpdateSuccess': 'Cập nhật phiếu giảm giá thành công.',
    'voucherUpdateFailed':
        'Cập nhật phiếu giảm giá thất bại. Vui lòng thử lại.',
    'giftVouchers': 'Tặng phiếu giảm giá',
    'confirmation': 'Xác nhận',
    'confirmGiftVoucher':
        'Tặng phiếu giảm giá này cho khách hàng? Hành động này sẽ không thể hoàn tác.',
    'giveVoucherSuccess': 'Tặng phiếu giảm giá thành công.',
    'giveVoucherFailed': 'Tặng phiếu giảm giá thất bại. Vui lòng thử lại.',
    'starts': 'Bắt đầu',
    'expires': 'Kết thúc',
    'expired': 'Đã hết hạn',
    'addressAddedSuccess': 'Địa chỉ đã được thêm thành công.',
    'addressAddFailed': 'Không thể thêm địa chỉ. Vui lòng thử lại.',
    'addressUpdatedSuccess': 'Địa chỉ đã được cập nhật thành công.',
    'addressUpdateFailed': 'Không thể cập nhật địa chỉ. Vui lòng thử lại.',
    'editAddress': 'Chỉnh sửa địa chỉ',
    'saveAddress': 'Lưu địa chỉ',
  };

  String get appTitle => _getTranslation('appTitle');
  String get welcomeBack => _getTranslation('welcomeBack');
  String get overview => _getTranslation('overview');
  String get products => _getTranslation('products');
  String get customers => _getTranslation('customers');
  String get revenue => _getTranslation('revenue');
  String get avgIncome => _getTranslation('avgIncome');
  String get monthlySales => _getTranslation('monthlySales');
  String get last12Months => _getTranslation('last12Months');
  String get last3Months => _getTranslation('last3Months');
  String get newIncomingInvoice => _getTranslation('newIncomingInvoice');
  String get selectManufacturer => _getTranslation('selectManufacturer');
  String get addProduct => _getTranslation('addProduct');
  String get invoiceDetails => _getTranslation('invoiceDetails');
  String get importPrice => _getTranslation('importPrice');
  String get quantity => _getTranslation('quantity');
  String get totalPrice => _getTranslation('totalPrice');
  String get paymentStatus => _getTranslation('paymentStatus');
  String get createInvoice => _getTranslation('createInvoice');
  String get cancel => _getTranslation('cancel');
  String get add => _getTranslation('add');
  String get editProductDetail => _getTranslation('editProductDetail');
  String get update => _getTranslation('update');
  String get searchIncomingInvoices =>
      _getTranslation('searchIncomingInvoices');
  String get noIncomingInvoicesFound =>
      _getTranslation('noIncomingInvoicesFound');
  String get view => _getTranslation('view');
  String get editPayment => _getTranslation('editPayment');
  String get onlyUnpaidCanBeMarkedPaid =>
      _getTranslation('onlyUnpaidCanBeMarkedPaid');
  String get markAsPaidQuestion => _getTranslation('markAsPaidQuestion');
  String get confirm => _getTranslation('confirm');
  String get sortBy => _getTranslation('sortBy');
  String get dateNewestFirst => _getTranslation('dateNewestFirst');
  String get dateOldestFirst => _getTranslation('dateOldestFirst');
  String get priceHighestFirst => _getTranslation('priceHighestFirst');
  String get priceLowestFirst => _getTranslation('priceLowestFirst');
  String get errorOccurred => _getTranslation('errorOccurred');
  String get newInvoice => _getTranslation('newInvoice');
  String get customerInformation => _getTranslation('customerInformation');
  String get selectCustomer => _getTranslation('selectCustomer');
  String get customer => _getTranslation('customer');
  String get pleaseSelectCustomer => _getTranslation('pleaseSelectCustomer');
  String get address => _getTranslation('address');
  String get pleaseSelectAddress => _getTranslation('pleaseSelectAddress');
  String get salesStatus => _getTranslation('salesStatus');
  String get totalAmount => _getTranslation('totalAmount');
  String get noProductsAddedYet => _getTranslation('noProductsAddedYet');
  String get price => _getTranslation('price');
  String get availableStock => _getTranslation('availableStock');
  String get pleaseSelectCustomerFirst =>
      _getTranslation('pleaseSelectCustomerFirst');
  String get searchSalesInvoices => _getTranslation('searchSalesInvoices');
  String get noSalesInvoicesFound => _getTranslation('noSalesInvoicesFound');
  String get warrantyInformation => _getTranslation('warrantyInformation');
  String get status => _getTranslation('status');
  String get reasonForWarranty => _getTranslation('reasonForWarranty');
  String get productsUnderWarranty => _getTranslation('productsUnderWarranty');
  String get unknownCategory => _getTranslation('unknownCategory');
  String get updateWarrantyStatus => _getTranslation('updateWarrantyStatus');
  String get confirmStatusUpdate => _getTranslation('confirmStatusUpdate');
  String get save => _getTranslation('save');
  String get updateStatus => _getTranslation('updateStatus');
  String get noSalesInvoicesAvailable =>
      _getTranslation('noSalesInvoicesAvailable');
  String get noEligibleSalesInvoices =>
      _getTranslation('noEligibleSalesInvoices');
  String get pleaseSelectSalesInvoice =>
      _getTranslation('pleaseSelectSalesInvoice');
  String get reasonForWarrantyLabel =>
      _getTranslation('reasonForWarrantyLabel');
  String get selectProductsForWarranty =>
      _getTranslation('selectProductsForWarranty');
  String get warrantyInvoiceCreated =>
      _getTranslation('warrantyInvoiceCreated');
  String get product => _getTranslation('product');
  String get selectProduct => _getTranslation('selectProduct');
  String get pleaseSelectProduct => _getTranslation('pleaseSelectProduct');
  String get quantityGreaterThanZero =>
      _getTranslation('quantityGreaterThanZero');
  String get notEnoughStock => _getTranslation('notEnoughStock');
  String get noAddressFound => _getTranslation('noAddressFound');
  String get date => _getTranslation('date');
  String get subtotal => _getTranslation('subtotal');
  String get editInvoice => _getTranslation('editInvoice');
  String get changeAddress => _getTranslation('changeAddress');
  String get unknownProduct => _getTranslation('unknownProduct');
  String get salesInvoice => _getTranslation('salesInvoice');
  String get loading => _getTranslation('loading');
  String get category => _getTranslation('category');
  String get enterAddress => _getTranslation('enterAddress');
  String get findWarrantyInvoices => _getTranslation('findWarrantyInvoices');
  String get noWarrantyInvoicesFound =>
      _getTranslation('noWarrantyInvoicesFound');
  String get markAsCompleted => _getTranslation('markAsCompleted');
  String get sales => _getTranslation('sales');
  String get incoming => _getTranslation('incoming');
  String get warranty => _getTranslation('warranty');
  String get hello => _getTranslation('hello');
  String get contactUs => _getTranslation('contactUs');
  String get logOut => _getTranslation('logOut');
  String get home => _getTranslation('home');
  String get invoice => _getTranslation('invoice');
  String get stakeholder => _getTranslation('stakeholder');
  String get voucher => _getTranslation('voucher');
  String get profile => _getTranslation('profile');
  String get addNewAddress => _getTranslation('addNewAddress');
  String get receiverName => _getTranslation('receiverName');
  String get enterReceiverName => _getTranslation('enterReceiverName');
  String get receiverPhone => _getTranslation('receiverPhone');
  String get enterPhoneNumber => _getTranslation('enterPhoneNumber');
  String get location => _getTranslation('location');
  String get streetAddress => _getTranslation('streetAddress');
  String get streetNameBuildingHouseNo =>
      _getTranslation('streetNameBuildingHouseNo');
  String get addAddress => _getTranslation('addAddress');
  String get customerDetail => _getTranslation('customerDetail');
  String get edit => _getTranslation('edit');
  String get name => _getTranslation('name');
  String get email => _getTranslation('email');
  String get phone => _getTranslation('phone');
  String get addresses => _getTranslation('addresses');
  String get pleaseFillInAllRequiredFields =>
      _getTranslation('pleaseFillInAllRequiredFields');
  String get discardChanges => _getTranslation('discardChanges');
  String get unsavedChangesDiscard => _getTranslation('unsavedChangesDiscard');
  String get discard => _getTranslation('discard');
  String get editCustomer => _getTranslation('editCustomer');
  String get fullName => _getTranslation('fullName');
  String get nameIsRequired => _getTranslation('nameIsRequired');
  String get nameMin2Chars => _getTranslation('nameMin2Chars');
  String get phoneNumber => _getTranslation('phoneNumber');
  String get phoneNumberIsRequired => _getTranslation('phoneNumberIsRequired');
  String get pleaseEnterValidPhoneNumber =>
      _getTranslation('pleaseEnterValidPhoneNumber');
  String get addNewCustomer => _getTranslation('addNewCustomer');
  String get addCustomer => _getTranslation('addCustomer');
  String get pleaseFillInAllFields => _getTranslation('pleaseFillInAllFields');
  String get customerAddedSuccessfully =>
      _getTranslation('customerAddedSuccessfully');
  String get findCustomers => _getTranslation('findCustomers');
  String get noMatchingCustomersFound =>
      _getTranslation('noMatchingCustomersFound');
  String get employeeDetail => _getTranslation('employeeDetail');
  String get employeeInformation => _getTranslation('employeeInformation');
  String get role => _getTranslation('role');
  String get delete => _getTranslation('delete');
  String get deleteEmployee => _getTranslation('deleteEmployee');
  String get areYouSureDeleteEmployee =>
      _getTranslation('areYouSureDeleteEmployee');
  String get editEmployee => _getTranslation('editEmployee');
  String get pleaseEnterName => _getTranslation('pleaseEnterName');
  String get pleaseEnterPhoneNumber =>
      _getTranslation('pleaseEnterPhoneNumber');
  String get pleaseSelectRole => _getTranslation('pleaseSelectRole');
  String get addNewEmployee => _getTranslation('addNewEmployee');
  String get pleaseEnterEmail => _getTranslation('pleaseEnterEmail');
  String get filterByRole => _getTranslation('filterByRole');
  String get clearFilter => _getTranslation('clearFilter');
  String get findEmployees => _getTranslation('findEmployees');
  String get noEmployeesFound => _getTranslation('noEmployeesFound');
  String get employeeAddedSuccessfully =>
      _getTranslation('employeeAddedSuccessfully');
  String get manufacturerDetail => _getTranslation('manufacturerDetail');
  String get deactivate => _getTranslation('deactivate');
  String get activate => _getTranslation('activate');
  String get deactivateManufacturer =>
      _getTranslation('deactivateManufacturer');
  String get activateManufacturer => _getTranslation('activateManufacturer');
  String get deactivateManufacturerConfirm =>
      _getTranslation('deactivateManufacturerConfirm');
  String get activateManufacturerConfirm =>
      _getTranslation('activateManufacturerConfirm');
  String get inactive => _getTranslation('inactive');
  String get manufacturerInformation =>
      _getTranslation('manufacturerInformation');
  String get manufacturerName => _getTranslation('manufacturerName');
  String get editManufacturer => _getTranslation('editManufacturer');
  String get addNewManufacturer => _getTranslation('addNewManufacturer');
  String get addManufacturer => _getTranslation('addManufacturer');
  String get findManufacturers => _getTranslation('findManufacturers');
  String get noMatchingManufacturersFound =>
      _getTranslation('noMatchingManufacturersFound');
  String get employees => _getTranslation('employees');
  String get vendors => _getTranslation('vendors');
  String get appAvatar => _getTranslation('appAvatar');
  String get createNewAccount => _getTranslation('createNewAccount');
  String get alreadyHaveAccount => _getTranslation('alreadyHaveAccount');
  String get informationTitle => _getTranslation('informationTitle');
  String get aboutGizmoGlobe => _getTranslation('aboutGizmoGlobe');
  String get aboutUsTitle => _getTranslation('aboutUsTitle');
  String get aboutUsContent => _getTranslation('aboutUsContent');
  String get ourMissionTitle => _getTranslation('ourMissionTitle');
  String get ourMissionContent => _getTranslation('ourMissionContent');
  String get contactInformationTitle =>
      _getTranslation('contactInformationTitle');
  String get contactInformationContent =>
      _getTranslation('contactInformationContent');
  String get businessHoursTitle => _getTranslation('businessHoursTitle');
  String get businessHoursContent => _getTranslation('businessHoursContent');
  String get supportTitle => _getTranslation('supportTitle');
  String get supportMembers => _getTranslation('supportMembers');
  String get supportRoleDeveloper => _getTranslation('supportRoleDeveloper');
  String get accountSettings => _getTranslation('accountSettings');
  String get editProfile => _getTranslation('editProfile');
  String get updatePersonalInfo => _getTranslation('updatePersonalInfo');
  String get changePassword => _getTranslation('changePassword');
  String get manageAccountSecurity => _getTranslation('manageAccountSecurity');
  String get signOut => _getTranslation('signOut');
  String get username => _getTranslation('username');
  String get saveChanges => _getTranslation('saveChanges');
  String get updateProfileSuccess => _getTranslation('updateProfileSuccess');
  String get sendPasswordResetEmail =>
      _getTranslation('sendPasswordResetEmail');
  String get noUserSignedIn => _getTranslation('noUserSignedIn');
  String get addVoucher => _getTranslation('addVoucher');
  String get basicInformation => _getTranslation('basicInformation');
  String get voucherName => _getTranslation('voucherName');
  String get minimumPurchase => _getTranslation('minimumPurchase');
  String get startTime => _getTranslation('startTime');
  String get maxUsagePerPerson => _getTranslation('maxUsagePerPerson');
  String get description => _getTranslation('description');
  String get voucherSettings => _getTranslation('voucherSettings');
  String get discountType => _getTranslation('discountType');
  String get fixedAmount => _getTranslation('fixedAmount');
  String get percentage => _getTranslation('percentage');
  String get maximumDiscountValue => _getTranslation('maximumDiscountValue');
  String get usageLimit => _getTranslation('usageLimit');
  String get unlimited => _getTranslation('unlimited');
  String get limited => _getTranslation('limited');
  String get maximumUsage => _getTranslation('maximumUsage');
  String get usageLeft => _getTranslation('usageLeft');
  String get timeLimit => _getTranslation('timeLimit');
  String get noEndTime => _getTranslation('noEndTime');
  String get hasEndTime => _getTranslation('hasEndTime');
  String get endTime => _getTranslation('endTime');
  String get voucherWillNotExpire => _getTranslation('voucherWillNotExpire');
  String get visibility => _getTranslation('visibility');
  String get hidden => _getTranslation('hidden');
  String get visible => _getTranslation('visible');
  String get disabled => _getTranslation('disabled');
  String get enabled => _getTranslation('enabled');
  String get all => _getTranslation('all');
  String get ongoing => _getTranslation('ongoing');
  String get upcoming => _getTranslation('upcoming');
  String get noVouchersAvailable => _getTranslation('noVouchersAvailable');
  String get filter => _getTranslation('filter');
  String get from => _getTranslation('from');
  String get to => _getTranslation('to');
  String get min => _getTranslation('min');
  String get max => _getTranslation('max');
  String get paid => _getTranslation('paid');
  String get unpaid => _getTranslation('unpaid');
  String get pending => _getTranslation('pending');
  String get preparing => _getTranslation('preparing');
  String get shipping => _getTranslation('shipping');
  String get shipped => _getTranslation('shipped');
  String get completed => _getTranslation('completed');
  String get cancelled => _getTranslation('cancelled');
  String get warrantyStatus_pending =>
      _getTranslation('warrantyStatus_pending');
  String get warrantyStatus_processing =>
      _getTranslation('warrantyStatus_processing');
  String get warrantyStatus_completed =>
      _getTranslation('warrantyStatus_completed');
  String get warrantyStatus_denied => _getTranslation('warrantyStatus_denied');
  String get success => _getTranslation('success');
  String get failure => _getTranslation('failure');
  String get signInSuccess => _getTranslation('signInSuccess');
  String get signInFailed => _getTranslation('signInFailed');
  String get verificationLinkFailed =>
      _getTranslation('verificationLinkFailed');
  String get changePasswordFailed => _getTranslation('changePasswordFailed');
  String get passwordsDoNotMatch => _getTranslation('passwordsDoNotMatch');
  String get verificationEmailSent => _getTranslation('verificationEmailSent');
  String get signUpFailed => _getTranslation('signUpFailed');
  String get resetPasswordLinkSent => _getTranslation('resetPasswordLinkSent');
  String get signOutFailed => _getTranslation('signOutFailed');
  String get emailNotVerified => _getTranslation('emailNotVerified');
  String get invalidEmailOrPassword =>
      _getTranslation('invalidEmailOrPassword');
  String get emailNotRegistered => _getTranslation('emailNotRegistered');
  String get productAddedSuccess => _getTranslation('productAddedSuccess');
  String get productAddFailed => _getTranslation('productAddFailed');
  String get productUpdatedSuccess => _getTranslation('productUpdatedSuccess');
  String get productUpdateFailed => _getTranslation('productUpdateFailed');
  String get unexpectedError => _getTranslation('unexpectedError');
  String get chooseFromGallery => _getTranslation('chooseFromGallery');
  String get takePhoto => _getTranslation('takePhoto');
  String get enterUrl => _getTranslation('enterUrl');
  String get enterImageUrl => _getTranslation('enterImageUrl');
  String get addProductImage => _getTranslation('addProductImage');
  String get searchManufacturer => _getTranslation('searchManufacturer');
  String get active => _getTranslation('active');
  String get outOfStock => _getTranslation('outOfStock');
  String get discontinued => _getTranslation('discontinued');
  String get categorySpecifications =>
      _getTranslation('categorySpecifications');
  String get ramBus => _getTranslation('ramBus');
  String get ramCapacity => _getTranslation('ramCapacity');
  String get ramType => _getTranslation('ramType');
  String get cpuFamily => _getTranslation('cpuFamily');
  String get cpuCore => _getTranslation('cpuCore');
  String get cpuThread => _getTranslation('cpuThread');
  String get cpuClockSpeed => _getTranslation('cpuClockSpeed');
  String get psuWattage => _getTranslation('psuWattage');
  String get psuEfficiency => _getTranslation('psuEfficiency');
  String get psuModular => _getTranslation('psuModular');
  String get gpuSeries => _getTranslation('gpuSeries');
  String get gpuCapacity => _getTranslation('gpuCapacity');
  String get gpuBus => _getTranslation('gpuBus');
  String get gpuClockSpeed => _getTranslation('gpuClockSpeed');
  String get formFactor => _getTranslation('formFactor');
  String get series => _getTranslation('series');
  String get compatibility => _getTranslation('compatibility');
  String get driveType => _getTranslation('driveType');
  String get driveCapacity => _getTranslation('driveCapacity');
  String get productName => _getTranslation('productName');
  String get sellingPrice => _getTranslation('sellingPrice');
  String get discount => _getTranslation('discount');
  String get stock => _getTranslation('stock');
  String get additionalInformation => _getTranslation('additionalInformation');
  String get releaseDate => _getTranslation('releaseDate');
  String get manufacturer => _getTranslation('manufacturer');
  String get drive => _getTranslation('drive');
  String get mainboard => _getTranslation('mainboard');
  String get findProducts => _getTranslation('findProducts');
  String get noProductsFound => _getTranslation('noProductsFound');
  String get releaseLatest => _getTranslation('releaseLatest');
  String get releaseOldest => _getTranslation('releaseOldest');
  String get stockHighest => _getTranslation('stockHighest');
  String get stockLowest => _getTranslation('stockLowest');
  String get salesHighest => _getTranslation('salesHighest');
  String get salesLowest => _getTranslation('salesLowest');
  String get voucherAddedSuccess => _getTranslation('voucherAddedSuccess');
  String get voucherAddFailed => _getTranslation('voucherAddFailed');
  String get voucherDeletedSuccess => _getTranslation('voucherDeletedSuccess');
  String get voucherDeleteFailed => _getTranslation('voucherDeleteFailed');
  String get errorLoadingVouchers => _getTranslation('errorLoadingVouchers');
  String get errorUpdatingVoucher => _getTranslation('errorUpdatingVoucher');
  String get generateDescriptionButton =>
      _getTranslation('generateDescriptionButton');
  String get translateDescriptionButton =>
      _getTranslation('translateDescriptionButton');
  String get enDescription => _getTranslation('enDescription');
  String get viDescription => _getTranslation('viDescription');
  String get descriptionGenerated => _getTranslation('descriptionGenerated');
  String get voucherEditSuccess => _getTranslation('voucherEditSuccess');
  String get productDescription => _getTranslation('productDescription');
  String get typeMessage => _getTranslation('typeMessage');
  String get selectConversation => _getTranslation('selectConversation');
  String get messages => _getTranslation('messages');
  String get noMessages => _getTranslation('noMessages');
  String get reactivate => _getTranslation('reactivate');
  String get discontinue => _getTranslation('discontinue');
  String get pleaseFillRequiredFields =>
      _getTranslation('pleaseFillRequiredFields');
  String get roleOwner => _getTranslation('roleOwner');
  String get roleManager => _getTranslation('roleManager');
  String get roleEmployee => _getTranslation('roleEmployee');
  String get appSettings => _getTranslation('appSettings');
  String get customizeAppPreferences =>
      _getTranslation('customizeAppPreferences');
  String get themeMode => _getTranslation('themeMode');
  String get switchBetweenLightAndDark =>
      _getTranslation('switchBetweenLightAndDark');
  String get language => _getTranslation('language');
  String get changeAppLanguage => _getTranslation('changeAppLanguage');
  String get english => _getTranslation('english');
  String get vietnamese => _getTranslation('vietnamese');
  String get signIn => _getTranslation('signIn');
  String get signUp => _getTranslation('signUp');
  String get forgotPassword => _getTranslation('forgotPassword');
  String get yourEmail => _getTranslation('yourEmail');
  String get password => _getTranslation('password');
  String get authorizedByAdmin => _getTranslation('authorizedByAdmin');
  String get passwordConfirmation => _getTranslation('passwordConfirmation');
  String get rememberYourPassword => _getTranslation('rememberYourPassword');
  String get forgetPasswordTitle => _getTranslation('forgetPasswordTitle');
  String get forgetPasswordDescription =>
      _getTranslation('forgetPasswordDescription');
  String get emailAddress => _getTranslation('emailAddress');
  String get enterYourEmailAddress => _getTranslation('enterYourEmailAddress');
  String get sendVerificationLink => _getTranslation('sendVerificationLink');
  String get ranOut => _getTranslation('ranOut');
  String get maximumDiscount => _getTranslation('maximumDiscount');
  String get discountValue => _getTranslation('discountValue');
  String get voucherUpdateSuccess => _getTranslation('voucherUpdateSuccess');
  String get voucherUpdateFailed => _getTranslation('voucherUpdateFailed');
  String get giftVouchers => _getTranslation('giftVouchers');
  String get confirmation => _getTranslation('confirmation');
  String get confirmGiftVoucher => _getTranslation('confirmGiftVoucher');
  String get giveVoucherSuccess => _getTranslation('giveVoucherSuccess');
  String get giveVoucherFailed => _getTranslation('giveVoucherFailed');
  String get starts => _getTranslation('starts');
  String get expires => _getTranslation('expires');
  String get expired => _getTranslation('expired');
  String get addressAddedSuccess => _getTranslation('addressAddedSuccess');
  String get addressAddFailed => _getTranslation('addressAddFailed');
  String get addressUpdatedSuccess => _getTranslation('addressUpdatedSuccess');
  String get addressUpdateFailed => _getTranslation('addressUpdateFailed');
  String get editAddress => _getTranslation('editAddress');
  String get saveAddress => _getTranslation('saveAddress');

  // Methods with parameters
  String warrantyReceipt(String id) =>
      _getTranslation('warrantyReceipt').replaceAll('{id}', id);
  String areYouSureChangeStatus(String status) =>
      _getTranslation('areYouSureChangeStatus').replaceAll('{status}', status);
  String errorCreatingWarrantyInvoice(String error) =>
      _getTranslation('errorCreatingWarrantyInvoice')
          .replaceAll('{error}', error);
  String errorWithMessage(String error) =>
      _getTranslation('errorWithMessage').replaceAll('{error}', error);
  String errorLoadingInvoiceDetails(String error) =>
      _getTranslation('errorLoadingInvoiceDetails')
          .replaceAll('{error}', error);
  String errorLoadingWarrantyInvoiceDetails(String error) =>
      _getTranslation('errorLoadingWarrantyInvoiceDetails')
          .replaceAll('{error}', error);
  String passwordResetEmailWillBeSent(String email) =>
      _getTranslation('passwordResetEmailWillBeSent')
          .replaceAll('{email}', email);
  String passwordResetEmailSentSuccess(String email) =>
      _getTranslation('passwordResetEmailSentSuccess')
          .replaceAll('{email}', email);
  String supportStudentId(String id) =>
      _getTranslation('supportStudentId').replaceAll('{id}', id);
  String supportRole(String role) =>
      _getTranslation('supportRole').replaceAll('{role}', role);
  String supportEmail(String email) =>
      _getTranslation('supportEmail').replaceAll('{email}', email);
  String deactivateManufacturerConfirmName(String name) =>
      _getTranslation('deactivateManufacturerConfirmName')
          .replaceAll('{name}', name);
  String activateManufacturerConfirmName(String name) =>
      _getTranslation('activateManufacturerConfirmName')
          .replaceAll('{name}', name);
  String selectField(String field) =>
      _getTranslation('selectField').replaceAll('{field}', field);
  String enterField(String field) =>
      _getTranslation('enterField').replaceAll('{field}', field);

  String _getTranslation(String key) {
    final translations = locale.languageCode == 'vi' ? _vi : _en;
    return translations[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'vi'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Static S class to match existing UI pattern
class S {
  static AppLocalizations of(BuildContext context) {
    return AppLocalizations.of(context);
  }
}
