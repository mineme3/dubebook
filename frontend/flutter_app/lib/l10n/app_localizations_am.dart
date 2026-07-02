// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Amharic (`am`).
class AppLocalizationsAm extends AppLocalizations {
  AppLocalizationsAm([String locale = 'am']) : super(locale);

  @override
  String get appName => 'ዱቤ ማስታወሻ';

  @override
  String get appTagline => 'ባለሙያ የሱቅ ረዳት';

  @override
  String get version => 'ስሪት 0.0.1 (ቅድመ-ልቀት)';

  @override
  String get copyright => '© 2024 WECAN TEAM';

  @override
  String get selectLanguage => 'ቋንቋ ይምረጡ';

  @override
  String get continueBtn => 'ቀጥል';

  @override
  String get enterPasswordPrompt => 'ለመግባት የይለፍ ቃል ያስገቡ';

  @override
  String get passwordHint => '••••••';

  @override
  String get accessDenied => 'ገንቢ ተከልክሏል';

  @override
  String get enter => 'ግባ';

  @override
  String get forgotPassword => 'የይለፍ ቃል ረስተዋል?';

  @override
  String get recovery => 'መልሶ ማግኘት';

  @override
  String get placeOfBirth => 'የትውልድ ቦታ';

  @override
  String get yearShopOpened => 'ሱቅ የተከፈተበት ዓመት';

  @override
  String get createNewPassword => 'አዲስ የይለፍ ቃል ፍጠር';

  @override
  String get cancel => 'ሰርዝ';

  @override
  String get reset => 'ዳግም አስጀምር';

  @override
  String get securityAnswersIncorrect => 'የጥበቃ መልሶች ትክክል አይደሉም';

  @override
  String get passwordResetSuccess => 'የይለፍ ቃል በተሳካ ሁኔታ ተቀይሯል';

  @override
  String get secureSetup => 'ደህንነት ማዋቀር';

  @override
  String get masterPassword => 'ዋና የይለፍ ቃል';

  @override
  String get recoveryQuestions => 'የማግኛ ጥያቄዎች';

  @override
  String get recoveryHelperText =>
      'ዳግም ሊያስታውሱት የሚችሉትን መልስ መጠቀምዎን ያረጋግጡ። ይህ የይለፍ ቃልዎን መልሰው ሲያገኙ ያስፈልጋል።';

  @override
  String get birthCity => 'የትውልድ ከተማ';

  @override
  String get openingYear => 'የመክፈቻ ዓመት (ኢትዮጵያ)';

  @override
  String get setUpMyShop => 'ሱቄን አዋቅር';

  @override
  String get dataSecureNote => 'መረጃዎ በዚህ መሣሪያ ላይ ብቻ ተከማችቷል።';

  @override
  String get passwordRequired => 'የይለፍ ቃል ያስፈልጋል';

  @override
  String get passwordMinLength => 'ቢያንስ 4 ቁምፊዎች መሆን አለበት';

  @override
  String get birthCityRequired => 'የትውልድ ከተማ ያስፈልጋል';

  @override
  String get yearRequired => 'ዓመት ያስፈልጋል';

  @override
  String get yearExactDigits => 'በትክክል 4 አሃዞች መሆን አለበት';

  @override
  String get invalidYearFormat => 'ልክ ያልሆነ ዓመት ቅርጸት';

  @override
  String yearFuture(int year) {
    return 'ወደፊት ሊሆን አይችልም ($year ዓ.ም.)';
  }

  @override
  String yearTooOld(int year) {
    return 'በጣም ያረጀ (ዝቅተኛ: $year)';
  }

  @override
  String get totalOutstanding => 'ጠቅላላ ያልተከፈለ';

  @override
  String get birr => 'ብር';

  @override
  String get activeCredit => 'ንቁ ብድር';

  @override
  String get pendingDebts => 'ያልተከፈሉ ዕዳዎች';

  @override
  String customersCount(int count) {
    return '$count ደንበኞች';
  }

  @override
  String get noCustomersFound => 'ደንበኞች አልተገኙም';

  @override
  String get newCustomer => 'አዲስ ደንበኛ';

