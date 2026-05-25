import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/theme.dart';
import '../../../utils/ethiopian_calendar.dart';
import '../../../core/providers/api_client_provider.dart';

/// Provider to fetch notification logs from the backend
final notificationLogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/notifications/log');
  return (response.data as List).cast<Map<String, dynamic>>();
});

class NotificationLogScreen extends ConsumerWidget {
  const NotificationLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(notificationLogProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('NOTIFICATIONS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryBlue),
            onPressed: () => ref.invalidate(notificationLogProvider),
          ),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primaryBlue)),
        error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.error_outline_rounded, size: 48, color: AppTheme.error),
          const SizedBox(height: 12),
          Text('Failed to load notifications', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextButton(onPressed: () => ref.invalidate(notificationLogProvider), child: const Text('Retry')),
        ])),
        data: (logs) {
          if (logs.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.notifications_none_rounded, size: 80, color: AppTheme.textSecondary.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text('NO NOTIFICATIONS YET', style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.3), fontWeight: FontWeight.w900, letterSpacing: 2)),
            ]));
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final type = log['type'] as String? ?? 'unknown';
              final message = log['message'] as String? ?? '';
              final sentAt = DateTime.tryParse(log['sentAt'] as String? ?? '');
              final status = log['deliveryStatus'] as String? ?? 'unknown';
              final isSent = status == 'sent';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSent ? AppTheme.accentGreen.withOpacity(0.2) : AppTheme.error.withOpacity(0.2)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(isSent ? Icons.check_circle_rounded : Icons.error_rounded,
                      size: 18, color: isSent ? AppTheme.accentGreen : AppTheme.error),
                    const SizedBox(width: 8),
                    Expanded(child: Text(type.replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1,
                        color: isSent ? AppTheme.accentGreen : AppTheme.error))),
                    if (sentAt != null) Text(
                      EthiopianCalendar.fromGregorian(sentAt).format(locale: locale),
                      style: TextStyle(fontSize: 10, color: AppTheme.textSecondary.withOpacity(0.5), fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(height: 10),
                  Text(message, maxLines: 3, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary, fontWeight: FontWeight.w500, height: 1.5)),
                  if (!isSent && log['errorMessage'] != null) ...[
                    const SizedBox(height: 8),
                    Text('Error: ${log['errorMessage']}',
                      style: TextStyle(fontSize: 10, color: AppTheme.error.withOpacity(0.7), fontWeight: FontWeight.w600)),
                  ],
                ]),
              );
            },
          );
        },
      ),
    );
  }
}
