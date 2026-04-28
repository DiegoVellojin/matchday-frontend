import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';


// NUESTRA CAJA DE HERRAMIENTAS Y TEMAS
import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';

import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart'; // NUEVO IMPORT
import 'features/main_hub/presentation/pages/main_hub_page.dart';
import 'features/teams_discovery/presentation/pages/create_team_page.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';
import 'features/teams_discovery/presentation/pages/team_dashboard_page.dart';




void main() async {
  // 1. Aseguramos que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();


  // 2. Inicializamos GetIt ANTES de correr la app
  await di.init();

  runApp(const MatchDayApp());
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomePage()),
    GoRoute(
      path: '/iniciar-sesion',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/crear-cuenta',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/recuperar-contrasena',
      builder: (context, state) => const ForgotPasswordPage(),
    ),
    // NUEVA RUTA: Atrapa el deep link y extrae el token de la URL
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        // Extraemos el ?token=... que viene del correo
        final token = state.uri.queryParameters['token'] ?? '';
        return ResetPasswordPage(token: token);
      },
    ),
    GoRoute(path: '/hub', builder: (context, state) => const MainHubPage()),
    GoRoute(path: '/crear-equipo', builder: (context, state) => const CreateTeamPage()),
    GoRoute(path: '/notificaciones', builder: (context, state) => const NotificationsPage()),
    GoRoute(
      path: '/team-dashboard/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return TeamDashboardPage(teamId: id);
      },
    ),
  ],


);


class MatchDayApp extends StatelessWidget {
  const MatchDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolvemos la app en el BLoC del Tema para que reaccione al Switch
    return BlocProvider(
      create: (_) => di.sl<ThemeBloc>(),
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, currentThemeMode) {
          return MaterialApp.router(
            title: 'MatchDay',
            debugShowCheckedModeBanner: false,
            // Aplicamos el tema dinámicamente basado en el estado del BLoC
            themeMode: currentThemeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
