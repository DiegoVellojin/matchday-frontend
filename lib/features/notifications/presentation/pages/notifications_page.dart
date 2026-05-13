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
      create: (_) =>
          sl<NotificationsBloc>()..add(MarkAllNotificationsAsReadEvent()),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<NotificationsBloc, NotificationsState>(
            builder: (context, state) =>
                MatchDayLoadingBar(isLoading: state is NotificationsLoading),
          ),
          Expanded(
            child: BlocConsumer<NotificationsBloc, NotificationsState>(
              listener: (context, state) {
                if (state is NotificationsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
                if (state is NotificationsLoaded) {
                  setState(() => _cachedNotifications = state.notifications);
                }
              },
              builder: (context, state) {
                if (state is NotificationsLoading &&
                    _cachedNotifications.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                if (_cachedNotifications.isEmpty &&
                    state is! NotificationsLoading) {
                  return _buildEmptyState(isDark);
                }

                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () async => context.read<NotificationsBloc>().add(
                    LoadNotificationsEvent(),
                  ),
                  child: ListView.separated(
                    itemCount: _cachedNotifications.length,
                    padding: const EdgeInsets.all(20),
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final notif = _cachedNotifications[index];
                      return _buildNotificationCard(notif, isDark, index);
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

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'TODO AL DÍA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No tienes notificaciones pendientes',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildNotificationCard(dynamic notif, bool isDark, int index) {
    final isRead = notif.isRead ?? false;
    final type = notif.type ?? 'default';

    return InkWell(
      onTap: () {
        if (!isRead) {
          context.read<NotificationsBloc>().add(
            MarkNotificationAsReadEvent(notif.id),
          );
        }
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: 300.ms,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead
              ? (isDark ? const Color(0xFF1F2937) : Colors.white)
              : AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isRead
                ? (isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05))
                : AppColors.primary.withValues(alpha: 0.3),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: isRead
              ? null
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconColor(type).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getIconData(type),
                color: _getIconColor(type),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isRead ? FontWeight.w600 : FontWeight.w900,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(notif.createdAt),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                margin: const EdgeInsets.only(top: 4, left: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1, end: 0);
  }

  IconData _getIconData(String type) {
    switch (type) {
      case 'join_request':
        return Icons.person_add_alt_1_rounded;
      case 'accepted':
        return Icons.verified_user_rounded;
      case 'rejected':
        return Icons.error_outline_rounded;
      case 'match_confirmed':
        return Icons.sports_soccer_rounded;
      default:
        return Icons.notifications_active_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'join_request':
        return AppColors.primary;
      case 'accepted':
        return Colors.greenAccent;
      case 'rejected':
        return Colors.redAccent;
      case 'match_confirmed':
        return Colors.blueAccent;
      default:
        return AppColors.primary;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now().toUtc();
    final createdAt = date.isUtc ? date : date.toUtc();
    final diff = now.difference(createdAt);
    
    if (diff.inSeconds < 60) return 'Ahora mismo';
    if (diff.inMinutes < 60) {
      final mins = diff.inMinutes;
      return mins > 0 ? 'Hace $mins min' : 'Ahora mismo';
    }
    if (diff.inHours < 24) {
      final hours = diff.inHours;
      return hours > 0 ? 'Hace $hours h' : 'Hace 1 h';
    }
    if (diff.inDays == 1) return 'Ayer';
    
    final displayDate = date.toLocal();
    return '${displayDate.day}/${displayDate.month}/${displayDate.year}';
  }
}
