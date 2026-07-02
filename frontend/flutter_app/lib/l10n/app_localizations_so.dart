// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Somali (`so`).
class AppLocalizationsSo extends AppLocalizations {
  AppLocalizationsSo([String locale = 'so']) : super(locale);

  @override
  String get appName => 'DUBE NOTE';

  @override
  String get appTagline => 'KAALIYAHA DUKAANKA EE RASHMIGA AH';

  @override
  String get version => 'Nuqul 0.0.1 (Siidaynta Beta)';

  @override
  String get copyright => '© 2024 WECAN TEAM';

  @override
  String get selectLanguage => 'DOORO LUGADDAADA';

  @override
  String get continueBtn => 'SIII COBO';

  @override
  String get enterPasswordPrompt => 'GELI SIRAHA SI AAD U GASHO';

  @override
  String get passwordHint => '••••••';

  @override
  String get accessDenied => 'Helitaanka waa la diiday';

  @override
  String get enter => 'GAL';

  @override
  String get forgotPassword => 'MA ILLOWDAY SIRAHA?';

  @override
  String get recovery => 'SOO CELIN';

  @override
  String get placeOfBirth => 'Goobtii Dhalashada';

  @override
  String get yearShopOpened => 'Sanadkii Dukaanka la Furay';

  @override
  String get createNewPassword => 'Abuur Sireed Cusub';

  @override
  String get cancel => 'KA NOQO';

  @override
  String get reset => 'DIB U DEJI';

  @override
  String get securityAnswersIncorrect => 'JAWAABAHA AMAANKA WAA KHADAD';

  @override
  String get passwordResetSuccess => 'Dib u dejinta siraha waa lagu guuleystay';

  @override
  String get secureSetup => 'HABAYN AMAAN';

  @override
  String get masterPassword => 'Sireedka Guud';

  @override
  String get recoveryQuestions => 'SU\'AALAHA SOO CELINTA';

  @override
  String get recoveryHelperText =>
      'Hubi inaad isticmaasho jawaab aad xasuusan karto. Tan waxaa loo baahan doonaa marka aad dib u soo celineyso sirahaaga.';

  @override
  String get birthCity => 'Magaaladii Dhalashada';

  @override
  String get openingYear => 'Sanadka la Furay (Itoobiya)';

  @override
  String get setUpMyShop => 'Samee Dukaankayga';

  @override
  String get dataSecureNote =>
      'Xogtaada waxaa si ammaan ah loogu kaydiyaa qalabkan oo keliya.';

  @override
  String get passwordRequired => 'Sireedka waa khasab';

  @override
  String get passwordMinLength => 'Waa inuu ugu yaraan ka koobnaadaa 4 xaraf';

  @override
  String get birthCityRequired => 'Magaalada dhalashada waa khasab';

  @override
  String get yearRequired => 'Sanadka waa khasab';

  @override
  String get yearExactDigits => 'Waa inuu ahaadaa sax 4 lambar';

  @override
  String get invalidYearFormat => 'Habka sanadka waa khaldan yahay';

  @override
  String yearFuture(int year) {
    return 'Ma noqon karo mustaqbalka ($year E.C.)';
  }

  @override
  String yearTooOld(int year) {
    return 'Aad buu u fog yahay (Ugu yaraan: $year)';
  }

  @override
  String get totalOutstanding => 'WADARTA DEYNTA KA MAQAN';

  @override
  String get birr => 'Birr';

  @override
  String get activeCredit => 'Deynta Firfircoon';

  @override
  String get pendingDebts => 'DEYNTA INTA SUGAN';

  @override
  String customersCount(int count) {
    return '$count MACAMIIL';
  }

  @override
  String get noCustomersFound => 'MA JIRAAN MACAMIIL LA HELAY';

  @override
  String get newCustomer => 'MACMIIL CUSUB';

  @override
  String get registerCustomer => 'DIIWAANGELI MACMIILKA';

