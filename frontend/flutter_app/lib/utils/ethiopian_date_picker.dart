import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'ethiopian_calendar.dart';
import 'theme.dart';

Future<DateTime?> showEthiopianDatePicker({
  required BuildContext context,
  DateTime? initialDate,
}) async {
  final ethNow = EthiopianCalendar.now();
  final EthiopianCalendar initial = initialDate != null ? EthiopianCalendar.fromGregorian(initialDate) : ethNow;

  int selectedYear = initial.year;
  int selectedMonth = initial.month;
  int selectedDay = initial.day;

  final locale = Localizations.localeOf(context).languageCode;
  final tokens = Theme.of(context).extension<DubeTokens>()!;

  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final daysInMonth = EthiopianCalendar.daysInMonth(selectedYear, selectedMonth);
        if (selectedDay > daysInMonth) selectedDay = daysInMonth;

        final selectedGregorian = EthiopianCalendar(selectedYear, selectedMonth, selectedDay).toGregorian();
        final isPast = selectedGregorian.isBefore(DateTime.now().subtract(const Duration(days: 1)));

        List<String> monthNames = locale == 'am' ? EthiopianCalendar.monthNamesAm : (locale == 'om' ? EthiopianCalendar.monthNamesOm : EthiopianCalendar.monthNamesEn);

        return AlertDialog(
          title: Text(locale == 'am' ? 'ቀን ይምረጡ' : 'Select Date'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: tokens.surfaceLow, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Center(child: Text(EthiopianCalendar(selectedYear, selectedMonth, selectedDay).format(locale: locale), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primary))),
              ),
              const SizedBox(height: 24),
              _buildSelector(context, label: 'Year', value: selectedYear.toString(), onDec: () => setState(() => selectedYear--), onInc: () => setState(() => selectedYear++)),
              const SizedBox(height: 12),
              _buildSelector(context, label: 'Month', value: monthNames[selectedMonth - 1], onDec: () => setState(() => selectedMonth = selectedMonth > 1 ? selectedMonth - 1 : 13), onInc: () => setState(() => selectedMonth = selectedMonth < 13 ? selectedMonth + 1 : 1)),
              const SizedBox(height: 12),
              _buildSelector(context, label: 'Day', value: selectedDay.toString(), onDec: () => setState(() => selectedDay = selectedDay > 1 ? selectedDay - 1 : daysInMonth), onInc: () => setState(() => selectedDay = selectedDay < daysInMonth ? selectedDay + 1 : 1)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
            ElevatedButton(onPressed: isPast ? null : () => Navigator.pop(ctx, selectedGregorian), child: const Text('CONFIRM')),
          ],
        );
      },
    ),
  );
}

Widget _buildSelector(BuildContext context, {required String label, required String value, required VoidCallback onDec, required VoidCallback onInc}) {
  final tokens = Theme.of(context).extension<DubeTokens>()!;
  return Row(
    children: [
      IconButton(onPressed: onDec, icon: const Icon(Icons.chevron_left, color: AppTheme.primary)),
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(color: tokens.surfaceLow, borderRadius: BorderRadius.circular(8)),
          child: Center(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ),
      ),
      IconButton(onPressed: onInc, icon: const Icon(Icons.chevron_right, color: AppTheme.primary)),
    ],
  );
}
