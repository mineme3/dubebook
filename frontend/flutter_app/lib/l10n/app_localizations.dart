import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_om.dart';
import 'app_localizations_so.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('om'),
    Locale('so'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'DUBE NOTE'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'PROFESSIONAL SHOP ASSISTANT'**
  String get appTagline;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 0.0.1 (Beta Release)'**
  String get version;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2024 WECAN TEAM'**
  String get copyright;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'SELECT YOUR LANGUAGE'**
  String get selectLanguage;

  /// No description provided for @continueBtn.
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueBtn;

  /// No description provided for @enterPasswordPrompt.
  ///
  /// In en, this message translates to:
  /// **'ENTER PASSWORD TO ENTER'**
  String get enterPasswordPrompt;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'••••••'**
  String get passwordHint;

  /// No description provided for @accessDenied.
  ///
  /// In en, this message translates to:
  /// **'Access Denied'**
  String get accessDenied;

  /// No description provided for @enter.
  ///
  /// In en, this message translates to:
  /// **'ENTER'**
  String get enter;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'FORGOT PASSWORD?'**
  String get forgotPassword;

  /// No description provided for @recovery.
  ///
  /// In en, this message translates to:
  /// **'RECOVERY'**
  String get recovery;

  /// No description provided for @placeOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Place of Birth'**
  String get placeOfBirth;

  /// No description provided for @yearShopOpened.
  ///
  /// In en, this message translates to:
  /// **'Year Shop Opened'**
  String get yearShopOpened;

  /// No description provided for @createNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Create New Password'**
  String get createNewPassword;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'CANCEL'**
  String get cancel;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get reset;

  /// No description provided for @securityAnswersIncorrect.
  ///
  /// In en, this message translates to:
  /// **'SECURITY ANSWERS INCORRECT'**
  String get securityAnswersIncorrect;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successfully'**
  String get passwordResetSuccess;

  /// No description provided for @secureSetup.
  ///
  /// In en, this message translates to:
  /// **'SECURE SETUP'**
  String get secureSetup;

  /// No description provided for @masterPassword.
  ///
  /// In en, this message translates to:
  /// **'Master Password'**
  String get masterPassword;

  /// No description provided for @recoveryQuestions.
  ///
  /// In en, this message translates to:
  /// **'RECOVERY QUESTIONS'**
  String get recoveryQuestions;

  /// No description provided for @recoveryHelperText.
  ///
  /// In en, this message translates to:
  /// **'Make sure to use an answer you will remember. This will be required when recovering your password.'**
  String get recoveryHelperText;

  /// No description provided for @birthCity.
  ///
  /// In en, this message translates to:
  /// **'Birth City'**
  String get birthCity;

  /// No description provided for @openingYear.
  ///
  /// In en, this message translates to:
  /// **'Opening Year (Ethiopian)'**
  String get openingYear;

  /// No description provided for @setUpMyShop.
  ///
  /// In en, this message translates to:
  /// **'Set Up My Shop'**
  String get setUpMyShop;

  /// No description provided for @dataSecureNote.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored securely on this device only.'**
  String get dataSecureNote;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Must be at least 4 characters'**
  String get passwordMinLength;

  /// No description provided for @birthCityRequired.
  ///
  /// In en, this message translates to:
  /// **'Birth city is required'**
  String get birthCityRequired;

  /// No description provided for @yearRequired.
  ///
  /// In en, this message translates to:
  /// **'Year is required'**
  String get yearRequired;

  /// No description provided for @yearExactDigits.
  ///
  /// In en, this message translates to:
  /// **'Must be exactly 4 digits'**
  String get yearExactDigits;

  /// No description provided for @invalidYearFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid year format'**
  String get invalidYearFormat;

  /// No description provided for @yearFuture.
  ///
  /// In en, this message translates to:
  /// **'Cannot be in the future ({year} E.C.)'**
  String yearFuture(int year);

  /// No description provided for @yearTooOld.
  ///
  /// In en, this message translates to:
  /// **'Too far in the past (Min: {year})'**
  String yearTooOld(int year);

  /// No description provided for @totalOutstanding.
  ///
  /// In en, this message translates to:
  /// **'TOTAL OUTSTANDING'**
  String get totalOutstanding;

  /// No description provided for @birr.
  ///
  /// In en, this message translates to:
  /// **'Birr'**
  String get birr;

  /// No description provided for @activeCredit.
  ///
  /// In en, this message translates to:
  /// **'Active Credit'**
  String get activeCredit;

  /// No description provided for @pendingDebts.
  ///
  /// In en, this message translates to:
  /// **'PENDING DEBTS'**
  String get pendingDebts;

  /// No description provided for @customersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} CUSTOMERS'**
  String customersCount(int count);

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'NO CUSTOMERS FOUND'**
  String get noCustomersFound;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'NEW CUSTOMER'**
  String get newCustomer;

  /// No description provided for @registerCustomer.
  ///
  /// In en, this message translates to:
  /// **'REGISTER CUSTOMER'**
  String get registerCustomer;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @setPaymentDeadline.
  ///
  /// In en, this message translates to:
  /// **'Set Payment Deadline'**
  String get setPaymentDeadline;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get register;

  /// No description provided for @noDeadlineSet.
  ///
  /// In en, this message translates to:
  /// **'No deadline set'**
  String get noDeadlineSet;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due {date}'**
  String dueDate(String date);

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'OVERDUE'**
  String get overdue;

  /// No description provided for @outstandingBalance.
  ///
  /// In en, this message translates to:
  /// **'OUTSTANDING BALANCE'**
  String get outstandingBalance;

  /// No description provided for @creditHistory.
  ///
  /// In en, this message translates to:
  /// **'CREDIT HISTORY'**
  String get creditHistory;

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} ITEMS'**
  String itemsCount(int count);

  /// No description provided for @noUnpaidItems.
  ///
  /// In en, this message translates to:
  /// **'NO UNPAID ITEMS'**
  String get noUnpaidItems;

  /// No description provided for @addCredit.
  ///
  /// In en, this message translates to:
  /// **'ADD CREDIT'**
  String get addCredit;

  /// No description provided for @settleAll.
  ///
  /// In en, this message translates to:
  /// **'SETTLE ALL'**
  String get settleAll;

  /// No description provided for @settleDebt.
  ///
  /// In en, this message translates to:
  /// **'SETTLE DEBT'**
  String get settleDebt;

  /// No description provided for @markAllAsPaidConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark all items as paid and move to history?'**
  String get markAllAsPaidConfirm;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM'**
  String get confirm;

  /// No description provided for @deleteCustomer.
  ///
  /// In en, this message translates to:
  /// **'DELETE CUSTOMER'**
  String get deleteCustomer;

  /// No description provided for @deleteCustomerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this customer and all their transaction records? This cannot be undone.'**
  String get deleteCustomerConfirm;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'DELETE'**
  String get delete;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'EDIT TRANSACTION'**
  String get editTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'DELETE TRANSACTION'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete this transaction? The customer balance will be updated.'**
  String get deleteTransactionConfirm;

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'MARK AS PAID'**
  String get markAsPaid;

  /// No description provided for @markAsPaidConfirm.
  ///
  /// In en, this message translates to:
  /// **'Mark this transaction as paid and move to history?'**
  String get markAsPaidConfirm;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @deleteTx.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTx;

  /// No description provided for @payItem.
  ///
  /// In en, this message translates to:
  /// **'Pay This'**
  String get payItem;

  /// No description provided for @newCredit.
  ///
  /// In en, this message translates to:
  /// **'NEW CREDIT'**
  String get newCredit;

  /// No description provided for @editCredit.
  ///
  /// In en, this message translates to:
  /// **'EDIT CREDIT'**
  String get editCredit;

  /// No description provided for @whatWasTaken.
  ///
  /// In en, this message translates to:
  /// **'What was taken?'**
  String get whatWasTaken;

  /// No description provided for @qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get qty;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @totalTransactionAmount.
  ///
  /// In en, this message translates to:
  /// **'TOTAL TRANSACTION AMOUNT'**
  String get totalTransactionAmount;

  /// No description provided for @saveToRecord.
  ///
  /// In en, this message translates to:
  /// **'SAVE TO RECORD'**
  String get saveToRecord;

  /// No description provided for @updateRecord.
  ///
  /// In en, this message translates to:
  /// **'UPDATE RECORD'**
  String get updateRecord;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @negativeNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'Negative value is not allowed'**
  String get negativeNotAllowed;

  /// No description provided for @paidRecords.
  ///
  /// In en, this message translates to:
  /// **'PAID RECORDS'**
  String get paidRecords;

  /// No description provided for @deletedCustomer.
  ///
  /// In en, this message translates to:
  /// **'Deleted Customer'**
  String get deletedCustomer;

  /// No description provided for @paidOn.
  ///
  /// In en, this message translates to:
  /// **'Paid on: {date}'**
  String paidOn(String date);

  /// No description provided for @deleteRecord.
  ///
  /// In en, this message translates to:
  /// **'DELETE RECORD?'**
  String get deleteRecord;

  /// No description provided for @deleteRecordConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove this transaction from the history.'**
  String get deleteRecordConfirm;

  /// No description provided for @noTransactionHistory.
  ///
  /// In en, this message translates to:
  /// **'NO TRANSACTION HISTORY'**
  String get noTransactionHistory;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'SETTINGS'**
  String get settings;

  /// No description provided for @databaseManagement.
  ///
  /// In en, this message translates to:
  /// **'DATABASE MANAGEMENT'**
  String get databaseManagement;

  /// No description provided for @exportLocalBackup.
  ///
  /// In en, this message translates to:
  /// **'Export Local Backup'**
  String get exportLocalBackup;

  /// No description provided for @exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Securely export your credit database file.'**
  String get exportDescription;

  /// No description provided for @databaseExportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Database exported successfully'**
  String get databaseExportSuccess;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed: {error}'**
  String exportFailed(String error);

  /// No description provided for @applicationInfo.
  ///
  /// In en, this message translates to:
  /// **'APPLICATION INFO'**
  String get applicationInfo;

  /// No description provided for @securityEngine.
  ///
  /// In en, this message translates to:
  /// **'Security Engine'**
  String get securityEngine;

  /// No description provided for @localOnlyArchitecture.
  ///
  /// In en, this message translates to:
  /// **'Local-only data architecture'**
  String get localOnlyArchitecture;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageDescription.
  ///
  /// In en, this message translates to:
  /// **'Change application language'**
  String get languageDescription;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'CHANGE LANGUAGE'**
  String get changeLanguage;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @changePasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Update your access credentials'**
  String get changePasswordDescription;

  /// No description provided for @quantityTimesPrice.
  ///
  /// In en, this message translates to:
  /// **'{qty} x Birr {price}'**
  String quantityTimesPrice(int qty, String price);

  /// No description provided for @birrAmount.
  ///
  /// In en, this message translates to:
  /// **'Birr {amount}'**
  String birrAmount(String amount);

  /// No description provided for @amountBirr.
  ///
  /// In en, this message translates to:
  /// **'{amount} Birr'**
  String amountBirr(String amount);

  /// No description provided for @roleShopOwner.
  ///
  /// In en, this message translates to:
  /// **'Shop Owner'**
  String get roleShopOwner;

  /// No description provided for @roleCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get roleCustomer;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'SELECT YOUR ROLE'**
  String get selectRole;

  /// No description provided for @customerPortal.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER PORTAL'**
  String get customerPortal;

  /// No description provided for @myTransactions.
  ///
  /// In en, this message translates to:
  /// **'MY TRANSACTIONS'**
  String get myTransactions;

  /// No description provided for @overallDeadline.
  ///
  /// In en, this message translates to:
  /// **'OVERALL DEADLINE'**
  String get overallDeadline;

  /// No description provided for @shopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopNameLabel;

  /// No description provided for @shopPhone.
  ///
  /// In en, this message translates to:
  /// **'Shop Phone'**
  String get shopPhone;

  /// No description provided for @noTransactions.
  ///
  /// In en, this message translates to:
  /// **'NO TRANSACTIONS RECORDED YET'**
  String get noTransactions;

  /// No description provided for @dubebook.
  ///
  /// In en, this message translates to:
  /// **'DUBEBOOK'**
  String get dubebook;

  /// No description provided for @secureCreditManagement.
  ///
  /// In en, this message translates to:
  /// **'SECURE CREDIT MANAGEMENT'**
  String get secureCreditManagement;

  /// No description provided for @emailOrUsername.
  ///
  /// In en, this message translates to:
  /// **'Email or Username'**
  String get emailOrUsername;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN'**
  String get signIn;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here? '**
  String get newHere;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @joinDubebook.
  ///
  /// In en, this message translates to:
  /// **'JOIN DUBEBOOK'**
  String get joinDubebook;

  /// No description provided for @startManagingCredit.
  ///
  /// In en, this message translates to:
  /// **'START MANAGING CREDIT SECURELY'**
  String get startManagingCredit;

  /// No description provided for @retailer.
  ///
  /// In en, this message translates to:
  /// **'RETAILER'**
  String get retailer;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMER'**
  String get customer;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @createAccountBtn.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get createAccountBtn;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an account? '**
  String get haveAccount;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @myPortal.
  ///
  /// In en, this message translates to:
  /// **'MY PORTAL'**
  String get myPortal;

  /// No description provided for @totalAggregateDebt.
  ///
  /// In en, this message translates to:
  /// **'TOTAL AGGREGATE DEBT'**
  String get totalAggregateDebt;

  /// No description provided for @myCreditAccounts.
  ///
  /// In en, this message translates to:
  /// **'MY CREDIT ACCOUNTS'**
  String get myCreditAccounts;

  /// No description provided for @unknownShop.
  ///
  /// In en, this message translates to:
  /// **'Unknown Shop'**
  String get unknownShop;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'CUSTOMERS'**
  String get customers;

  /// No description provided for @noCustomersFoundLower.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFoundLower;

  /// No description provided for @searchCustomers.
  ///
  /// In en, this message translates to:
  /// **'Search customers...'**
  String get searchCustomers;

  /// No description provided for @etbAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} ETB'**
  String etbAmount(String amount);

  /// No description provided for @activeSession.
  ///
  /// In en, this message translates to:
  /// **'Active Session'**
  String get activeSession;

  /// No description provided for @noActiveCredit.
  ///
  /// In en, this message translates to:
  /// **'No Active Credit'**
  String get noActiveCredit;

  /// No description provided for @createYourShop.
  ///
  /// In en, this message translates to:
  /// **'Create Your Shop'**
  String get createYourShop;

  /// No description provided for @createYourShopDesc.
  ///
  /// In en, this message translates to:
  /// **'You need a shop profile to begin registering customers and tracking credits.'**
  String get createYourShopDesc;

  /// No description provided for @createNewShop.
  ///
  /// In en, this message translates to:
  /// **'Create New Shop'**
  String get createNewShop;

  /// No description provided for @switchShop.
  ///
  /// In en, this message translates to:
  /// **'SWITCH SHOP'**
  String get switchShop;

  /// No description provided for @addNewShop.
  ///
  /// In en, this message translates to:
  /// **'Add New Shop'**
  String get addNewShop;

  /// No description provided for @businessType.
  ///
  /// In en, this message translates to:
  /// **'Business Type'**
  String get businessType;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @serverError.
  ///
  /// In en, this message translates to:
  /// **'Server error'**
  String get serverError;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'BALANCE'**
  String get balance;

  /// No description provided for @totalDebt.
  ///
  /// In en, this message translates to:
  /// **'TOTAL DEBT'**
  String get totalDebt;

  /// No description provided for @walletBalancePositive.
  ///
  /// In en, this message translates to:
  /// **'WALLET BALANCE (POSITIVE)'**
  String get walletBalancePositive;

  /// No description provided for @startDate.
  ///
  /// In en, this message translates to:
  /// **'Start Date'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In en, this message translates to:
  /// **'End Date'**
  String get endDate;

  /// No description provided for @timeline.
  ///
  /// In en, this message translates to:
  /// **'TIMELINE'**
  String get timeline;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'PAYMENTS'**
  String get payments;

  /// No description provided for @noPhone.
  ///
  /// In en, this message translates to:
  /// **'NO PHONE'**
  String get noPhone;

  /// No description provided for @deleteCustomerAndRecords.
  ///
  /// In en, this message translates to:
  /// **'Delete customer and all records?'**
  String get deleteCustomerAndRecords;

  /// No description provided for @noDeadline.
  ///
  /// In en, this message translates to:
  /// **'No Deadline'**
  String get noDeadline;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'PAID'**
  String get paid;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get active;

  /// No description provided for @paymentReceived.
  ///
  /// In en, this message translates to:
  /// **'Payment Received'**
  String get paymentReceived;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'REMAINING: {amount} ETB'**
  String remaining(String amount);

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @addNew.
  ///
  /// In en, this message translates to:
  /// **'Add New'**
  String get addNew;

  /// No description provided for @pay.
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// No description provided for @sessionLimitWarning.
  ///
  /// In en, this message translates to:
  /// **'A customer can have at most 2 active sessions. Settle a session to open a new one.'**
  String get sessionLimitWarning;

  /// No description provided for @noCreditMatchesFilters.
  ///
  /// In en, this message translates to:
  /// **'No credit history matches filters'**
  String get noCreditMatchesFilters;

  /// No description provided for @noPaymentsMatchesFilters.
  ///
  /// In en, this message translates to:
  /// **'No payments recorded matching filters'**
  String get noPaymentsMatchesFilters;

  /// No description provided for @deleteItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Item'**
  String get deleteItem;

  /// No description provided for @deleteItemConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item? Customer balance will be updated.'**
  String get deleteItemConfirm;

  /// No description provided for @editItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editItem;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @byKg.
  ///
  /// In en, this message translates to:
  /// **'By KG'**
  String get byKg;

  /// No description provided for @byQuantity.
  ///
  /// In en, this message translates to:
  /// **'By Quantity'**
  String get byQuantity;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (KG)'**
  String get weightKg;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @pricePerKg.
  ///
  /// In en, this message translates to:
  /// **'Price per KG'**
  String get pricePerKg;

  /// No description provided for @pricePerItem.
  ///
  /// In en, this message translates to:
  /// **'Price per Item'**
  String get pricePerItem;

  /// No description provided for @pricePerKgEtb.
  ///
  /// In en, this message translates to:
  /// **'Price per KG (ETB)'**
  String get pricePerKgEtb;

  /// No description provided for @pricePerItemEtb.
  ///
  /// In en, this message translates to:
  /// **'Price per Item (ETB)'**
  String get pricePerItemEtb;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total: {amount} ETB'**
  String totalAmount(String amount);

  /// No description provided for @itemTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Item Total: {amount} ETB'**
  String itemTotalAmount(String amount);

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @addToBasket.
  ///
  /// In en, this message translates to:
  /// **'Add to Basket'**
  String get addToBasket;

  /// No description provided for @addItemToSession.
  ///
  /// In en, this message translates to:
  /// **'Add Item to Session'**
  String get addItemToSession;

  /// No description provided for @raiseDispute.
  ///
  /// In en, this message translates to:
  /// **'Raise a Dispute'**
  String get raiseDispute;

  /// No description provided for @complaintMessage.
  ///
  /// In en, this message translates to:
  /// **'Complaint Message'**
  String get complaintMessage;

  /// No description provided for @complaintHint.
  ///
  /// In en, this message translates to:
  /// **'Enter why you think this session amount is incorrect...'**
  String get complaintHint;

  /// No description provided for @submitDispute.
  ///
  /// In en, this message translates to:
  /// **'Submit Dispute'**
  String get submitDispute;

  /// No description provided for @disputeSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Dispute submitted successfully to shop owner.'**
  String get disputeSubmitted;

  /// No description provided for @dispute.
  ///
  /// In en, this message translates to:
  /// **'Dispute'**
  String get dispute;

  /// No description provided for @updateDeadline.
  ///
  /// In en, this message translates to:
  /// **'Update Deadline'**
  String get updateDeadline;

  /// No description provided for @cancelSession.
  ///
  /// In en, this message translates to:
  /// **'Cancel Session'**
  String get cancelSession;

  /// No description provided for @cancelSessionConfirm.
  ///
  /// In en, this message translates to:
  /// **'This session will be marked as cancelled. This cannot be undone.'**
  String get cancelSessionConfirm;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @newCreditSession.
  ///
  /// In en, this message translates to:
  /// **'NEW CREDIT SESSION'**
  String get newCreditSession;

  /// No description provided for @basketItems.
  ///
  /// In en, this message translates to:
  /// **'BASKET ITEMS'**
  String get basketItems;

  /// No description provided for @deadlineOptional.
  ///
  /// In en, this message translates to:
  /// **'DEADLINE (OPTIONAL)'**
  String get deadlineOptional;

  /// No description provided for @selectDeadlineDate.
  ///
  /// In en, this message translates to:
  /// **'Select Deadline Date'**
  String get selectDeadlineDate;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'TOTAL'**
  String get total;

  /// No description provided for @saveSession.
  ///
  /// In en, this message translates to:
  /// **'SAVE SESSION'**
  String get saveSession;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'RECORD PAYMENT'**
  String get recordPayment;

  /// No description provided for @paymentAmountEtb.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount (ETB)'**
  String get paymentAmountEtb;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'PAYMENT METHOD'**
  String get paymentMethod;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @mobileMoney.
  ///
  /// In en, this message translates to:
  /// **'Mobile Money'**
  String get mobileMoney;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @confirmPayment.
  ///
  /// In en, this message translates to:
  /// **'CONFIRM PAYMENT'**
  String get confirmPayment;

  /// No description provided for @mustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Must be > 0'**
  String get mustBeGreaterThanZero;

  /// No description provided for @alerts.
  ///
  /// In en, this message translates to:
  /// **'ALERTS'**
  String get alerts;

  /// No description provided for @markAllAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get markAllAsRead;

  /// No description provided for @clearReadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Clear read notifications'**
  String get clearReadNotifications;

  /// No description provided for @allNotificationsRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get allNotificationsRead;

  /// No description provided for @readNotificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'Read notifications cleared'**
  String get readNotificationsCleared;

  /// No description provided for @allClear.
  ///
  /// In en, this message translates to:
  /// **'All clear'**
  String get allClear;

  /// No description provided for @noAlertsDescription.
  ///
  /// In en, this message translates to:
  /// **'You have no alerts or notifications at this time.'**
  String get noAlertsDescription;

  /// No description provided for @alert.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get alert;

  /// No description provided for @saasPlafform.
  ///
  /// In en, this message translates to:
  /// **'SaaS PLATFORM'**
  String get saasPlafform;

  /// No description provided for @due.
  ///
  /// In en, this message translates to:
  /// **'DUE {date}'**
  String due(String date);

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'ACCOUNT'**
  String get account;

  /// No description provided for @shopDetails.
  ///
  /// In en, this message translates to:
  /// **'SHOP DETAILS'**
  String get shopDetails;

  /// No description provided for @editShopDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Shop Details'**
  String get editShopDetails;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'PREFERENCES'**
  String get preferences;

  /// No description provided for @dangerZone.
  ///
  /// In en, this message translates to:
  /// **'DANGER ZONE'**
  String get dangerZone;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @editShop.
  ///
  /// In en, this message translates to:
  /// **'Edit Shop'**
  String get editShop;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @updateProfileFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile: {error}'**
  String updateProfileFailed(String error);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en', 'om', 'so'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'om':
      return AppLocalizationsOm();
    case 'so':
      return AppLocalizationsSo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