  @override
  String get fullName => 'Magaca Buuxa';

  @override
  String get setPaymentDeadline => 'Deji Xilliga U Dambeeya ee Bixinta';

  @override
  String get register => 'DIIWAANGELI';

  @override
  String get noDeadlineSet => 'Ma jiro wakhti xaddidan oo la dejiyay';

  @override
  String dueDate(String date) {
    return 'U dambaysa $date';
  }

  @override
  String get overdue => 'WAKHTIGII WAA DHAFAY';

  @override
  String get outstandingBalance => 'DEYNTA HARYSA EE MAQAN';

  @override
  String get creditHistory => 'TAARIIXDA DEYNTA';

  @override
  String itemsCount(int count) {
    return '$count WALXO';
  }

  @override
  String get noUnpaidItems => 'MA JIRAAN WALXO AAN LA BIXIN';

  @override
  String get addCredit => 'KU DAR DEYN';

  @override
  String get settleAll => 'WADA BIXI';

  @override
  String get settleDebt => 'BIXI DEYNTA';

  @override
  String get markAllAsPaidConfirm =>
      'Ma rabtaa inaad dhammaan walxaha u calaamadiso sidii la bixiyay oo aad u rurto taariikhda?';

  @override
  String get confirm => 'XAQIIQI';

  @override
  String get deleteCustomer => 'TIRTIR MACMIILKA';

  @override
  String get deleteCustomerConfirm =>
      'Ma rabtaa inaad si joogto ah u tirtirto macmiilkan iyo dhammaan xogtiisa? Tan dib looma celin karo.';

  @override
  String get delete => 'TIRTIR';

  @override
  String get editTransaction => 'WAX KA BEDEL MACAAMILKA';

  @override
  String get deleteTransaction => 'TIRTIR MACAAMILKA';

  @override
  String get deleteTransactionConfirm =>
      'Ma rabtaa inaad si joogto ah u tirtirto macaamilkan? Dhibicda macmiilka waa la cusbooneysiin doonaa.';

  @override
  String get markAsPaid => 'U CALAAMADEE IN LA BIXIYAY';

  @override
  String get markAsPaidConfirm =>
      'Ma rabtaa inaad macaamilkan u calaamadiso in la bixiyay oo aad u rurto taariikhda?';

  @override
  String get edit => 'Wax ka bedel';

  @override
  String get deleteTx => 'Tirtir';

  @override
  String get payItem => 'Bixi tan';

  @override
  String get newCredit => 'DEYN CUSUB';

  @override
  String get editCredit => 'WAX KA BEDEL DEYNTA';

  @override
  String get whatWasTaken => 'Maxaa la qaatay?';

  @override
  String get qty => 'Tirada';

  @override
  String get unitPrice => 'Qiimaha Xabbaddii';

  @override
  String get totalTransactionAmount => 'WADARTA GUUD EE MACAAMILKA';

  @override
  String get saveToRecord => 'KAYDI XOGTA';

  @override
  String get updateRecord => 'CUSBOONEYSII XOGTA';

  @override
  String get fieldRequired => 'Meeshan waa khasab';

  @override
  String get negativeNotAllowed => 'Qiimaha taban lama ogola';

  @override
  String get paidRecords => 'XOGTA LA BIXIYAY';

  @override
  String get deletedCustomer => 'Macmiil la tirtiray';

  @override
  String paidOn(String date) {
    return 'La bixiyay: $date';
  }

  @override
  String get deleteRecord => 'TIRTIR XOGTA?';

  @override
  String get deleteRecordConfirm =>
      'Tani waxay si joogto ah u tirtiri doontaa macaamilkan taariikhda.';

  @override
  String get noTransactionHistory => 'MA JIRTO TAARIIX MACAAMIL GANACSI';

  @override
  String get settings => 'HABAYNTA';

  @override
  String get databaseManagement => 'MAAREYNTA XOGTA';

