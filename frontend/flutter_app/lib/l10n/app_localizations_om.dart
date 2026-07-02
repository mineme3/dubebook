// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oromo (`om`).
class AppLocalizationsOm extends AppLocalizations {
  AppLocalizationsOm([String locale = 'om']) : super(locale);

  @override
  String get appName => 'DUBE NOTE';

  @override
  String get appTagline => 'GARGAARSA SUUQII OGUMMAA';

  @override
  String get version => 'Gosa 0.0.1 (Beta)';

  @override
  String get copyright => '© 2024 WECAN TEAM';

  @override
  String get selectLanguage => 'AFAAN FILADHU';

  @override
  String get continueBtn => 'ITTI FUFI';

  @override
  String get enterPasswordPrompt => 'SEENUUF JECHA DARBII GALCHI';

  @override
  String get passwordHint => '••••••';

  @override
  String get accessDenied => 'Hayyamni Dhorkame';

  @override
  String get enter => 'SEENI';

  @override
  String get forgotPassword => 'JECHA DARBII DAGATTEE?';

  @override
  String get recovery => 'DEEBISUU';

  @override
  String get placeOfBirth => 'Bakka Dhalootaa';

  @override
  String get yearShopOpened => 'Bara Suuqiin Baname';

  @override
  String get createNewPassword => 'Jecha Darbii Haaraa Uumi';

  @override
  String get cancel => 'HAQI';

  @override
  String get reset => 'HAAROMSI';

  @override
  String get securityAnswersIncorrect => 'DEEBIIN NAGEENYA SIRRII MITI';

  @override
  String get passwordResetSuccess => 'Jechni darbii milkaa\'inaan jijjiirame';

  @override
  String get secureSetup => 'QINDAA\'INA NAGEENYA';

  @override
  String get masterPassword => 'Jecha Darbii Jalqabaa';

  @override
  String get recoveryQuestions => 'GAAFFILEE DEEBISUU';

  @override
  String get recoveryHelperText =>
      'Deebii booda yaadachuu dandeessan galchuudhaaf qabaa. Kun yeroo jecha darbii deebistan isin barbaachisa.';

  @override
  String get birthCity => 'Magaalaa Dhalootaa';

  @override
  String get openingYear => 'Bara Banamsaa (Itoophiyaa)';

  @override
  String get setUpMyShop => 'Suuqii Koo Qindeessi';

  @override
  String get dataSecureNote =>
      'Daataan keessan meeshaa kana qofa irratti kuufame.';

  @override
  String get passwordRequired => 'Jechni darbii barbaachisaadha';

  @override
  String get passwordMinLength => 'Yoo xiqqaate arfii 4 ta\'uu qaba';

  @override
  String get birthCityRequired => 'Magaalaan dhalootaa barbaachisaadha';

  @override
  String get yearRequired => 'Barri barbaachisaadha';

  @override
  String get yearExactDigits => 'Lakkoofsa 4 qofa ta\'uu qaba';

  @override
  String get invalidYearFormat => 'Boca baraa sirrii miti';

  @override
  String yearFuture(int year) {
    return 'Gara fuulduraatti ta\'uu hin danda\'u ($year)';
  }

  @override
  String yearTooOld(int year) {
    return 'Baay\'ee durii (Xiqqaate: $year)';
  }

  @override
  String get totalOutstanding => 'WALIIGALA HIN KAFFALAMNE';

  @override
  String get birr => 'Birrii';

  @override
  String get activeCredit => 'Liqii Hojii Irra Jiru';

  @override
  String get pendingDebts => 'LIQII HIN KAFFALAMNE';

  @override
  String customersCount(int count) {
    return 'MAAMILOOTA $count';
  }

  @override
  String get noCustomersFound => 'MAAMILNI HIN ARGAMNE';

  @override
  String get newCustomer => 'MAAMILA HAARAA';

  @override
  String get registerCustomer => 'MAAMILA GALMEESSI';

  @override
  String get fullName => 'Maqaa Guutuu';

  @override
  String get setPaymentDeadline => 'Beellama Kaffaltii Qindeessi';

  @override
  String get register => 'GALMEESSI';

  @override
  String get noDeadlineSet => 'Beellamni hin qindaa\'in';

  @override
  String dueDate(String date) {
    return 'Guyyaa $date';
  }

  @override
  String get overdue => 'YEROON DARBE';

  @override
  String get outstandingBalance => 'HAFTEE HIN KAFFALAMNE';

  @override
  String get creditHistory => 'SEENAA LIQII';

  @override
  String itemsCount(int count) {
    return 'MEESHAALEE $count';
  }

  @override
  String get noUnpaidItems => 'MEESHAAN HIN KAFFALAMNE HIN JIRU';

  @override
  String get addCredit => 'LIQII DABALII';

