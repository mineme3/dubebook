import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'ethiopian_calendar.dart';
import 'theme.dart';

/// A custom date picker dialog that displays dates in the Ethiopian calendar.
///
/// The user selects Year, Month, Day using dropdown spinners.
/// The selected date is returned as a Gregorian [DateTime] for internal use.
Future<DateTime?> showEthiopianDatePicker({
  required BuildContext context,
  DateTime? initialDate,
}) async {
  final ethNow = EthiopianCalendar.now();
  final EthiopianCalendar initial = initialDate != null
      ? EthiopianCalendar.fromGregorian(initialDate)
      : ethNow;

  int selectedYear = initial.year;
  int selectedMonth = initial.month;
  int selectedDay = initial.day;

  // Determine locale for month names
  final locale = Localizations.localeOf(context).languageCode;

  final result = await showDialog<DateTime>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setState) {
          final daysInMonth = EthiopianCalendar.daysInMonth(selectedYear, selectedMonth);
          if (selectedDay > daysInMonth) {
            selectedDay = daysInMonth;
          }

          List<String> monthNames;
          switch (locale) {
            case 'am':
              monthNames = EthiopianCalendar.monthNamesAm;
              break;
            case 'om':
              monthNames = EthiopianCalendar.monthNamesOm;
              break;
            default:
              monthNames = EthiopianCalendar.monthNamesEn;
          }

          return AlertDialog(
            backgroundColor: AppTheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: BorderSide(color: AppTheme.primaryBlue.withOpacity(0.2)),
            ),
            title: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryBlue, size: 22),
                const SizedBox(width: 10),
                Text(
                  locale == 'am' ? 'ቀን ይምረጡ' : locale == 'om' ? 'Guyyaa Filadhu' : 'Select Date',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Preview
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Text(
                      EthiopianCalendar(selectedYear, selectedMonth, selectedDay).format(locale: locale),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryBlue,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Year selector
                _buildSelector(
                  label: locale == 'am' ? 'ዓመት' : locale == 'om' ? 'Bara' : 'Year',
                  value: selectedYear.toString(),
                  onDecrease: () {
                    if (selectedYear > ethNow.year) {
                      setState(() => selectedYear--);
                    }
                  },
                  onIncrease: () {
                    if (selectedYear < ethNow.year + 5) {
                      setState(() => selectedYear++);
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Month selector
                _buildSelector(
                  label: locale == 'am' ? 'ወር' : locale == 'om' ? 'Ji\'a' : 'Month',
                  value: monthNames[selectedMonth - 1],
                  onDecrease: () {
                    setState(() {
                      selectedMonth = selectedMonth > 1 ? selectedMonth - 1 : 13;
                    });
                  },
                  onIncrease: () {
                    setState(() {
                      selectedMonth = selectedMonth < 13 ? selectedMonth + 1 : 1;
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Day selector
                _buildSelector(
                  label: locale == 'am' ? 'ቀን' : locale == 'om' ? 'Guyyaa' : 'Day',
                  value: selectedDay.toString().padLeft(2, '0'),
                  onDecrease: () {
                    setState(() {
                      selectedDay = selectedDay > 1 ? selectedDay - 1 : daysInMonth;
                    });
                  },
                  onIncrease: () {
                    setState(() {
                      selectedDay = selectedDay < daysInMonth ? selectedDay + 1 : 1;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  AppLocalizations.of(ctx)?.cancel ?? 'CANCEL',
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  final ethDate = EthiopianCalendar(selectedYear, selectedMonth, selectedDay);
                  Navigator.pop(ctx, ethDate.toGregorian());
                },
                child: Text(AppLocalizations.of(ctx)?.confirm ?? 'CONFIRM'),
              ),
            ],
          );
        },
      );
    },
  );

  return result;
}

Widget _buildSelector({
  required String label,
  required String value,
  required VoidCallback onDecrease,
  required VoidCallback onIncrease,
}) {
  return Row(
    children: [
      SizedBox(
        width: 60,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.textSecondary,
            letterSpacing: 1,
          ),
        ),
      ),
      IconButton(
        onPressed: onDecrease,
        icon: const Icon(Icons.chevron_left_rounded, color: AppTheme.primaryBlue),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.textSecondary.withOpacity(0.1)),
          ),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ),
      ),
      IconButton(
        onPressed: onIncrease,
        icon: const Icon(Icons.chevron_right_rounded, color: AppTheme.primaryBlue),
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    ],
  );
}
