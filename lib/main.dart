import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/di/injection_container.dart' as di;
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';

import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'features/main_hub/presentation/pages/main_hub_page.dart';
import 'features/teams/presentation/pages/create_team_page.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';
import 'features/teams/presentation/pages/team_dashboard_page.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/profile/presentation/pages/edit_profile_page.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/matches/presentation/bloc/matches_bloc.dart';
import 'features/teams/presentation/bloc/teams_bloc.dart';
import 'features/teams/presentation/bloc/teams_event.dart';
import 'features/teams/presentation/bloc/my_teams_bloc.dart';
import 'features/teams/presentation/bloc/my_teams_event.dart';
import 'features/payments/presentation/bloc/payments_bloc.dart';
import 'features/payments/presentation/bloc/payments_event.dart';
import 'features/rankings/presentation/bloc/leaderboard_bloc.dart';
import 'features/rankings/presentation/bloc/leaderboard_event.dart';
import 'features/payments/presentation/pages/payment_management_page.dart';
import 'features/matches/presentation/pages/create_match_page.dart';
import 'features/matches/presentation/pages/match_details_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_event.dart';
import 'features/profile/domain/entities/profile_entity.dart';

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
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomePage()),
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
    GoRoute(
      path: '/hub',
      builder: (context, state) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => di.sl<MatchesBloc>()..add(LoadMatchesEvent())),
          BlocProvider(create: (_) => di.sl<TeamsBloc>()..add(LoadTeamsEvent())),
          BlocProvider(create: (_) => di.sl<MyTeamsBloc>()..add(LoadMyTeamsEvent())),
          BlocProvider(create: (_) => di.sl<PaymentsBloc>()..add(LoadMyPaymentsEvent())),
          BlocProvider(create: (_) => di.sl<LeaderboardBloc>()..add(LoadLeaderboardEvent())),
        ],
        child: const MainHubPage(),
      ),
    ),
    GoRoute(
      path: '/crear-equipo',
      builder: (context, state) => const CreateTeamPage(),
    ),
    GoRoute(
      path: '/notificaciones',
      builder: (context, state) => const NotificationsPage(),
    ),
    GoRoute(path: '/perfil', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/editar-perfil',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        final profile = extra['profile'] as UserProfileEntity;
        return EditProfilePage(profile: profile);
      },

    ),

    GoRoute(
      path: '/team-dashboard/:id',
      builder: (context, state) {
        final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
        return TeamDashboardPage(teamId: id);
      },
    ),
    GoRoute(
      path: '/pagos',
      builder: (context, state) => const PaymentManagementPage(),
    ),
    GoRoute(
      path: '/crear-partido',
      builder: (context, state) => const CreateMatchPage(),
    ),
    GoRoute(
      path: '/match-details/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return MatchDetailsPage(matchId: id);
      },
    ),
  ],
);

class MatchDayApp extends StatelessWidget {
  const MatchDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Envolvemos la app en el BLoC del Tema para que reaccione al Switch
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<ThemeBloc>()),
        BlocProvider(create: (_) => di.sl<ProfileBloc>()..add(LoadProfileEvent())),
        BlocProvider(create: (_) => di.sl<NotificationsBloc>()..add(LoadNotificationsEvent())),
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
      ],
      child: BlocBuilder<ThemeBloc, ThemeMode>(
        builder: (context, currentThemeMode) {
          return MaterialApp.router(
            title: 'MatchDay',
            debugShowCheckedModeBanner: false,
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