  @override
  String get settleAll => 'HUNDA KAFFALI';

  @override
  String get settleDebt => 'LIQII KAFFALI';

  @override
  String get markAllAsPaidConfirm =>
      'Meeshaalee hunda akka kaffalameetti mallattoo gochuu barbaaddaa?';

  @override
  String get confirm => 'MIRKANEESSI';

  @override
  String get deleteCustomer => 'MAAMILA HAQI';

  @override
  String get deleteCustomerConfirm =>
      'Maamila kana fi galmee daldalaa hunda haquuf? Kun deebi\'uu hin danda\'u.';

  @override
  String get delete => 'HAQI';

  @override
  String get editTransaction => 'DALDALAA SIRREESSI';

  @override
  String get deleteTransaction => 'DALDALAA HAQI';

  @override
  String get deleteTransactionConfirm =>
      'Daldalaa kana haquuf? Hafteen maamila ni haaromsa.';

  @override
  String get markAsPaid => 'KAFFALAME JEDHI';

  @override
  String get markAsPaidConfirm =>
      'Daldalaa kana kaffalame jettee mallattoo godhuu barbaaddaa?';

  @override
  String get edit => 'Sirreessi';

  @override
  String get deleteTx => 'Haqi';

  @override
  String get payItem => 'Kana Kaffali';

  @override
  String get newCredit => 'LIQII HAARAA';

  @override
  String get editCredit => 'LIQII SIRREESSI';

  @override
  String get whatWasTaken => 'Maaltu fudhatame?';

  @override
  String get qty => 'Bay.';

  @override
  String get unitPrice => 'Gatii Tokkoo';

  @override
  String get totalTransactionAmount => 'WALIIGALA GATII DALDALAA';

  @override
  String get saveToRecord => 'GALMEETTI OLKAA\'I';

  @override
  String get updateRecord => 'GALMEE HAAROMSI';

  @override
  String get fieldRequired => 'Dirreen kun barbaachisaadha';

  @override
  String get negativeNotAllowed => 'Gatiin negaatiivii hin hayyamamu';

  @override
  String get paidRecords => 'GALMEE KAFFALAME';

  @override
  String get deletedCustomer => 'Maamila Haqame';

  @override
  String paidOn(String date) {
    return 'Kaffalame: $date';
  }

  @override
  String get deleteRecord => 'GALMEE HAQI?';

  @override
  String get deleteRecordConfirm =>
      'Daldalaan kun seenaa keessaa dhaabbataan ni haqama.';

  @override
  String get noTransactionHistory => 'SEENAAN DALDALAA HIN JIRU';

  @override
  String get settings => 'QINDAA\'INA';

  @override
  String get databaseManagement => 'BULCHIINSA KUUSAA';

  @override
  String get exportLocalBackup => 'Kuusaa Olbaasi';

  @override
  String get exportDescription => 'Kuusaa liqii keessan nagaan olbaasaa.';

  @override
  String get databaseExportSuccess => 'Kuusaan milkaa\'inaan ergame';

  @override
  String exportFailed(String error) {
    return 'Olbaasuun hin milkoofne: $error';
  }

  @override
  String get applicationInfo => 'ODEEFFANNOO APPII';

  @override
  String get securityEngine => 'Mootiira Nageenya';

  @override
  String get localOnlyArchitecture => 'Meeshaa kana qofa irratti kuufame';

  @override
  String get language => 'Afaan';

  @override
  String get languageDescription => 'Afaan appii jijjiiri';

  @override
  String get changeLanguage => 'AFAAN JIJJIIRI';

  @override
  String get changePassword => 'Jecha Darbii Jijjiiri';

  @override
  String get changePasswordDescription => 'Oodeffannoo seensaa kee jijjiiri';

  @override
  String quantityTimesPrice(int qty, String price) {
    return '$qty x Birrii $price';
  }

  @override
  String birrAmount(String amount) {
    return 'Birrii $amount';
  }

  @override
  String amountBirr(String amount) {
    return '$amount Birrii';
  }

  @override
  String get roleShopOwner => 'Abbaa Suuqii';

  @override
  String get roleCustomer => 'Maamiltoota';

  @override
  String get selectRole => 'DHARQII KEE FILADHU';

  @override
  String get customerPortal => 'PORTAL MAAMILTOOTA';

  @override
  String get myTransactions => 'GIBIYYANNAA KOO';

  @override
  String get overallDeadline => 'DAANGAA KAFALTI WALIIGALAA';

  @override
  String get shopNameLabel => 'Maqaa Suuqii';

  @override
  String get shopPhone => 'Bilbila Suuqii';

  @override
  String get noTransactions => 'GIBIYYANNAAN TOKKOLLEE HIN GALMEESSINE';

  @override
  String get dubebook => 'DUBEBOOK';

