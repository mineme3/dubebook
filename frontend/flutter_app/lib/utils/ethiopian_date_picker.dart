import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

  // Helper translations for languages: en, am, om, so
  String getTxt(String key) {
    final translations = {
      'title': {
        'en': 'Set Payment Deadline',
        'am': 'የክፍያ ቀነ-ገደብ ያስቀምጡ',
        'om': 'Guyyaa Kaffaltii Filadhu',
        'so': 'U dooro Taariikhda Bixinta',
      },
      'presets': {
        'en': 'QUICK PRESETS',
        'am': 'ፈጣን ምርጫዎች',
        'om': 'FILANNOO DAFFEEN',
        'so': 'DIIYAAR GAROWGŪS',
      },
      'custom': {
        'en': 'CUSTOM DATE SELECTOR',
        'am': 'የቀን መምረጫ',
        'om': 'GUYYAA FILADHU',
        'so': 'TAARIIKH KALE',
      },
      'one_week': {
        'en': '1 Week',
        'am': '1 ሳምንት',
        'om': 'Torban 1',
        'so': '1 Toddobaad',
      },
      'two_weeks': {
        'en': '2 Weeks',
        'am': '2 ሳምንት',
        'om': 'Torban 2',
        'so': '2 Toddobaad',
      },
      'one_month': {
        'en': '1 Month',
        'am': '1 ወር',
        'om': 'Ji\'a 1',
        'so': '1 Bil',
      },
      'today': {
        'en': 'Today',
        'am': 'ዛሬ',
        'om': 'Har\'a',
        'so': 'Maanta',
      },
      'gregorian_eq': {
        'en': 'Gregorian Equivalent',
        'am': 'የፈረንጆች ቀን አቻ',
        'om': 'Guyyaa Awurooppaa',
        'so': 'Taariikhda Miilaadiga',
      },
      'due_today': {
        'en': 'Due today',
        'am': 'ዛሬ የሚከፈል',
        'om': 'Har\'a kaffalama',
        'so': 'Maanta kaffal',
      },
      'due_tomorrow': {
        'en': 'Due tomorrow',
        'am': 'ነገ የሚከፈል',
        'om': 'Bori kaffalama',
        'so': 'Berri kaffal',
      },
      'due_in_days': {
        'en': 'Due in {n} days',
        'am': 'በ {n} ቀናት ውስጥ የሚከፈል',
        'om': 'Guyyoota {n} keessatti',
        'so': 'Ku bixi {n} cisho',
      },
      'past_date': {
        'en': 'Past Date (Cannot confirm)',
        'am': 'ያለፈ ቀን (ማረጋገጥ አይቻልም)',
        'om': 'Guyyaa darbe (Mirkaneessuun hin danda\'amu)',
        'so': 'Taariikh tagtay (Lama xaqiijin karo)',
      },
      'cancel': {
        'en': 'CANCEL',
        'am': 'አቋርጥ',
        'om': 'HAQI',
        'so': 'HURŪR',
      },
      'confirm': {
        'en': 'CONFIRM',
        'am': 'አረጋግጥ',
        'om': 'MIRKANEESSI',
        'so': 'XAQIIQI',
      },
      'year': {
        'en': 'Year',
        'am': 'ዓመት',
        'om': 'Waggaa',
        'so': 'Sannad',
      },
      'month': {
        'en': 'Month',
        'am': 'ወር',
        'om': 'Ji\'a',
        'so': 'Bil',
      },
      'day': {
        'en': 'Day',
        'am': 'ቀን',
        'om': 'Guyyaa',
        'so': 'Maalin',
      }
    };
    return translations[key]?[locale] ?? translations[key]?['en'] ?? '';
  }

  return showDialog<DateTime>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) {
        final daysInMonth = EthiopianCalendar.daysInMonth(selectedYear, selectedMonth);
        if (selectedDay > daysInMonth) selectedDay = daysInMonth;

        final selectedGregorian = EthiopianCalendar(selectedYear, selectedMonth, selectedDay).toGregorian();
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final target = DateTime(selectedGregorian.year, selectedGregorian.month, selectedGregorian.day);
        final difference = target.difference(today).inDays;
        
        final isPast = target.isBefore(today);

        List<String> monthNames = locale == 'am' 
            ? EthiopianCalendar.monthNamesAm 
            : (locale == 'om' ? EthiopianCalendar.monthNamesOm : EthiopianCalendar.monthNamesEn);

        // Predefine preset Dates
        final presetsList = [
          {'label': getTxt('today'), 'days': 0},
          {'label': getTxt('one_week'), 'days': 7},
          {'label': getTxt('two_weeks'), 'days': 14},
          {'label': getTxt('one_month'), 'days': 30},
        ];

        // Format relative label
        String relativeLabel = '';
        if (isPast) {
          relativeLabel = getTxt('past_date');
        } else if (difference == 0) {
          relativeLabel = getTxt('due_today');
        } else if (difference == 1) {
          relativeLabel = getTxt('due_tomorrow');
        } else {
          relativeLabel = getTxt('due_in_days').replaceAll('{n}', difference.toString());
        }

        void applyPreset(int days) {
          final targetDate = now.add(Duration(days: days));
          final eth = EthiopianCalendar.fromGregorian(targetDate);
          setState(() {
            selectedYear = eth.year;
            selectedMonth = eth.month;
            selectedDay = eth.day;
          });
        }

        // Helper widget to build Column/Row of presets
        Widget buildPresetsGrid() {
          return GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: presetsList.map((preset) {
              final days = preset['days'] as int;
              final presetGregorian = now.add(Duration(days: days));
              final presetEth = EthiopianCalendar.fromGregorian(presetGregorian);
              
              final isSelected = selectedYear == presetEth.year &&
                  selectedMonth == presetEth.month &&
                  selectedDay == presetEth.day;

              return InkWell(
                onTap: () => applyPreset(days),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary : tokens.surfaceLow,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : tokens.surfaceBorder,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppTheme.primary.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      )
                    ] : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        preset['label'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? AppTheme.background : AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        presetEth.format(locale: locale),
                        style: TextStyle(
                          fontSize: 10,
                          color: isSelected ? AppTheme.background.withOpacity(0.8) : AppTheme.textMuted,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        }

        Widget buildColumnSelector({
          required String label,
          required String value,
          required VoidCallback onDec,
          required VoidCallback onInc,
        }) {
          return Expanded(
            child: Column(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: tokens.surfaceLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: tokens.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      IconButton(
                        onPressed: onInc,
                        icon: const Icon(Icons.keyboard_arrow_up, size: 20, color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        constraints: const BoxConstraints(),
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          border: Border.symmetric(
                            horizontal: BorderSide(color: tokens.surfaceBorder.withOpacity(0.5)),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            value,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: onDec,
                        icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppTheme.primary),
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return Dialog(
          backgroundColor: AppTheme.background,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title / Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.event, color: AppTheme.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          getTxt('title'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 24, color: tokens.surfaceBorder),

                  // Presets Section
                  Text(
                    getTxt('presets'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  buildPresetsGrid(),
                  const SizedBox(height: 20),

                  // Custom Selector Section
                  Text(
                    getTxt('custom'),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Month
                      buildColumnSelector(
                        label: getTxt('month'),
                        value: monthNames[selectedMonth - 1],
                        onDec: () => setState(() => selectedMonth = selectedMonth > 1 ? selectedMonth - 1 : 13),
                        onInc: () => setState(() => selectedMonth = selectedMonth < 13 ? selectedMonth + 1 : 1),
                      ),
                      const SizedBox(width: 8),
                      // Day
                      buildColumnSelector(
                        label: getTxt('day'),
                        value: selectedDay.toString(),
                        onDec: () => setState(() => selectedDay = selectedDay > 1 ? selectedDay - 1 : daysInMonth),
                        onInc: () => setState(() => selectedDay = selectedDay < daysInMonth ? selectedDay + 1 : 1),
                      ),
                      const SizedBox(width: 8),
                      // Year
                      buildColumnSelector(
                        label: getTxt('year'),
                        value: selectedYear.toString(),
                        onDec: () => setState(() => selectedYear--),
                        onInc: () => setState(() => selectedYear++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Live Preview Details Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isPast 
                          ? AppTheme.error.withOpacity(0.06) 
                          : AppTheme.primary.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isPast 
                            ? AppTheme.error.withOpacity(0.15) 
                            : AppTheme.primary.withOpacity(0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          EthiopianCalendar(selectedYear, selectedMonth, selectedDay).format(locale: locale),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isPast ? AppTheme.error : AppTheme.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${getTxt('gregorian_eq')}: ',
                              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(selectedGregorian),
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isPast 
                                ? AppTheme.error.withOpacity(0.1) 
                                : (difference == 0 ? tokens.warning.withOpacity(0.1) : tokens.successMuted),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            relativeLabel,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isPast 
                                  ? AppTheme.error 
                                  : (difference == 0 ? tokens.warning : AppTheme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dialog Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          getTxt('cancel'),
                          style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: isPast ? null : () => Navigator.pop(ctx, selectedGregorian),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.background,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        child: Text(
                          getTxt('confirm'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
