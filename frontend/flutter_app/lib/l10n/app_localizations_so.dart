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
  String get version => 'Nuqul (Version) 0.0.1 (Siidaynta Beta)';

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
      'Ma rabtaa inaad si joogto ah u tirtirto macmiilkan iyo dhammaan xogtiisa macaamil ganacsi? Tan dib looma celin karo.';

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
}
