import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_colors.dart';
import '../theme/bloc/theme_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/profile_state.dart';
import '../../features/profile/presentation/bloc/profile_event.dart';
import '../../features/notifications/presentation/bloc/notifications_bloc.dart';
import '../../features/notifications/presentation/bloc/notifications_state.dart';

class MatchDayAppBar extends StatelessWidget {
  const MatchDayAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  String? photoUrl;
                  if (profileState is ProfileLoaded) {
                    photoUrl = profileState.profile.photoUrl;
                  } else if (profileState is ProfileUpdateSuccess) {
                    photoUrl = profileState.profile.photoUrl;
                  } else if (profileState is ProfileInitial) {
                    context.read<ProfileBloc>().add(LoadProfileEvent());
                  }

                  return InkWell(
                    onTap: () => context.push('/perfil'),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: CircleAvatar(
                        backgroundColor: Colors.transparent,
                        radius: 18,
                        backgroundImage: (photoUrl != null && photoUrl.isNotEmpty && photoUrl.startsWith('http'))
                            ? NetworkImage(photoUrl)
                            : null,
                        child: (photoUrl == null || photoUrl.isEmpty || !photoUrl.startsWith('http'))
                            ? const Icon(Icons.person_outline, color: AppColors.primary, size: 20)
                            : null,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Text(
                'MatchDay',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              BlocBuilder<ThemeBloc, ThemeMode>(
                builder: (context, themeMode) {
                  final isDarkTheme = themeMode == ThemeMode.dark;
                  return IconButton(
                    icon: Icon(
                      isDarkTheme ? Icons.light_mode : Icons.dark_mode,
                      color: colorScheme.onSurface,
                    ),
                    onPressed: () => context.read<ThemeBloc>().add(ToggleThemeEvent()),
                  );
                },
              ),
              BlocBuilder<NotificationsBloc, NotificationsState>(
                builder: (context, notifState) {
                  bool hasUnread = false;
                  if (notifState is NotificationsLoaded) {
                    hasUnread = notifState.notifications.any((n) => !n.isRead);
                  }

                  return IconButton(
                    icon: Icon(
                      hasUnread ? Icons.notifications : Icons.notifications_none_outlined,
                      color: hasUnread ? AppColors.primary : colorScheme.onSurface,
                    ),
                    onPressed: () => context.push('/notificaciones'),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