  @override
  String get secureCreditManagement => 'BULCHIINSA LIQII NAGEENYA';

  @override
  String get emailOrUsername => 'Imeelii ykn Maqaa Fayyadamaa';

  @override
  String get password => 'Jecha Darbii';

  @override
  String get signIn => 'SEENI';

  @override
  String get newHere => 'Haaraa? ';

  @override
  String get createAccount => 'Herrega Uumi';

  @override
  String get joinDubebook => 'DUBEBOOK MAKKAMI';

  @override
  String get startManagingCredit => 'LIQII NAGAAN BULCHUU JALQABI';

  @override
  String get retailer => 'DALDAALTUU';

  @override
  String get customer => 'MAAMILA';

  @override
  String get username => 'Maqaa Fayyadamaa';

  @override
  String get phoneNumber => 'Lakk. Bilbilaa';

  @override
  String get emailAddress => 'Teessoo Imeelii';

  @override
  String get createAccountBtn => 'HERREGA UUMI';

  @override
  String get haveAccount => 'Herrega qabdaa? ';

  @override
  String get required => 'Barbaachisaadha';

  @override
  String get myPortal => 'PORTAL KOO';

  @override
  String get totalAggregateDebt => 'WALIIGALA LIQII DABALAME';

  @override
  String get myCreditAccounts => 'HERREGAA LIQII KOO';

  @override
  String get unknownShop => 'Suuqii Hin Beekamne';

  @override
  String get customers => 'MAAMILOOTA';

  @override
  String get noCustomersFoundLower => 'Maamilni hin argamne';

  @override
  String get searchCustomers => 'Maamila barbaadi...';

  @override
  String etbAmount(String amount) {
    return '$amount Birrii';
  }

  @override
  String get activeSession => 'Yeroo Hojii';

  @override
  String get noActiveCredit => 'Liqiin Hojii Irra Jiru Hin Jiru';

  @override
  String get createYourShop => 'Suuqii Kee Uumi';

  @override
  String get createYourShopDesc =>
      'Maamila galmeessuuf fi liqii hordofuuf sagantaa suuqii si barbaachisa.';

  @override
  String get createNewShop => 'Suuqii Haaraa Uumi';

  @override
  String get switchShop => 'SUUQII JIJJIIRI';

  @override
  String get addNewShop => 'Suuqii Haaraa Dabali';

  @override
  String get businessType => 'Gosa Daldalaa';

  @override
  String get create => 'Uumi';

  @override
  String get serverError => 'Dogoggora sarvarii';

  @override
  String get somethingWentWrong => 'Wanti tokko dogoggoreera';

  @override
  String get balance => 'HAFTEE';

  @override
  String get totalDebt => 'WALIIGALA LIQII';

  @override
  String get walletBalancePositive => 'HAFTEE WAALEETII (POOZATIIVII)';

  @override
  String get startDate => 'Guyyaa Jalqabaa';

  @override
  String get endDate => 'Guyyaa Dhumaa';

  @override
  String get timeline => 'TAAYIIMLAAYINII';

  @override
  String get payments => 'KAFFALTIIWWAN';

  @override
  String get noPhone => 'BILBILA HIN QABU';

  @override
  String get deleteCustomerAndRecords => 'Maamila fi galmee hunda haqi?';

  @override
  String get noDeadline => 'Beellamni Hin Jiru';

  @override
  String get paid => 'KAFFALAME';

  @override
  String get active => 'HOJII IRRA';

  @override
  String get paymentReceived => 'Kaffaltiin Argame';

  @override
  String remaining(String amount) {
    return 'KAN HAFE: $amount Birrii';
  }

  @override
  String get addItem => 'Meeshaa Dabali';

  @override
  String get addNew => 'Haaraa Dabali';

  @override
  String get pay => 'Kaffali';

  @override
  String get sessionLimitWarning =>
      'Maamilni yeroo tokkotti yeroo hojii irra 2 ol qabaachuu hin danda\'u. Haaraa banuuf yeroo hojii irra tokko xumuri.';

  @override
  String get noCreditMatchesFilters =>
      'Seenaa liqii filtar waliin walsimu hin jiru';

  @override
  String get noPaymentsMatchesFilters =>
      'Kaffaltii filtar waliin walsimu hin jiru';

  @override
  String get deleteItem => 'Meeshaa Haqi';

  @override
  String get deleteItemConfirm =>
      'Meeshaa kana haquuf mirkaneeffadhaa? Hafteen maamila ni haaromsa.';

  @override
  String get editItem => 'Meeshaa Sirreessi';

  @override
  String get itemName => 'Maqaa Meeshaa';

  @override
  String get byKg => 'KG dhaan';

  @override
  String get byQuantity => 'Baay\'ina dhaan';

