import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/notifications_bloc.dart';
import '../bloc/notifications_event.dart';
import '../bloc/notifications_state.dart';
import '../../../../core/widgets/matchday_loading_bar.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsBloc>()..add(MarkAllNotificationsAsReadEvent()),
      child: const _NotificationsView(),
    );
  }
}


class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  List<dynamic> _cachedNotifications = [];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.background : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.surface : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Notificaciones',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.border : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) {
              return MatchDayLoadingBar(isLoading: state is NotificationsLoading);
            },
          ),
          Expanded(
            child: BlocConsumer<NotificationsBloc, NotificationsState>(
              listener: (context, state) {
                if (state is NotificationsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                }
                if (state is NotificationsLoaded) {
                  setState(() => _cachedNotifications = state.notifications);
                }
              },
              builder: (context, state) {
                if (state is NotificationsLoading && _cachedNotifications.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (_cachedNotifications.isEmpty && state is! NotificationsLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_none_outlined,
                          size: 64,
                          color: isDark ? AppColors.textHint : Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No tienes notificaciones todavía.',
                          style: TextStyle(
                            color: isDark ? AppColors.textMuted : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async {
                    context.read<NotificationsBloc>().add(LoadNotificationsEvent());
                  },
                  child: ListView.separated(
                    itemCount: _cachedNotifications.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    separatorBuilder: (context, index) => Divider(
                      color: isDark ? AppColors.border : Colors.grey.shade100,
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final notif = _cachedNotifications[index];

                      return InkWell(
                        onTap: () {
                          if (!notif.isRead) {
                            context
                                .read<NotificationsBloc>()
                                .add(MarkNotificationAsReadEvent(notif.id));
                          }
                        },
                        child: Container(
                          color: !notif.isRead
                              ? (isDark
                                  ? AppColors.surface
                                  : Colors.blue.shade50)
                              : Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: _getIconBgColor(notif.type),
                                radius: 20,
                                child: Icon(
                                  _getIconData(notif.type),
                                  color: Colors.black,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif.message,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 14,
                                        fontWeight: !notif.isRead
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatDate(notif.createdAt),
                                      style: TextStyle(
                                        color: isDark
                                            ? const Color(0xFF6B7280)
                                            : Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!notif.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                        ).animate()
                         .fadeIn(duration: 400.ms, delay: (index * 40).ms)
                         .slideX(begin: 0.1, end: 0),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String? type) {
    switch (type) {
      case 'join_request':
        return Icons.group_add_outlined;
      case 'accepted':
        return Icons.check_circle_outline;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_none;
    }
  }

  Color _getIconBgColor(String? type) {
    switch (type) {
      case 'join_request':
        return AppColors.primary;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return AppColors.textMuted;
    }
  }

  String _formatDate(DateTime date) {
    final dateUtc = date.isUtc ? date : date.toUtc();
    final nowUtc = DateTime.now().toUtc();
    final diff = nowUtc.difference(dateUtc);

    if (diff.isNegative) return 'Hace un momento';
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    final dateLocal = dateUtc.toLocal();
    return '${dateLocal.day}/${dateLocal.month}/${dateLocal.year}';
  }
}