  @override
  String get registerCustomer => 'ደንበኛ ይመዝገቡ';

  @override
  String get fullName => 'ሙሉ ስም';

  @override
  String get setPaymentDeadline => 'የክፍያ ግዜ ያዘጋጁ';

  @override
  String get register => 'መዝግብ';

  @override
  String get noDeadlineSet => 'ግዜ አልተዘጋጀም';

  @override
  String dueDate(String date) {
    return 'ቀነ-ገደብ $date';
  }

  @override
  String get overdue => 'ጊዜው ያለፈ';

  @override
  String get outstandingBalance => 'ያልተከፈለ ቀሪ ሂሳብ';

  @override
  String get creditHistory => 'የብድር ታሪክ';

  @override
  String itemsCount(int count) {
    return '$count ዕቃዎች';
  }

  @override
  String get noUnpaidItems => 'ያልተከፈሉ ዕቃዎች የሉም';

  @override
  String get addCredit => 'ብድር ጨምር';

  @override
  String get settleAll => 'ሁሉንም ክፈል';

  @override
  String get settleDebt => 'ዕዳ ክፈል';

  @override
  String get markAllAsPaidConfirm => 'ሁሉንም ዕቃዎች እንደ ተከፈለ ምልክት ማድረግ ይፈልጋሉ?';

  @override
  String get confirm => 'አረጋግጥ';

  @override
  String get deleteCustomer => 'ደንበኛ ሰርዝ';

  @override
  String get deleteCustomerConfirm =>
      'ይህን ደንበኛና ሁሉንም የግብይት ሪከርዶቻቸውን እስከመጨረሻው ይሰርዛል? ይህ ሊቀለበስ አይችልም።';

  @override
  String get delete => 'ሰርዝ';

  @override
  String get editTransaction => 'ግብይት አስተካክል';

  @override
  String get deleteTransaction => 'ግብይት ሰርዝ';

  @override
  String get deleteTransactionConfirm =>
      'ይህን ግብይት እስከመጨረሻው ይሰርዛል? የደንበኛው ቀሪ ሂሳብ ይዘምናል።';

  @override
  String get markAsPaid => 'ተከፍሏል ምልክት አድርግ';

  @override
  String get markAsPaidConfirm => 'ይህን ግብይት ተከፍሏል ብለው ምልክት ያድርጉ?';

  @override
  String get edit => 'አስተካክል';

  @override
  String get deleteTx => 'ሰርዝ';

  @override
  String get payItem => 'ይህን ክፈል';

  @override
  String get newCredit => 'አዲስ ብድር';

  @override
  String get editCredit => 'ብድር አስተካክል';

  @override
  String get whatWasTaken => 'ምን ተወሰደ?';

  @override
  String get qty => 'ብዛት';

  @override
  String get unitPrice => 'የአንዱ ዋጋ';

  @override
  String get totalTransactionAmount => 'ጠቅላላ የግብይት መጠን';

  @override
  String get saveToRecord => 'ወደ ሪከርድ አስቀምጥ';

  @override
  String get updateRecord => 'ሪከርድ አዘምን';

  @override
  String get fieldRequired => 'ይህ መስክ ያስፈልጋል';

  @override
  String get negativeNotAllowed => 'አሉታዊ ዋጋ አይፈቀድም';

  @override
  String get paidRecords => 'የተከፈሉ ሪከርዶች';

  @override
  String get deletedCustomer => 'የተሰረዘ ደንበኛ';

  @override
  String paidOn(String date) {
    return 'የተከፈለ: $date';
  }

  @override
  String get deleteRecord => 'ሪከርድ ይሰረዝ?';

  @override
  String get deleteRecordConfirm => 'ይህ ግብይት ከታሪክ ዘላቂ ይሰረዛል።';

  @override
  String get noTransactionHistory => 'የግብይት ታሪክ የለም';

  @override
  String get settings => 'ቅንብሮች';

  @override
  String get databaseManagement => 'የመረጃ ቋት አስተዳደር';

  @override
  String get exportLocalBackup => 'ስሪት ውጣ';