  @override
  String get exportLocalBackup => 'U dhoofi Kaabta Maxalliga ah';

  @override
  String get exportDescription =>
      'Si ammaan ah u dhoofi faylkaaga macluumaadka deynta.';

  @override
  String get databaseExportSuccess => 'Guul ayaa loogu dhoofiyay faylka xogta';

  @override
  String exportFailed(String error) {
    return 'Dhoofinta waa fashilantay: $error';
  }

  @override
  String get applicationInfo => 'MACLUUMAADKA COBSIGA';

  @override
  String get securityEngine => 'Mishiinka Amniga';

  @override
  String get localOnlyArchitecture =>
      'Qaab-dhismeedka xogta ee maxalliga ah oo keliya';

  @override
  String get language => 'Luqadda';

  @override
  String get languageDescription => 'Beddel luqadda codsiga';

  @override
  String get changeLanguage => 'BEDDEL LUQADDA';

  @override
  String get changePassword => 'Beddel Sireedka';

  @override
  String get changePasswordDescription =>
      'Cusbooneysii aqoonsigaaga gelitaanka';

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
  String get roleShopOwner => 'Mulkiilaha Dukaanka';

  @override
  String get roleCustomer => 'Macmiilka';

  @override
  String get selectRole => 'DOORO DOORKAADA';

  @override
  String get customerPortal => 'PORTAL-KA MACMIILKA';

  @override
  String get myTransactions => 'MACAAMILADAYDA';

  @override
  String get overallDeadline => 'XILLIGA GUUD EE U DAMBEYSA';

  @override
  String get shopNameLabel => 'Magaca Dukaanka';

  @override
  String get shopPhone => 'Taleefanka Dukaanka';

  @override
  String get noTransactions => 'WELI WAX MACAAMIL GANACSI AH CO CALAAMADEYN';

  @override
  String get dubebook => 'DUBEBOOK';

  @override
  String get secureCreditManagement => 'MAAREYNTA DEYNTA OO AMMAAN AH';

  @override
  String get emailOrUsername => 'Iimaylka ama Magaca Isticmaalaha';

  @override
  String get password => 'Sireedka';

  @override
  String get signIn => 'SOO GAL';

  @override
  String get newHere => 'Cusub? ';

  @override
  String get createAccount => 'Samee Xisaab';

  @override
  String get joinDubebook => 'KU BIIR DUBEBOOK';

  @override
  String get startManagingCredit => 'BILOW MAAREYNTA DEYNTA SI AMMAAN AH';

  @override
  String get retailer => 'TAAJIIR';

  @override
  String get customer => 'MACMIIL';

  @override
  String get username => 'Magaca Isticmaalaha';

  @override
  String get phoneNumber => 'Lambarka Taleefanka';

  @override
  String get emailAddress => 'Ciwaanka Iimaylka';

  @override
  String get createAccountBtn => 'SAMEE XISAAB';

  @override
  String get haveAccount => 'Xisaab ma leedahay? ';

  @override
  String get required => 'Waa khasab';

  @override
  String get myPortal => 'PORTAL-KAYGA';

  @override
  String get totalAggregateDebt => 'WADARTA GUUD EE DEYNTA';

  @override
  String get myCreditAccounts => 'XISAABAADAYDA DEYNTA';

  @override
  String get unknownShop => 'Dukaan aan la Garaneyn';

  @override
  String get customers => 'MACAAMIISHA';

  @override
  String get noCustomersFoundLower => 'Macamiil lama helin';

  @override
  String get searchCustomers => 'Raadi macamiil...';

  @override
  String etbAmount(String amount) {
    return '$amount Birr';
  }

  @override
  String get activeSession => 'Wakhti Firfircoon';

  @override
  String get noActiveCredit => 'Deyn Firfircoon Ma Jirto';

  @override
  String get createYourShop => 'Samee Dukaankaaga';

