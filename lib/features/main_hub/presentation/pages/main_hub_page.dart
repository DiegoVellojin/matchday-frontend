import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/network_robot.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../teams/presentation/pages/teams_page.dart';
import '../../../teams/presentation/pages/my_teams_page.dart';
import '../../../../core/widgets/matchday_app_bar.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_event.dart';
import '../../../matches/presentation/pages/matches_page.dart';
import '../../../rankings/presentation/pages/leaderboard_page.dart';

class MainHubPage extends StatefulWidget {
  const MainHubPage({super.key});

  @override
  State<MainHubPage> createState() => _MainHubPageState();
}

class _MainHubPageState extends State<MainHubPage> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    context.read<ProfileBloc>().add(LoadProfileEvent());
    _setupPushNotifications();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _setupPushNotifications() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        String? fcmToken = await messaging.getToken();
        if (fcmToken != null) {
          final networkRobot = sl<NetworkRobot>();
          await networkRobot.post(
            '/users/fcm-token',
            data: {'fcm_token': fcmToken},
          );
        }
      }
    } catch (e) {
      debugPrint('Error al configurar notificaciones push: $e');
    }
  }

  final List<Widget> _pages = [
    const TeamsPage(),
    const MatchesPage(),
    const MyTeamsPage(),
    const LeaderboardPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                const MatchDayAppBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    physics: const BouncingScrollPhysics(),
                    children: _pages,
                  ),
                ),
                // Padding for the custom floating nav bar
                const SizedBox(height: 85),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _CustomFloatingNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutQuart,
                );
              },
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDark;

  const _CustomFloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isDark ? const Color(0xFF1F2937) : Colors.white;
    
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(35),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _NavBarItem(
            icon: Icons.people_outline,
            activeIcon: Icons.people,
            label: 'Equipos',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            icon: Icons.emoji_events_outlined,
            activeIcon: Icons.emoji_events,
            label: 'Partidos',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavBarItem(
            icon: Icons.checklist_rtl_outlined,
            activeIcon: Icons.checklist_rtl,
            label: 'Mis Equipos',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavBarItem(
            icon: Icons.military_tech_outlined,
            activeIcon: Icons.military_tech,
            label: 'Rankings',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 800.ms, curve: Curves.easeOutQuart);
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : Colors.grey[500];

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 24,
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
            child: Text(label),
          ),
          if (isSelected)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ).animate().scale(duration: 200.ms),
        ],
      ),
    );
  }
}
