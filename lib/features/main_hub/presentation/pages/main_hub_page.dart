import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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

  @override
  void initState() {
    super.initState();
    // Aseguramos que el perfil esté cargado para que los roles (Capitán/Jugador) sean correctos
    context.read<ProfileBloc>().add(LoadProfileEvent());
    _setupPushNotifications();
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
          debugPrint('🔑 FCM_TOKEN_DISPOSITIVO: $fcmToken');

          final networkRobot = sl<NetworkRobot>();
          await networkRobot.post(
            '/users/fcm-token',
            data: {'fcm_token': fcmToken},
          );
          debugPrint('Token FCM enviado exitosamente al backend.');
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
    // Detectamos si el tema actual es oscuro para hacer pequeños ajustes en los íconos inactivos
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const MatchDayAppBar(),
            Expanded(child: _pages[_currentIndex]),
          ],
        ),
      ),
      bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              // Usa el color del borde configurado en el AppTheme (claro u oscuro)
              top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            // Usa el color de fondo configurado en el AppTheme
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: isDark
                ? const Color(0xFF6B7280)
                : Colors.grey[600],
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.people_outline),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.people),
                ),
                label: 'Equipos',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.emoji_events_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.emoji_events),
                ),
                label: 'Partidos',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.checklist_rtl_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.checklist_rtl),
                ),
                label: 'Mis Equipos',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.military_tech_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 4.0),
                  child: Icon(Icons.military_tech),
                ),
                label: 'Rankings',
              ),
            ],
          ),
        ),
    );
  }
}