  @override
  String get exportDescription => 'የብድር መረጃ ቋትዎን በደህንነት ያስወጡ።';

  @override
  String get databaseExportSuccess => 'መረጃ ቋት በተሳካ ሁኔታ ተልኳል';

  @override
  String exportFailed(String error) {
    return 'ማስወጣት አልተሳካም: $error';
  }

  @override
  String get applicationInfo => 'የመተግበሪያ መረጃ';

  @override
  String get securityEngine => 'የጥበቃ ስርዓት';

  @override
  String get localOnlyArchitecture => 'በመሣሪያው ላይ ብቻ የተከማቸ';

  @override
  String get language => 'ቋንቋ';

  @override
  String get languageDescription => 'የመተግበሪያ ቋንቋ ይቀይሩ';

  @override
  String get changeLanguage => 'ቋንቋ ቀይር';

  @override
  String get changePassword => 'የይለፍ ቃል ቀይር';

  @override
  String get changePasswordDescription => 'የመግቢያ ምስጢር ቁጥርዎን ያድሱ';

  @override
  String quantityTimesPrice(int qty, String price) {
    return '$qty x ብር $price';
  }

  @override
  String birrAmount(String amount) {
    return 'ብር $amount';
  }

  @override
  String amountBirr(String amount) {
    return '$amount ብር';
  }

  @override
  String get roleShopOwner => 'የሱቅ ባለቤት';

  @override
  String get roleCustomer => 'ደንበኛ';

  @override
  String get selectRole => 'የእርስዎን ሚና ይምረጡ';

  @override
  String get customerPortal => 'የደንበኞች ፖርታል';

  @override
  String get myTransactions => 'የእኔ ግብይቶች';

  @override
  String get overallDeadline => 'አጠቃላይ የክፍያ የመጨረሻ ቀን';

  @override
  String get shopNameLabel => 'የሱቅ ስም';

  @override
  String get shopPhone => 'የሱቅ ስልክ ቁጥር';

  @override
  String get noTransactions => 'እስካሁን ምንም ግብይቶች አልተመዘገቡም';

  @override
  String get dubebook => 'ዱቤቡክ';

  @override
  String get secureCreditManagement => 'ደህንነቱ የተጠበቀ ብድር አስተዳደር';

  @override
  String get emailOrUsername => 'ኢሜይል ወይም የተጠቃሚ ስም';

  @override
  String get password => 'የይለፍ ቃል';

  @override
  String get signIn => 'ግባ';

  @override
  String get newHere => 'አዲስ ነዎት? ';

  @override
  String get createAccount => 'መለያ ይፍጠሩ';

  @override
  String get joinDubebook => 'ዱቤቡክ ይቀላቀሉ';

  @override
  String get startManagingCredit => 'ብድር በደህንነት ማስተዳደር ይጀምሩ';

  @override
  String get retailer => 'ቸርቻሪ';

  @override
  String get customer => 'ደንበኛ';

  @override
  String get username => 'የተጠቃሚ ስም';

  @override
  String get phoneNumber => 'ስልክ ቁጥር';

  @override
  String get emailAddress => 'ኢሜይል አድራሻ';

  @override
  String get createAccountBtn => 'መለያ ፍጠር';

  @override
  String get haveAccount => 'መለያ አለዎት? ';

  @override
  String get required => 'ያስፈልጋል';

  @override
  String get myPortal => 'የእኔ ፖርታል';

  @override
  String get totalAggregateDebt => 'ጠቅላላ ድምር ዕዳ';

  @override
  String get myCreditAccounts => 'የእኔ የብድር ሂሳቦች';

  @override
  String get unknownShop => 'ያልታወቀ ሱቅ';

  @override
  String get customers => 'ደንበኞች';

  @override
  String get noCustomersFoundLower => 'ደንበኞች አልተገኙም';

  @override
  String get searchCustomers => 'ደንበኞችን ይፈልጉ...';

  @override
  String etbAmount(String amount) {
    return '$amount ብር';
  }

  @override
  String get activeSession => 'ንቁ ክፍለ-ጊዜ';

  @override
  String get noActiveCredit => 'ንቁ ብድር የለም';

