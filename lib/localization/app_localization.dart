import 'package:flutter/material.dart';

import 'en.dart';
import 'vi.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // English translations
  static const Map<String, String> _en = en;

  // Vietnamese translations
  static const Map<String, String> _vi = vi;

  String get appTitle => _getTranslation('appTitle');
  String get welcomeBack => _getTranslation('welcomeBack');
  String get overview => _getTranslation('overview');
  String get products => _getTranslation('products');
  String get customers => _getTranslation('customers');
  String get revenue => _getTranslation('revenue');
  String get avgIncome => _getTranslation('avgIncome');
  String get monthlySales => _getTranslation('monthlySales');
  String get dailySales => _getTranslation('dailySales');
  String get monthly => _getTranslation('monthly');
  String get daily => _getTranslation('daily');
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
  String get paymentMethod => _getTranslation('paymentMethod');
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
  String get noProductsAvailableForManufacturer =>
      _getTranslation('noProductsAvailableForManufacturer');
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
  String get unknown => _getTranslation('unknown');
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
  String get productInfoLoading => _getTranslation('productInfoLoading');
  String get category => _getTranslation('category');
  String get enterAddress => _getTranslation('enterAddress');
  String get createInvoiceSuccess => _getTranslation('createInvoiceSuccess');
  String get editInvoiceSuccess => _getTranslation('editInvoiceSuccess');
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
  String get employeeUpdatedSuccessfully =>
      _getTranslation('employeeUpdatedSuccessfully');
  String get employeeDeletedSuccessfully =>
      _getTranslation('employeeDeletedSuccessfully');
  String get customerUpdatedSuccessfully =>
      _getTranslation('customerUpdatedSuccessfully');
  String get manufacturerUpdatedSuccessfully =>
      _getTranslation('manufacturerUpdatedSuccessfully');
  String get manufacturerDeactivatedSuccessfully =>
      _getTranslation('manufacturerDeactivatedSuccessfully');
  String get manufacturerActivatedSuccessfully =>
      _getTranslation('manufacturerActivatedSuccessfully');
  String failedToToggleManufacturerStatus(String error) =>
      _getTranslation('failedToToggleManufacturerStatus')
          .replaceAll('{error}', error);
  String failedToUpdateManufacturer(String error) =>
      _getTranslation('failedToUpdateManufacturer')
          .replaceAll('{error}', error);
  String failedToUpdateEmployee(String error) =>
      _getTranslation('failedToUpdateEmployee').replaceAll('{error}', error);
  String failedToDeleteEmployee(String error) =>
      _getTranslation('failedToDeleteEmployee').replaceAll('{error}', error);
  String failedToUpdateCustomer(String error) =>
      _getTranslation('failedToUpdateCustomer').replaceAll('{error}', error);
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
  // Rating and Reply related
  String get reply => _getTranslation('reply');
  String get postReply => _getTranslation('postReply');
  String get replyPostedSuccessfully =>
      _getTranslation('replyPostedSuccessfully');
  String get loadMore => _getTranslation('loadMore');
  String get noItems => _getTranslation('noItems');
  String get newRatings => _getTranslation('newRatings');
  String get repliedRatings => _getTranslation('repliedRatings');
  String get ratingsAndReplies => _getTranslation('ratingsAndReplies');
  String get clickToManageImages => _getTranslation('clickToManageImages');
  String get manage => _getTranslation('manage');
  String get writeAReply => _getTranslation('writeAReply');
  String get from => _getTranslation('from');
  String get to => _getTranslation('to');
  String get min => _getTranslation('min');
  String get max => _getTranslation('max');
  String get paid => _getTranslation('paid');
  String get unpaid => _getTranslation('unpaid');
  String get pendingLabel => _getTranslation('pendingLabel');
  String get preparing => _getTranslation('preparing');
  String get shipping => _getTranslation('shipping');
  String get shipped => _getTranslation('shipped');
  String get received => _getTranslation('received');
  String get completed => _getTranslation('completed');
  String get cancelled => _getTranslation('cancelled');
  String get warrantyStatusPending => _getTranslation('warrantyStatusPending');
  String get warrantyStatusProcessing =>
      _getTranslation('warrantyStatusProcessing');
  String get warrantyStatusCompleted =>
      _getTranslation('warrantyStatusCompleted');
  String get warrantyStatusDenied => _getTranslation('warrantyStatusDenied');
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
  String get ratingsAndReviews => _getTranslation('ratingsAndReviews');
  String get reviews => _getTranslation('reviews');
  String get noRatingsYet => _getTranslation('noRatingsYet');
  String get showMore => _getTranslation('showMore');
  String get version => _getTranslation('version');
  String get memory => _getTranslation('memory');
  String get clockSpeed => _getTranslation('clockSpeed');
  String get tdp => _getTranslation('tdp');
  String get ioPorts => _getTranslation('ioPorts');
  String get cores => _getTranslation('cores');
  String get threads => _getTranslation('threads');
  String get baseClock => _getTranslation('baseClock');
  String get turboClock => _getTranslation('turboClock');
  String get socket => _getTranslation('socket');
  String get chipset => _getTranslation('chipset');
  String get ramSpec => _getTranslation('ramSpec');
  String get storage => _getTranslation('storage');
  String get pcieSlots => _getTranslation('pcieSlots');
  String get connectors => _getTranslation('connectors');
  String get efficiencyRating => _getTranslation('efficiencyRating');
  String get modularity => _getTranslation('modularity');
  String get clLatency => _getTranslation('clLatency');
  String get kitStickCount => _getTranslation('kitStickCount');
  String get capacityPerStick => _getTranslation('capacityPerStick');
  String get bus => _getTranslation('bus');
  String get type => _getTranslation('type');
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
  String get selectConversationToStart =>
      _getTranslation('selectConversationToStart');
  String get backToChatList => _getTranslation('backToChatList');
  String get messages => _getTranslation('messages');
  String get noMessages => _getTranslation('noMessages');
  String get manageProductImages => _getTranslation('manageProductImages');
  String get uploadImage => _getTranslation('uploadImage');
  String get addUrl => _getTranslation('addUrl');
  String get primary => _getTranslation('primary');
  String get pending => _getTranslation('pending');
  String get newLabel => _getTranslation('newLabel');
  String get pendingUpload => _getTranslation('pendingUpload');
  String get closeWithoutSaving => _getTranslation('closeWithoutSaving');
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
  String get chooseYear => _getTranslation('chooseYear');
  String get chooseMonth => _getTranslation('chooseMonth');
  String get selectMonth => _getTranslation('selectMonth');
  String get yearMonthly => _getTranslation('yearMonthly');
  String get monthDaily => _getTranslation('monthDaily');
  String get createIncomingInvoiceSuccess =>
      _getTranslation('createIncomingInvoiceSuccess');
  String get updateIncomingInvoiceSuccess =>
      _getTranslation('updateIncomingInvoiceSuccess');
  String get voucherUpdatedSuccess => _getTranslation('voucherUpdatedSuccess');
  String get warrantyInvoiceUpdatedSuccess =>
      _getTranslation('warrantyInvoiceUpdatedSuccess');
  String get editProduct => _getTranslation('editProduct');
  // Business Report
  String get businessReport => _getTranslation('businessReport');
  String get selectReportPeriod => _getTranslation('selectReportPeriod');
  String get period => _getTranslation('period');
  String get today => _getTranslation('today');
  String get thisWeek => _getTranslation('thisWeek');
  String get thisMonth => _getTranslation('thisMonth');
  String get thisYear => _getTranslation('thisYear');
  String get custom => _getTranslation('custom');
  String get startDate => _getTranslation('startDate');
  String get endDate => _getTranslation('endDate');
  String get selectStartDate => _getTranslation('selectStartDate');
  String get selectEndDate => _getTranslation('selectEndDate');
  String get selectedPeriod => _getTranslation('selectedPeriod');
  String get createReport => _getTranslation('createReport');
  String get generatingReport => _getTranslation('generatingReport');
  String get thisMayTakeFewMoments => _getTranslation('thisMayTakeFewMoments');
  String get reportGeneratedSuccess =>
      _getTranslation('reportGeneratedSuccess');
  String get errorGeneratingReport => _getTranslation('errorGeneratingReport');
  String get pleaseSelectValidDateRange =>
      _getTranslation('pleaseSelectValidDateRange');
  String get reportPeriod => _getTranslation('reportPeriod');
  String get executiveSummary => _getTranslation('executiveSummary');
  String get totalRevenue => _getTranslation('totalRevenue');
  String get totalCosts => _getTranslation('totalCosts');
  String get grossProfit => _getTranslation('grossProfit');
  String get profitMargin => _getTranslation('profitMargin');
  String get totalOrders => _getTranslation('totalOrders');
  String get averageOrderValue => _getTranslation('averageOrderValue');
  String get financialOverview => _getTranslation('financialOverview');
  String get revenueMetrics => _getTranslation('revenueMetrics');
  String get costMetrics => _getTranslation('costMetrics');
  String get salesAnalysis => _getTranslation('salesAnalysis');
  String get totalProducts => _getTranslation('totalProducts');
  String get totalCustomers => _getTranslation('totalCustomers');
  String get totalSalesInvoices => _getTranslation('totalSalesInvoices');
  String get totalIncomingInvoices => _getTranslation('totalIncomingInvoices');
  String get topProducts => _getTranslation('topProducts');
  String get productId => _getTranslation('productId');
  String get quantitySold => _getTranslation('quantitySold');
  String get salesByCategory => _getTranslation('salesByCategory');
  String get revenueBreakdown => _getTranslation('revenueBreakdown');
  String get revenueByCategory => _getTranslation('revenueByCategory');
  String get monthlyRevenue => _getTranslation('monthlyRevenue');
  String get costBreakdown => _getTranslation('costBreakdown');
  String get costOfGoodsSold => _getTranslation('costOfGoodsSold');
  String get operatingExpenses => _getTranslation('operatingExpenses');
  String get customerInsights => _getTranslation('customerInsights');
  String get newCustomers => _getTranslation('newCustomers');
  String get returningCustomers => _getTranslation('returningCustomers');
  String get customerRetentionRate => _getTranslation('customerRetentionRate');
  String get topCustomersBySpending =>
      _getTranslation('topCustomersBySpending');
  String get orders => _getTranslation('orders');
  String get totalSpending => _getTranslation('totalSpending');
  String get bestSellingProducts => _getTranslation('bestSellingProducts');
  String get topProductsByQuantity => _getTranslation('topProductsByQuantity');
  String get inventoryInsights => _getTranslation('inventoryInsights');
  String get totalStockValue => _getTranslation('totalStockValue');
  String get lowStockItems => _getTranslation('lowStockItems');
  String get currentStock => _getTranslation('currentStock');
  String get inventoryTurnoverRate => _getTranslation('inventoryTurnoverRate');
  String get salesTrends => _getTranslation('salesTrends');
  String get monthlySalesTrend => _getTranslation('monthlySalesTrend');
  String get month => _getTranslation('month');
  String get costs => _getTranslation('costs');
  String get profit => _getTranslation('profit');
  String get businessKPIs => _getTranslation('businessKPIs');
  String get averageItemsPerOrder => _getTranslation('averageItemsPerOrder');
  String get totalItemsSold => _getTranslation('totalItemsSold');
  String get conclusionInsights => _getTranslation('conclusionInsights');
  String get noSpecificInsights => _getTranslation('noSpecificInsights');
  String get strongProfitMargin => _getTranslation('strongProfitMargin');
  String get lowProfitMargin => _getTranslation('lowProfitMargin');
  String get goodCustomerRetention => _getTranslation('goodCustomerRetention');
  String get improveCustomerRetention =>
      _getTranslation('improveCustomerRetention');
  String get consistentRevenue => _getTranslation('consistentRevenue');
  String get reportGeneratedBy => _getTranslation('reportGeneratedBy');
  String get generatedOn => _getTranslation('generatedOn');
  String get cpuSeries => _getTranslation('cpuSeries');
  String get cpuSocket => _getTranslation('cpuSocket');
  String get cpuBaseClock => _getTranslation('cpuBaseClock');
  String get cpuTurboClock => _getTranslation('cpuTurboClock');
  String get cpuTdp => _getTranslation('cpuTdp');
  String get numberOfCpuCores => _getTranslation('numberOfCpuCores');
  String get numberOfCpuThreads => _getTranslation('numberOfCpuThreads');
  String get gpuVersion => _getTranslation('gpuVersion');
  String get gpuMemory => _getTranslation('gpuMemory');
  String get gpuTdp => _getTranslation('gpuTdp');
  String get gpuBoostClock => _getTranslation('gpuBoostClock');
  String get connectorType => _getTranslation('connectorType');
  String get addConnector => _getTranslation('addConnector');
  String get addIoPort => _getTranslation('addIoPort');
  String get addPcieSlot => _getTranslation('addPcieSlot');
  String get driveGeneration => _getTranslation('driveGeneration');
  String get chipsetCode => _getTranslation('chipsetCode');
  String get mainboardFormFactor => _getTranslation('mainboardFormFactor');
  String get supportedRamType => _getTranslation('supportedRamType');
  String get numberOfSataPorts => _getTranslation('numberOfSataPorts');
  String get numberOfM2Slots => _getTranslation('numberOfM2Slots');
  String get physicalSize => _getTranslation('physicalSize');
  String get electricalSpeed => _getTranslation('electricalSpeed');
  String get generation => _getTranslation('generation');
  String get interfaceType => _getTranslation('interfaceType');
  String get driveFormFactor => _getTranslation('driveFormFactor');
  String get maxWattage => _getTranslation('maxWattage');
  String get psuModularity => _getTranslation('psuModularity');
  String get port => _getTranslation('port');
  String get thisFieldIsRequired => _getTranslation('thisFieldIsRequired');
  String get ramBusSpeed => _getTranslation('ramBusSpeed');
  String get maximumSingleRamCapacity =>
      _getTranslation('maximumSingleRamCapacity');
  String get capacity => _getTranslation('capacity');
  String get readSpeed => _getTranslation('readSpeed');
  String get writeSpeed => _getTranslation('writeSpeed');
  String get select => _getTranslation('select');
  String get year => _getTranslation('year');
  String get generateBusinessReport =>
      _getTranslation('generateBusinessReport');
  String get noData => _getTranslation('noData');
  String get productCategoryDistribution =>
      _getTranslation('productCategoryDistribution');

  // Methods with parameters
  String lowStockAlert(int count) =>
      _getTranslation('lowStockAlert').replaceAll('{count}', count.toString());
  String consistentRevenueWithOrders(int orders) =>
      _getTranslation('consistentRevenue')
          .replaceAll('{orders}', orders.toString());

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
  String manufacturerAddedSuccessfully(String name) =>
      _getTranslation('manufacturerAddedSuccessfully')
          .replaceAll('{name}', name);
  String sendingVerificationLink(String email) =>
      _getTranslation('sendingVerificationLink').replaceAll('{email}', email);
  // Voucher distribution types
  String get distributionPublic => _getTranslation('distributionPublic');
  String get distributionRewards => _getTranslation('distributionRewards');
  String get distributionStaffIssued =>
      _getTranslation('distributionStaffIssued');
  String get refresh => _getTranslation('refresh');
  String get anonymous => _getTranslation('anonymous');
  String get numberOfRamSlots => _getTranslation('numberOfRamSlots');

  String rewardsFor(String points) =>
      _getTranslation('rewardsFor').replaceAll('{points}', points);

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