  @override
  String get weightKg => 'Ulfaatina (KG)';

  @override
  String get quantity => 'Baay\'ina';

  @override
  String get pricePerKg => 'Gatii KG tti';

  @override
  String get pricePerItem => 'Gatii Meeshaa tti';

  @override
  String get pricePerKgEtb => 'Gatii KG tti (Birrii)';

  @override
  String get pricePerItemEtb => 'Gatii Meeshaa tti (Birrii)';

  @override
  String totalAmount(String amount) {
    return 'Waliigala: $amount Birrii';
  }

  @override
  String itemTotalAmount(String amount) {
    return 'Waliigala Meeshaa: $amount Birrii';
  }

  @override
  String get saveChanges => 'Jijjiirama Olkaa\'i';

  @override
  String get addToBasket => 'Qalqalloo tti Dabali';

  @override
  String get addItemToSession => 'Meeshaa Yeroo tti Dabali';

  @override
  String get raiseDispute => 'Komii Dhiheessi';

  @override
  String get complaintMessage => 'Ergaa Komii';

  @override
  String get complaintHint =>
      'Maaliif gatiin yeroo kanaa sirrii akka hin taane yaada keessan galchaa...';

  @override
  String get submitDispute => 'Komii Ergi';

  @override
  String get disputeSubmitted =>
      'Komiin abbaa suuqii tti milkaa\'inaan ergameera.';

  @override
  String get dispute => 'Komii';

  @override
  String get updateDeadline => 'Beellama Haaromsi';

  @override
  String get cancelSession => 'Yeroo Haqi';

  @override
  String get cancelSessionConfirm =>
      'Yeroon kun akka haqameetti mallattaa\'a. Kun deebi\'uu hin danda\'u.';

  @override
  String get selectDate => 'Guyyaa Filadhu';

  @override
  String get newCreditSession => 'YEROO LIQII HAARAA';

  @override
  String get basketItems => 'MEESHAALEE QALQALLOO';

  @override
  String get deadlineOptional => 'BEELLAMA (DIRQAMA MITI)';

  @override
  String get selectDeadlineDate => 'Guyyaa Beellama Filadhu';

  @override
  String get total => 'WALIIGALA';

  @override
  String get saveSession => 'YEROO OLKAA\'I';

  @override
  String get recordPayment => 'KAFFALTII GALMEESSI';

  @override
  String get paymentAmountEtb => 'Hamma Kaffaltii (Birrii)';

  @override
  String get paymentMethod => 'MALA KAFFALTII';

  @override
  String get cash => 'Qarshii';

  @override
  String get mobileMoney => 'Maallaqa Mobaayilaa';

  @override
  String get bankTransfer => 'Dabarsa Baankii';

  @override
  String get other => 'Kan biraa';

  @override
  String get noteOptional => 'Yaadannoo (dirqama miti)';

  @override
  String get confirmPayment => 'KAFFALTII MIRKANEESSI';

  @override
  String get mustBeGreaterThanZero => '0 ol ta\'uu qaba';

  @override
  String get alerts => 'AKEEKKACHIISOTA';

  @override
  String get markAllAsRead => 'Hunda akka dubbifameetti mallattoo godhi';

  @override
  String get clearReadNotifications => 'Akeekkachiisota dubbifaman haqi';

  @override
  String get allNotificationsRead =>
      'Akeekkachiisotni hundi akka dubbifameetti mallattaa\'eera';

  @override
  String get readNotificationsCleared =>
      'Akeekkachiisotni dubbifaman haqameera';

  @override
  String get allClear => 'Hundi qulqulluu';

  @override
  String get noAlertsDescription =>
      'Yeroo ammaa akeekkachiisa ykn beeksisa hin qabdu.';

  @override
  String get alert => 'Akeekkachiisa';

  @override
  String get saasPlafform => 'SaaS SAGANTAA';

  @override
  String due(String date) {
    return 'BEELLAMA $date';
  }

  @override
  String get account => 'HERREGA';

  @override
  String get shopDetails => 'BAL\'INA SUUQII';

  @override
  String get editShopDetails => 'Bal\'ina Suuqii Sirreessi';

  @override
  String get preferences => 'FILANNOOWWAN';

  @override
  String get dangerZone => 'KUTAA HAMAA';

  @override
  String get signOut => 'Bahuu';

  @override
  String get editShop => 'Suuqii Sirreessi';

  @override
  String get phone => 'Bilbila';

  @override
  String get email => 'Imeelii';

  @override
  String get address => 'Teessoo';

  @override
  String get save => 'Olkaa\'i';

  @override
  String get editProfile => 'Profaayilii Sirreessi';

  @override
  String updateProfileFailed(String error) {
    return 'Profaayilii haaromsuun hin milkoofne: $error';
  }
}