  @override
  String get createYourShop => 'ሱቅዎን ይፍጠሩ';

  @override
  String get createYourShopDesc => 'ደንበኞችን ለመመዝገብ እና ብድር ለመከታተል የሱቅ ገጽ ያስፈልጋል።';

  @override
  String get createNewShop => 'አዲስ ሱቅ ፍጠር';

  @override
  String get switchShop => 'ሱቅ ቀይር';

  @override
  String get addNewShop => 'አዲስ ሱቅ ጨምር';

  @override
  String get businessType => 'የንግድ ዓይነት';

  @override
  String get create => 'ፍጠር';

  @override
  String get serverError => 'የሰርቨር ስህተት';

  @override
  String get somethingWentWrong => 'ችግር ተፈጠረ';

  @override
  String get balance => 'ቀሪ ሂሳብ';

  @override
  String get totalDebt => 'ጠቅላላ ዕዳ';

  @override
  String get walletBalancePositive => 'የዋሌት ቀሪ ሂሳብ (ፖዘቲቭ)';

  @override
  String get startDate => 'መጀመሪያ ቀን';

  @override
  String get endDate => 'መጨረሻ ቀን';

  @override
  String get timeline => 'ታይምላይን';

  @override
  String get payments => 'ክፍያዎች';

  @override
  String get noPhone => 'ስልክ የለም';

  @override
  String get deleteCustomerAndRecords => 'ደንበኛ እና ሁሉንም ሪከርዶች ይሰርዙ?';

  @override
  String get noDeadline => 'ቀነ-ገደብ የለም';

  @override
  String get paid => 'ተከፍሏል';

  @override
  String get active => 'ንቁ';

  @override
  String get paymentReceived => 'ክፍያ ተቀብሏል';

  @override
  String remaining(String amount) {
    return 'ቀሪ: $amount ብር';
  }

  @override
  String get addItem => 'ዕቃ ጨምር';

  @override
  String get addNew => 'አዲስ ጨምር';

  @override
  String get pay => 'ክፈል';

  @override
  String get sessionLimitWarning =>
      'ደንበኛ ከ2 በላይ ንቁ ክፍለ-ጊዜዎች ሊኖሩት አይችልም። አዲስ ለመክፈት ክፍለ-ጊዜ ያጠናቁ።';

  @override
  String get noCreditMatchesFilters => 'ከማጣሪያ ጋር የሚዛመድ የብድር ታሪክ የለም';

  @override
  String get noPaymentsMatchesFilters => 'ከማጣሪያ ጋር የሚዛመድ ክፍያ የለም';

  @override
  String get deleteItem => 'ዕቃ ሰርዝ';

  @override
  String get deleteItemConfirm => 'ይህን ዕቃ መሰረዝ ይፈልጋሉ? የደንበኛው ቀሪ ሂሳብ ይዘምናል።';

  @override
  String get editItem => 'ዕቃ አስተካክል';

  @override
  String get itemName => 'የዕቃ ስም';

  @override
  String get byKg => 'በኪሎ';

  @override
  String get byQuantity => 'በብዛት';

  @override
  String get weightKg => 'ክብደት (ኪ.ግ.)';

  @override
  String get quantity => 'ብዛት';

  @override
  String get pricePerKg => 'በኪሎ ዋጋ';

  @override
  String get pricePerItem => 'በዕቃ ዋጋ';

  @override
  String get pricePerKgEtb => 'በኪሎ ዋጋ (ብር)';

  @override
  String get pricePerItemEtb => 'በዕቃ ዋጋ (ብር)';

  @override
  String totalAmount(String amount) {
    return 'ጠቅላላ: $amount ብር';
  }

  @override
  String itemTotalAmount(String amount) {
    return 'የዕቃ ጠቅላላ: $amount ብር';
  }

  @override
  String get saveChanges => 'ለውጦችን አስቀምጥ';

  @override
  String get addToBasket => 'ወደ ቅርጫት ጨምር';

  @override
  String get addItemToSession => 'ዕቃ ወደ ክፍለ-ጊዜ ጨምር';

  @override
  String get raiseDispute => 'አቤቱታ አቅርብ';

