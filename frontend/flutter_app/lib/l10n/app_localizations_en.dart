// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'DUBE NOTE';

  @override
  String get appTagline => 'PROFESSIONAL SHOP ASSISTANT';

  @override
  String get version => 'Version 0.0.1 (Beta Release)';

  @override
  String get copyright => '© 2024 WECAN TEAM';

  @override
  String get selectLanguage => 'SELECT YOUR LANGUAGE';

  @override
  String get continueBtn => 'CONTINUE';

  @override
  String get enterPasswordPrompt => 'ENTER PASSWORD TO ENTER';

  @override
  String get passwordHint => '••••••';

  @override
  String get accessDenied => 'Access Denied';

  @override
  String get enter => 'ENTER';

  @override
  String get forgotPassword => 'FORGOT PASSWORD?';

  @override
  String get recovery => 'RECOVERY';

  @override
  String get placeOfBirth => 'Place of Birth';

  @override
  String get yearShopOpened => 'Year Shop Opened';

  @override
  String get createNewPassword => 'Create New Password';

  @override
  String get cancel => 'CANCEL';

  @override
  String get reset => 'RESET';

  @override
  String get securityAnswersIncorrect => 'SECURITY ANSWERS INCORRECT';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get secureSetup => 'SECURE SETUP';

  @override
  String get masterPassword => 'Master Password';

  @override
  String get recoveryQuestions => 'RECOVERY QUESTIONS';

  @override
  String get recoveryHelperText =>
      'Make sure to use an answer you will remember. This will be required when recovering your password.';

  @override
  String get birthCity => 'Birth City';

  @override
  String get openingYear => 'Opening Year (Ethiopian)';

  @override
  String get setUpMyShop => 'Set Up My Shop';

  @override
  String get dataSecureNote =>
      'Your data is stored securely on this device only.';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordMinLength => 'Must be at least 4 characters';

  @override
  String get birthCityRequired => 'Birth city is required';

  @override
  String get yearRequired => 'Year is required';

  @override
  String get yearExactDigits => 'Must be exactly 4 digits';

  @override
  String get invalidYearFormat => 'Invalid year format';

  @override
  String yearFuture(int year) {
    return 'Cannot be in the future ($year E.C.)';
  }

  @override
  String yearTooOld(int year) {
    return 'Too far in the past (Min: $year)';
  }

  @override
  String get totalOutstanding => 'TOTAL OUTSTANDING';

  @override
  String get birr => 'Birr';

  @override
  String get activeCredit => 'Active Credit';

  @override
  String get pendingDebts => 'PENDING DEBTS';

  @override
  String customersCount(int count) {
    return '$count CUSTOMERS';
  }

  @override
  String get noCustomersFound => 'NO CUSTOMERS FOUND';

  @override
  String get newCustomer => 'NEW CUSTOMER';

  @override
  String get registerCustomer => 'REGISTER CUSTOMER';

  @override
  String get fullName => 'Full Name';

  @override
  String get setPaymentDeadline => 'Set Payment Deadline';

  @override
  String get register => 'REGISTER';

  @override
  String get noDeadlineSet => 'No deadline set';

  @override
  String dueDate(String date) {
    return 'Due $date';
  }

  @override
  String get overdue => 'OVERDUE';

  @override
  String get outstandingBalance => 'OUTSTANDING BALANCE';

  @override
  String get creditHistory => 'CREDIT HISTORY';

  @override
  String itemsCount(int count) {
    return '$count ITEMS';
  }

  @override
  String get noUnpaidItems => 'NO UNPAID ITEMS';

  @override
  String get addCredit => 'ADD CREDIT';

  @override
  String get settleAll => 'SETTLE ALL';

  @override
  String get settleDebt => 'SETTLE DEBT';

  @override
  String get markAllAsPaidConfirm =>
      'Mark all items as paid and move to history?';

  @override
  String get confirm => 'CONFIRM';

  @override
  String get deleteCustomer => 'DELETE CUSTOMER';

  @override
  String get deleteCustomerConfirm =>
      'Permanently delete this customer and all their transaction records? This cannot be undone.';

  @override
  String get delete => 'DELETE';

  @override
  String get editTransaction => 'EDIT TRANSACTION';

  @override
  String get deleteTransaction => 'DELETE TRANSACTION';

  @override
  String get deleteTransactionConfirm =>
      'Permanently delete this transaction? The customer balance will be updated.';

  @override
  String get markAsPaid => 'MARK AS PAID';

  @override
  String get markAsPaidConfirm =>
      'Mark this transaction as paid and move to history?';

  @override
  String get edit => 'Edit';

  @override
  String get deleteTx => 'Delete';

  @override
  String get payItem => 'Pay This';

  @override
  String get newCredit => 'NEW CREDIT';

  @override
  String get editCredit => 'EDIT CREDIT';

  @override
  String get whatWasTaken => 'What was taken?';

  @override
  String get qty => 'Qty';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get totalTransactionAmount => 'TOTAL TRANSACTION AMOUNT';

  @override
  String get saveToRecord => 'SAVE TO RECORD';

  @override
  String get updateRecord => 'UPDATE RECORD';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get negativeNotAllowed => 'Negative value is not allowed';

  @override
  String get paidRecords => 'PAID RECORDS';

  @override
  String get deletedCustomer => 'Deleted Customer';

  @override
  String paidOn(String date) {
    return 'Paid on: $date';
  }

  @override
  String get deleteRecord => 'DELETE RECORD?';

  @override
  String get deleteRecordConfirm =>
      'This will permanently remove this transaction from the history.';

  @override
  String get noTransactionHistory => 'NO TRANSACTION HISTORY';

  @override
  String get settings => 'SETTINGS';

  @override
  String get databaseManagement => 'DATABASE MANAGEMENT';

  @override
  String get exportLocalBackup => 'Export Local Backup';

  @override
  String get exportDescription => 'Securely export your credit database file.';

  @override
  String get databaseExportSuccess => 'Database exported successfully';

  @override
  String exportFailed(String error) {
    return 'Export failed: $error';
  }

  @override
  String get applicationInfo => 'APPLICATION INFO';

  @override
  String get securityEngine => 'Security Engine';

  @override
  String get localOnlyArchitecture => 'Local-only data architecture';

  @override
  String get language => 'Language';

  @override
  String get languageDescription => 'Change application language';

  @override
  String get changeLanguage => 'CHANGE LANGUAGE';

  @override
  String get changePassword => 'Change Password';

  @override
  String get changePasswordDescription => 'Update your access credentials';

  @override
  String quantityTimesPrice(int qty, String price) {
    return '$qty x Birr $price';
  }

  @override
  String birrAmount(String amount) {
    return 'Birr $amount';
  }

  @override
  String amountBirr(String amount) {
    return '$amount Birr';
  }

  @override
  String get roleShopOwner => 'Shop Owner';

  @override
  String get roleCustomer => 'Customer';

  @override
  String get selectRole => 'SELECT YOUR ROLE';

  @override
  String get customerPortal => 'CUSTOMER PORTAL';

  @override
  String get myTransactions => 'MY TRANSACTIONS';

  @override
  String get overallDeadline => 'OVERALL DEADLINE';

  @override
  String get shopNameLabel => 'Shop Name';

  @override
  String get shopPhone => 'Shop Phone';

  @override
  String get noTransactions => 'NO TRANSACTIONS RECORDED YET';

  @override
  String get dubebook => 'DUBEBOOK';

  @override
  String get secureCreditManagement => 'SECURE CREDIT MANAGEMENT';

  @override
  String get emailOrUsername => 'Email or Username';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'SIGN IN';

  @override
  String get newHere => 'New here? ';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinDubebook => 'JOIN DUBEBOOK';

  @override
  String get startManagingCredit => 'START MANAGING CREDIT SECURELY';

  @override
  String get retailer => 'RETAILER';

  @override
  String get customer => 'CUSTOMER';

  @override
  String get username => 'Username';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get createAccountBtn => 'CREATE ACCOUNT';

  @override
  String get haveAccount => 'Have an account? ';

  @override
  String get required => 'Required';

  @override
  String get myPortal => 'MY PORTAL';

  @override
  String get totalAggregateDebt => 'TOTAL AGGREGATE DEBT';

  @override
  String get myCreditAccounts => 'MY CREDIT ACCOUNTS';

  @override
  String get unknownShop => 'Unknown Shop';

  @override
  String get customers => 'CUSTOMERS';

  @override
  String get noCustomersFoundLower => 'No customers found';

  @override
  String get searchCustomers => 'Search customers...';

  @override
  String etbAmount(String amount) {
    return '$amount ETB';
  }

  @override
  String get activeSession => 'Active Session';

  @override
  String get noActiveCredit => 'No Active Credit';

  @override
  String get createYourShop => 'Create Your Shop';

  @override
  String get createYourShopDesc =>
      'You need a shop profile to begin registering customers and tracking credits.';

  @override
  String get createNewShop => 'Create New Shop';

  @override
  String get switchShop => 'SWITCH SHOP';

  @override
  String get addNewShop => 'Add New Shop';

  @override
  String get businessType => 'Business Type';

  @override
  String get create => 'Create';

  @override
  String get serverError => 'Server error';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get balance => 'BALANCE';

  @override
  String get totalDebt => 'TOTAL DEBT';

  @override
  String get walletBalancePositive => 'WALLET BALANCE (POSITIVE)';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get timeline => 'TIMELINE';

  @override
  String get payments => 'PAYMENTS';

  @override
  String get noPhone => 'NO PHONE';

  @override
  String get deleteCustomerAndRecords => 'Delete customer and all records?';

  @override
  String get noDeadline => 'No Deadline';

  @override
  String get paid => 'PAID';

  @override
  String get active => 'ACTIVE';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String remaining(String amount) {
    return 'REMAINING: $amount ETB';
  }

  @override
  String get addItem => 'Add Item';

  @override
  String get addNew => 'Add New';

  @override
  String get pay => 'Pay';

  @override
  String get sessionLimitWarning =>
      'A customer can have at most 2 active sessions. Settle a session to open a new one.';

  @override
  String get noCreditMatchesFilters => 'No credit history matches filters';

  @override
  String get noPaymentsMatchesFilters =>
      'No payments recorded matching filters';

  @override
  String get deleteItem => 'Delete Item';

  @override
  String get deleteItemConfirm =>
      'Are you sure you want to delete this item? Customer balance will be updated.';

  @override
  String get editItem => 'Edit Item';

  @override
  String get itemName => 'Item Name';

  @override
  String get byKg => 'By KG';

  @override
  String get byQuantity => 'By Quantity';

  @override
  String get weightKg => 'Weight (KG)';

  @override
  String get quantity => 'Quantity';

  @override
  String get pricePerKg => 'Price per KG';

  @override
  String get pricePerItem => 'Price per Item';

  @override
  String get pricePerKgEtb => 'Price per KG (ETB)';

  @override
  String get pricePerItemEtb => 'Price per Item (ETB)';

  @override
  String totalAmount(String amount) {
    return 'Total: $amount ETB';
  }

  @override
  String itemTotalAmount(String amount) {
    return 'Item Total: $amount ETB';
  }

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get addToBasket => 'Add to Basket';

  @override
  String get addItemToSession => 'Add Item to Session';

  @override
  String get raiseDispute => 'Raise a Dispute';

  @override
  String get complaintMessage => 'Complaint Message';

  @override
  String get complaintHint =>
      'Enter why you think this session amount is incorrect...';

  @override
  String get submitDispute => 'Submit Dispute';

  @override
  String get disputeSubmitted =>
      'Dispute submitted successfully to shop owner.';

  @override
  String get dispute => 'Dispute';

  @override
  String get updateDeadline => 'Update Deadline';

  @override
  String get cancelSession => 'Cancel Session';

  @override
  String get cancelSessionConfirm =>
      'This session will be marked as cancelled. This cannot be undone.';

  @override
  String get selectDate => 'Select Date';

  @override
  String get newCreditSession => 'NEW CREDIT SESSION';

  @override
  String get basketItems => 'BASKET ITEMS';

  @override
  String get deadlineOptional => 'DEADLINE (OPTIONAL)';

  @override
  String get selectDeadlineDate => 'Select Deadline Date';

  @override
  String get total => 'TOTAL';

  @override
  String get saveSession => 'SAVE SESSION';

  @override
  String get recordPayment => 'RECORD PAYMENT';

  @override
  String get paymentAmountEtb => 'Payment Amount (ETB)';

  @override
  String get paymentMethod => 'PAYMENT METHOD';

  @override
  String get cash => 'Cash';

  @override
  String get mobileMoney => 'Mobile Money';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get other => 'Other';

  @override
  String get noteOptional => 'Note (optional)';

  @override
  String get confirmPayment => 'CONFIRM PAYMENT';

  @override
  String get mustBeGreaterThanZero => 'Must be > 0';

  @override
  String get alerts => 'ALERTS';

  @override
  String get markAllAsRead => 'Mark all as read';

  @override
  String get clearReadNotifications => 'Clear read notifications';

  @override
  String get allNotificationsRead => 'All notifications marked as read';

  @override
  String get readNotificationsCleared => 'Read notifications cleared';

  @override
  String get allClear => 'All clear';

  @override
  String get noAlertsDescription =>
      'You have no alerts or notifications at this time.';

  @override
  String get alert => 'Alert';

  @override
  String get saasPlafform => 'SaaS PLATFORM';

  @override
  String due(String date) {
    return 'DUE $date';
  }

  @override
  String get account => 'ACCOUNT';

  @override
  String get shopDetails => 'SHOP DETAILS';

  @override
  String get editShopDetails => 'Edit Shop Details';

  @override
  String get preferences => 'PREFERENCES';

  @override
  String get dangerZone => 'DANGER ZONE';

  @override
  String get signOut => 'Sign Out';

  @override
  String get editShop => 'Edit Shop';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get address => 'Address';

  @override
  String get save => 'Save';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String updateProfileFailed(String error) {
    return 'Failed to update profile: $error';
  }
}
