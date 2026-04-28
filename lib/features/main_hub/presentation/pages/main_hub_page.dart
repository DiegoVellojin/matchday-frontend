import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../teams_discovery/presentation/pages/teams_discovery_page.dart';

class MainHubPage extends StatefulWidget {
  const MainHubPage({super.key});

  @override
  State<MainHubPage> createState() => _MainHubPageState();
}

class _MainHubPageState extends State<MainHubPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const TeamsDiscoveryPage(), // Reemplazamos el Skeleton con la página real
    const Center(child: Text('🏆 Partidos', style: TextStyle(fontSize: 24))),
    const Center(child: Text('📋 Mis Equipos', style: TextStyle(fontSize: 24))),
    const Center(child: Text('🏅 Rankings', style: TextStyle(fontSize: 24))),
  ];

  @override
  Widget build(BuildContext context) {
    // Detectamos si el tema actual es oscuro para hacer pequeños ajustes en los íconos inactivos
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _pages[_currentIndex],
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