  @override
  String get complaintMessage => 'የአቤቱታ መልዕክት';

  @override
  String get complaintHint => 'ለምን የዚህ ክፍለ-ጊዜ መጠን ትክክል ያልሆነ ይመስልዎታል ያስገቡ...';

  @override
  String get submitDispute => 'አቤቱታ አስገባ';

  @override
  String get disputeSubmitted => 'አቤቱታ ለሱቅ ባለቤት በተሳካ ሁኔታ ተልኳል።';

  @override
  String get dispute => 'አቤቱታ';

  @override
  String get updateDeadline => 'ቀነ-ገደብ አዘምን';

  @override
  String get cancelSession => 'ክፍለ-ጊዜ ሰርዝ';

  @override
  String get cancelSessionConfirm => 'ይህ ክፍለ-ጊዜ እንደ ተሰረዘ ይሰላል። ይህ ሊቀለበስ አይችልም።';

  @override
  String get selectDate => 'ቀን ይምረጡ';

  @override
  String get newCreditSession => 'አዲስ የብድር ክፍለ-ጊዜ';

  @override
  String get basketItems => 'የቅርጫት ዕቃዎች';

  @override
  String get deadlineOptional => 'ቀነ-ገደብ (አማራጭ)';

  @override
  String get selectDeadlineDate => 'የቀነ-ገደብ ቀን ይምረጡ';

  @override
  String get total => 'ጠቅላላ';

  @override
  String get saveSession => 'ክፍለ-ጊዜ አስቀምጥ';

  @override
  String get recordPayment => 'ክፍያ መዝግብ';

  @override
  String get paymentAmountEtb => 'የክፍያ መጠን (ብር)';

  @override
  String get paymentMethod => 'የክፍያ ዘዴ';

  @override
  String get cash => 'ጥሬ ገንዘብ';

  @override
  String get mobileMoney => 'ሞባይል ገንዘብ';

  @override
  String get bankTransfer => 'የባንክ ዝውውር';

  @override
  String get other => 'ሌላ';

  @override
  String get noteOptional => 'ማስታወሻ (አማራጭ)';

  @override
  String get confirmPayment => 'ክፍያ አረጋግጥ';

  @override
  String get mustBeGreaterThanZero => 'ከ0 በላይ መሆን አለበት';

  @override
  String get alerts => 'ማንቂያዎች';

  @override
  String get markAllAsRead => 'ሁሉንም እንደ ተነበበ ምልክት አድርግ';

  @override
  String get clearReadNotifications => 'የተነበቡ ማንቂያዎችን አጥፋ';

  @override
  String get allNotificationsRead => 'ሁሉም ማንቂያዎች እንደ ተነበበ ተምልክተዋል';

  @override
  String get readNotificationsCleared => 'የተነበቡ ማንቂያዎች ተጠርገዋል';

  @override
  String get allClear => 'ሁሉም ተጠርጓል';

  @override
  String get noAlertsDescription => 'በአሁኑ ጊዜ ማንቂያ ወይም ማስታወቂያ የለዎትም።';

  @override
  String get alert => 'ማንቂያ';

  @override
  String get saasPlafform => 'SaaS መድረክ';

  @override
  String due(String date) {
    return 'ቀነ-ገደብ $date';
  }

  @override
  String get account => 'መለያ';

  @override
  String get shopDetails => 'የሱቅ ዝርዝሮች';

  @override
  String get editShopDetails => 'የሱቅ ዝርዝሮችን አስተካክል';

  @override
  String get preferences => 'ምርጫዎች';

  @override
  String get dangerZone => 'አደገኛ ቀጠና';

  @override
  String get signOut => 'ውጣ';

  @override
  String get editShop => 'ሱቅ አስተካክል';

  @override
  String get phone => 'ስልክ';

  @override
  String get email => 'ኢሜይል';

  @override
  String get address => 'አድራሻ';

  @override
  String get save => 'አስቀምጥ';

  @override
  String get editProfile => 'መገለጫ አስተካክል';

  @override
  String updateProfileFailed(String error) {
    return 'መገለጫ ማዘመን አልተሳካም: $error';
  }
}