  @override
  String get createYourShopDesc =>
      'Waxaad u baahan tahay profile dukaan si aad u bilowdo diiwaangelinta macaamiisha iyo la socodka deynta.';

  @override
  String get createNewShop => 'Samee Dukaan Cusub';

  @override
  String get switchShop => 'BEDDEL DUKAANKA';

  @override
  String get addNewShop => 'Ku dar Dukaan Cusub';

  @override
  String get businessType => 'Nooca Ganacsiga';

  @override
  String get create => 'Samee';

  @override
  String get serverError => 'Khalad server';

  @override
  String get somethingWentWrong => 'Wax baa qaldamay';

  @override
  String get balance => 'DHEELITIRKA';

  @override
  String get totalDebt => 'WADARTA DEYNTA';

  @override
  String get walletBalancePositive => 'DHEELITIRKA JEEBKA (TOGAN)';

  @override
  String get startDate => 'Taariikhda Bilowga';

  @override
  String get endDate => 'Taariikhda Dhammaadka';

  @override
  String get timeline => 'JADWALKA WAQTIGA';

  @override
  String get payments => 'LACAG BIXINTA';

  @override
  String get noPhone => 'TALEEFAN LA\'AAN';

  @override
  String get deleteCustomerAndRecords =>
      'Tirtir macmiilka iyo dhammaan xogtiisa?';

  @override
  String get noDeadline => 'Xilli U Dambeys La\'aan';

  @override
  String get paid => 'LA BIXIYAY';

  @override
  String get active => 'FIRFIRCOON';

  @override
  String get paymentReceived => 'Lacag Bixin La Helay';

  @override
  String remaining(String amount) {
    return 'HARAY: $amount Birr';
  }

  @override
  String get addItem => 'Ku dar Walax';

  @override
  String get addNew => 'Ku dar Cusub';

  @override
  String get pay => 'Bixi';

  @override
  String get sessionLimitWarning =>
      'Macmiilku wuxuu yeelan karaa ugu badnaan 2 wakhti firfircoon. Si aad mid cusub u furto, dhammeystir mid ka mid ah.';

  @override
  String get noCreditMatchesFilters =>
      'Ma jirto taariix deyn oo la mid ah shaandhada';

  @override
  String get noPaymentsMatchesFilters =>
      'Ma jirto lacag bixin oo la mid ah shaandhada';

  @override
  String get deleteItem => 'Tirtir Walxiga';

  @override
  String get deleteItemConfirm =>
      'Ma hubtaa inaad rabto inaad tirtirto walxigan? Dheelitirka macmiilka waa la cusbooneysiin doonaa.';

  @override
  String get editItem => 'Wax ka bedel Walxiga';

  @override
  String get itemName => 'Magaca Walxiga';

  @override
  String get byKg => 'KG kasta';

  @override
  String get byQuantity => 'Tirada kasta';

  @override
  String get weightKg => 'Miisaanka (KG)';

  @override
  String get quantity => 'Tirada';

  @override
  String get pricePerKg => 'Qiimaha KG kasta';

  @override
  String get pricePerItem => 'Qiimaha Walax kasta';

  @override
  String get pricePerKgEtb => 'Qiimaha KG kasta (Birr)';

  @override
  String get pricePerItemEtb => 'Qiimaha Walax kasta (Birr)';

  @override
  String totalAmount(String amount) {
    return 'Wadarta: $amount Birr';
  }

  @override
  String itemTotalAmount(String amount) {
    return 'Wadarta Walxiga: $amount Birr';
  }

  @override
  String get saveChanges => 'Kaydi Isbeddelada';

  @override
  String get addToBasket => 'Ku dar Dambiilka';

  @override
  String get addItemToSession => 'Ku dar Walax Wakhtiga';

  @override
  String get raiseDispute => 'Soo Gudbi Cabashad';

  @override
  String get complaintMessage => 'Fariinta Cabashada';

