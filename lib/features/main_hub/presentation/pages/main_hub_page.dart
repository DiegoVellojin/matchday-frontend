import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Importamos el BLoC del Tema y nuestros colores
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/app_colors.dart';

class MainHubPage extends StatefulWidget {
  const MainHubPage({super.key});

  @override
  State<MainHubPage> createState() => _MainHubPageState();
}

class _MainHubPageState extends State<MainHubPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _EquiposViewSkeleton(),
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
          unselectedItemColor: isDark ? const Color(0xFF6B7280) : Colors.grey[600],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.people_outline)), activeIcon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.people)), label: 'Equipos'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.emoji_events_outlined)), activeIcon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.emoji_events)), label: 'Partidos'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.checklist_rtl_outlined)), activeIcon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.checklist_rtl)), label: 'Mis Equipos'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.military_tech_outlined)), activeIcon: Padding(padding: EdgeInsets.only(bottom: 4.0), child: Icon(Icons.military_tech)), label: 'Rankings'),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// SKELETON ADAPTATIVO
// =====================================================================
class _EquiposViewSkeleton extends StatelessWidget {
  const _EquiposViewSkeleton();

  @override
  Widget build(BuildContext context) {
    // Traemos la paleta de colores del contexto actual (blanca o negra)
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            
            // 1. Custom AppBar con el BOTÓN DE TEMA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  radius: 20,
                  child: Icon(Icons.person_outline, color: Colors.black),
                ),
                Text(
                  'MatchDay',
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                // Aquí conectamos el botón de la lunita/sol al Bloc
                BlocBuilder<ThemeBloc, ThemeMode>(
                  builder: (context, themeMode) {
                    final isDarkTheme = themeMode == ThemeMode.dark;
                    return IconButton(
                      icon: Icon(
                        isDarkTheme ? Icons.light_mode : Icons.dark_mode, 
                        color: colorScheme.onSurface, // Se adapta al modo claro/oscuro
                      ),
                      onPressed: () {
                        context.read<ThemeBloc>().add(ToggleThemeEvent());
                      },
                    );
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // 2. Barra de Búsqueda Adaptativa
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: colorScheme.surface, // Blanco en Light, Gris oscuro en Dark
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade300),
              ),
              child: TextField(
                style: TextStyle(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600),
                  hintText: 'Buscar equipos...',
                  hintStyle: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade500),
                  border: InputBorder.none,
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // 3. Chips de Filtro Adaptativos
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildChip(context, 'Todos los Deportes', isActive: true),
                  const SizedBox(width: 12),
                  _buildChip(context, 'Fútbol'),
                  const SizedBox(width: 12),
                  _buildChip(context, 'Baloncesto'),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            Expanded(
              child: Center(
                child: Text(
                  'Lista de Equipos en construcción...', 
                  style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600)
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componente rápido para los filtros
  Widget _buildChip(BuildContext context, String label, {bool isActive = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? Colors.transparent : (isDark ? Colors.transparent : Colors.grey.shade300)
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.black : colorScheme.onSurface,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}