/// Ethiopian Calendar conversion utility.
///
/// The Ethiopian calendar has 13 months:
///   - 12 months of 30 days each
///   - 1 month (Pagume) of 5 days (or 6 in a leap year)
///
/// Ethiopian New Year falls on September 11 (or 12 in Gregorian leap years).
/// The Ethiopian calendar is ~7-8 years behind the Gregorian calendar.
class EthiopianCalendar {
  final int year;
  final int month;
  final int day;

  const EthiopianCalendar(this.year, this.month, this.day);

  static const List<String> monthNamesEn = [
    'Meskerem', 'Tikimt', 'Hidar', 'Tahsas', 'Tir', 'Yekatit',
    'Megabit', 'Miyazya', 'Ginbot', 'Sene', 'Hamle', 'Nehase', 'Pagume'
  ];

  static const List<String> monthNamesAm = [
    'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሣሥ', 'ጥር', 'የካቲት',
    'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜ'
  ];

  static const List<String> monthNamesOm = [
    'Fulbaana', 'Onkololeessa', 'Sadaasa', 'Muddee', 'Amajjii', 'Guraandhala',
    'Bitooteessa', 'Ebla', 'Caamsaa', 'Waxabajjii', 'Adooleessa', 'Hagayya', 'Qaammee'
  ];

  /// Convert Gregorian DateTime to Ethiopian Calendar.
  static EthiopianCalendar fromGregorian(DateTime date) {
    // Julian Day Number calculation
    int jdn = _gregorianToJDN(date.year, date.month, date.day);
    return _jdnToEthiopian(jdn);
  }

  /// Convert Ethiopian Calendar to Gregorian DateTime.
  DateTime toGregorian() {
    int jdn = _ethiopianToJDN(year, month, day);
    return _jdnToGregorian(jdn);
  }

  /// Check if an Ethiopian year is a leap year.
  static bool isLeapYear(int year) {
    return (year % 4) == 3;
  }

  /// Get the number of days in a given Ethiopian month.
  static int daysInMonth(int year, int month) {
    if (month <= 12) return 30;
    return isLeapYear(year) ? 6 : 5;
  }

  /// Format as a readable string.
  String format({String locale = 'en'}) {
    List<String> names;
    switch (locale) {
      case 'am':
        names = monthNamesAm;
        break;
      case 'om':
        names = monthNamesOm;
        break;
      default:
        names = monthNamesEn;
    }
    final monthName = (month >= 1 && month <= 13) ? names[month - 1] : '?';
    return '$monthName $day, $year';
  }

  /// Short format: DD/MM/YYYY
  String formatShort() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }

  @override
  String toString() => format();

  // ─── Internal conversion helpers ───

  static int _gregorianToJDN(int year, int month, int day) {
    int a = ((14 - month) ~/ 12);
    int y = year + 4800 - a;
    int m = month + 12 * a - 3;
    return day + ((153 * m + 2) ~/ 5) + 365 * y + (y ~/ 4) - (y ~/ 100) + (y ~/ 400) - 32045;
  }

  static DateTime _jdnToGregorian(int jdn) {
    int a = jdn + 32044;
    int b = (4 * a + 3) ~/ 146097;
    int c = a - (146097 * b ~/ 4);
    int d = (4 * c + 3) ~/ 1461;
    int e = c - (1461 * d ~/ 4);
    int m = (5 * e + 2) ~/ 153;
    int day = e - ((153 * m + 2) ~/ 5) + 1;
    int month = m + 3 - 12 * (m ~/ 10);
    int year = 100 * b + d - 4800 + (m ~/ 10);
    return DateTime(year, month, day);
  }

  static int _ethiopianToJDN(int year, int month, int day) {
    return (1723856 + 365) + 365 * (year - 1) + (year ~/ 4) + 30 * month + day - 31;
  }

  static EthiopianCalendar _jdnToEthiopian(int jdn) {
    int r = ((jdn - 1723856) % 1461);
    int n = (r % 365) + 365 * (r ~/ 1460);
    int year = 4 * ((jdn - 1723856) ~/ 1461) + (r ~/ 365) - (r ~/ 1460);
    int month = (n ~/ 30) + 1;
    int day = (n % 30) + 1;
    return EthiopianCalendar(year, month, day);
  }

  /// Get the current Ethiopian date.
  static EthiopianCalendar now() {
    return fromGregorian(DateTime.now());
  }

  /// Get current Ethiopian year.
  static int currentYear() {
    return now().year;
  }
}
