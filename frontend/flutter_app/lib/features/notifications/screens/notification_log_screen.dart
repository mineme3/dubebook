import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/theme.dart';
import '../../../utils/ethiopian_calendar.dart';
import '../../../core/providers/api_client_provider.dart';
import '../../../shared/widgets/components/saas_components.dart';

final notificationLogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/notifications');
  return (response.data as List).cast<Map<String, dynamic>>();
});

class NotificationLogScreen extends ConsumerWidget {
  const NotificationLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(notificationLogProvider);
    final locale = Localizations.localeOf(context).languageCode;
    final tokens = Theme.of(context).extension<DubeTokens>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ALERTS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_outlined),
            tooltip: 'Mark all as read',
            onPressed: () async {
              try {
                final dio = ref.read(dioProvider);
                await dio.post('/notifications/mark-all-read');
                ref.invalidate(notificationLogProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All notifications marked as read')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear read notifications',
            onPressed: () async {
              try {
                final dio = ref.read(dioProvider);
                await dio.delete('/notifications/clear-read');
                ref.invalidate(notificationLogProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Read notifications cleared')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to clear: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(notificationLogProvider),
          ),
        ],
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (logs) {
          if (logs.isEmpty) {
            return const SaaSEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'All clear',
              description: 'You have no alerts or notifications at this time.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: logs.length,
            itemBuilder: (context, index) {
              final log = logs[index];
              final id = log['id'] as String? ?? '';
              final type = log['type'] as String? ?? 'info';
              final title = log['title'] as String? ?? 'Alert';
              final message = log['message'] as String? ?? '';
              final createdAtStr = log['createdAt'] as String?;
              final createdAt = createdAtStr != null ? DateTime.tryParse(createdAtStr) : null;
              final isRead = log['isRead'] as bool? ?? false;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: Key(id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                  ),
                  onDismissed: (direction) async {
                    try {
                      final dio = ref.read(dioProvider);
                      await dio.delete('/notifications/$id');
                      ref.invalidate(notificationLogProvider);
                    } catch (_) {}
                  },
                  child: SaaSCard(
                    onTap: () async {
                      if (!isRead) {
                        try {
                          final dio = ref.read(dioProvider);
                          await dio.patch('/notifications/$id/read');
                          ref.invalidate(notificationLogProvider);
                        } catch (_) {}
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: isRead ? tokens.surfaceHigh : AppTheme.primary.withOpacity(0.1),
                              child: Icon(
                                isRead ? Icons.notifications_none_rounded : Icons.notifications_active_rounded,
                                size: 14,
                                color: isRead ? tokens.onSurfaceMuted : AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  color: isRead ? tokens.onSurfaceMuted : tokens.onSurface,
                                ),
                              ),
                            ),
                            if (createdAt != null)
                              Text(
                                EthiopianCalendar.fromGregorian(createdAt).format(locale: locale),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          message,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                            color: isRead ? tokens.onSurfaceMuted : tokens.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              type.replaceAll('_', ' ').toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isRead ? tokens.onSurfaceMuted : AppTheme.primary,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded),
                              iconSize: 18,
                              color: tokens.onSurfaceMuted,
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                              onPressed: () async {
                                try {
                                  final dio = ref.read(dioProvider);
                                  await dio.delete('/notifications/$id');
                                  ref.invalidate(notificationLogProvider);
                                } catch (_) {}
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