  @override
  String get complaintHint =>
      'Geli sababta aad u malaynayso qiimaha wakhtigan inuusan sax ahayn...';

  @override
  String get submitDispute => 'Gudbi Cabashada';

  @override
  String get disputeSubmitted =>
      'Cabashada waxaa si guul leh loogu gudbiyay mulkiilaha dukaanka.';

  @override
  String get dispute => 'Cabashad';

  @override
  String get updateDeadline => 'Cusbooneysii Xilliga U Dambeysa';

  @override
  String get cancelSession => 'Jooji Wakhtiga';

  @override
  String get cancelSessionConfirm =>
      'Wakhtigan waxaa loo calaamadeyn doonaa sidii la joojiyay. Tan dib looma celin karo.';

  @override
  String get selectDate => 'Dooro Taariikh';

  @override
  String get newCreditSession => 'WAKHTI DEYN CUSUB';

  @override
  String get basketItems => 'WALXAHA DAMBIILKA';

  @override
  String get deadlineOptional => 'XILLIGA U DAMBEYSA (IKHTIYAARI)';

  @override
  String get selectDeadlineDate => 'Dooro Taariikhda Xilliga U Dambeysa';

  @override
  String get total => 'WADARTA';

  @override
  String get saveSession => 'KAYDI WAKHTIGA';

  @override
  String get recordPayment => 'DIIWAANGELI LACAG BIXINTA';

  @override
  String get paymentAmountEtb => 'Lacagta la Bixinayo (Birr)';

  @override
  String get paymentMethod => 'HABKA LACAG BIXINTA';

  @override
  String get cash => 'Lacag Caddaan ah';

  @override
  String get mobileMoney => 'Lacagta Mobilka';

  @override
  String get bankTransfer => 'Wareejinta Bangiga';

  @override
  String get other => 'Mid kale';

  @override
  String get noteOptional => 'Qoraal (ikhtiyaari)';

  @override
  String get confirmPayment => 'XAQIIQI LACAG BIXINTA';

  @override
  String get mustBeGreaterThanZero => 'Waa inuu ka weyn yahay 0';

  @override
  String get alerts => 'DIGNIINOOYINKA';

  @override
  String get markAllAsRead => 'Dhammaan u calaamadee in la akhriyay';

  @override
  String get clearReadNotifications => 'Tirtir digniinada la akhriyay';

  @override
  String get allNotificationsRead =>
      'Dhammaan digniinadu waxaa loo calaamadiyay in la akhriyay';

  @override
  String get readNotificationsCleared =>
      'Digniinada la akhriyay waa la tirtiray';

  @override
  String get allClear => 'Waa nadiif';

  @override
  String get noAlertsDescription =>
      'Wakhtigan ma jiraan digniinooyin ama ogeysiisyo.';

  @override
  String get alert => 'Digniino';

  @override
  String get saasPlafform => 'SaaS NIDAAMKA';

  @override
  String due(String date) {
    return 'XILLIGA $date';
  }

  @override
  String get account => 'XISAABTA';

  @override
  String get shopDetails => 'FAHFAAHINTA DUKAANKA';

  @override
  String get editShopDetails => 'Wax ka bedel Fahfaahinta Dukaanka';

  @override
  String get preferences => 'DOORASHADA';

  @override
  String get dangerZone => 'SEEDA KHATARTA';

  @override
  String get signOut => 'Ka Bax';

  @override
  String get editShop => 'Wax ka bedel Dukaanka';

  @override
  String get phone => 'Taleefan';

  @override
  String get email => 'Iimayl';

  @override
  String get address => 'Ciwaanka';

  @override
  String get save => 'Kaydi';

  @override
  String get editProfile => 'Wax ka bedel Profile-ka';

  @override
  String updateProfileFailed(String error) {
    return 'Fashilantay cusbooneysiinta profile-ka: $error';
  }
}
