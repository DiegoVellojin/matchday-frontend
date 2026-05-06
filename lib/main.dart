import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'features/teams/presentation/pages/team_dashboard_page.dart';
import 'features/teams/presentation/pages/team_settings_page.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';
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
import 'features/matches/presentation/pages/captain_match_dashboard_page.dart';
import 'features/matches/presentation/pages/configure_match_page.dart';
import 'features/matches/presentation/pages/player_match_dashboard_page.dart';
import 'features/matches/presentation/pages/register_match_result_page.dart';
import 'features/matches/presentation/pages/accept_encounter_page.dart';
import 'features/matches/presentation/pages/match_history_page.dart';
import 'features/matches/presentation/pages/match_history_detail_page.dart';
import 'features/payments/presentation/pages/upload_receipt_page.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/payments/domain/entities/payment_entity.dart';
import 'features/profile/presentation/bloc/profile_event.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';
import 'features/notifications/presentation/bloc/notifications_event.dart';
import 'features/profile/domain/entities/profile_entity.dart';
import 'features/teams/domain/entities/team_entity.dart';
import 'features/matches/domain/repositories/matches_repository.dart';
import 'features/matches/domain/entities/match_entity.dart';

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
    
    
    // RUTAS AUTENTICADAS (Comparten los BLoCs de feature sin ensuciar la raíz)
    ShellRoute(
      builder: (context, state, child) {
        return RepositoryProvider<IMatchesRepository>(
          create: (_) => di.sl<IMatchesRepository>(),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => di.sl<MatchesBloc>()..add(LoadMatchesEvent())),
              BlocProvider(create: (_) => di.sl<TeamsBloc>()..add(LoadTeamsEvent())),
              BlocProvider(create: (_) => di.sl<MyTeamsBloc>()..add(LoadMyTeamsEvent())),
              BlocProvider(create: (_) => di.sl<PaymentsBloc>()..add(LoadMyPaymentsEvent())),
              BlocProvider(create: (_) => di.sl<LeaderboardBloc>()..add(LoadLeaderboardEvent())),
            ],
            child: child,
          ),
        );
      },
      routes: [
        GoRoute(
          path: '/hub',
          builder: (context, state) => const MainHubPage(),
        ),
        GoRoute(
          path: '/crear-equipo',
          builder: (context, state) => const CreateTeamPage(),
        ),
        GoRoute(
          path: '/team-dashboard/:id',
          builder: (context, state) {
            final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
            return TeamDashboardPage(teamId: id);
          },
        ),
        GoRoute(
          path: '/team-settings/:id',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final team = extra?['team'] as TeamEntity;
            final currentUserId = extra?['currentUserId'] as int;
            return TeamSettingsPage(team: team, currentUserId: currentUserId);
          },
        ),
        GoRoute(
          path: '/notificaciones',
          builder: (context, state) => const NotificationsPage(),
        ),
        GoRoute(
          path: '/perfil',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/editar-perfil',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final profile = extra?['profile'] as UserProfileEntity?;
            return EditProfilePage(profile: profile!);
          },
        ),
        GoRoute(
          path: '/match-dashboard',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final matchEntity = extra?['matchEntity'];
            return CaptainMatchDashboardPage(matchEntity: matchEntity);
          },
        ),
        GoRoute(
          path: '/accept-encounter',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final match = extra?['match'];
            return AcceptEncounterPage(match: match);
          },
        ),
        GoRoute(
          path: '/pagos',
          builder: (context, state) => const PaymentManagementPage(),
        ),
        GoRoute(
          path: '/upload-receipt',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final payment = extra?['payment'] as PaymentEntity;
            return UploadReceiptPage(pago: payment);
          },
        ),
        GoRoute(
          path: '/crear-partido',
          builder: (context, state) => const CreateMatchPage(),
        ),
        GoRoute(
          path: '/configure-match',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final matchEntity = extra?['matchEntity'];
            return ConfigureMatchPage(partido: matchEntity);
          },
        ),
        GoRoute(
          path: '/register-result',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final matchEntity = extra?['matchEntity'];
            return RegisterMatchResultPage(partido: matchEntity);
          },
        ),
        GoRoute(
          path: '/match-details/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return MatchDetailsPage(matchId: id);
          },
        ),
        GoRoute(
          path: '/player-match-dashboard',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>?;
            final match = extra?['match'] as MatchEntity;
            return PlayerMatchDashboardPage(match: match);
          },
        ),
        GoRoute(
          path: '/match-history',
          builder: (context, state) => const MatchHistoryPage(),
        ),
        GoRoute(
          path: '/match-history-detail/:id',
          builder: (context, state) {
            final id = int.parse(state.pathParameters['id']!);
            return MatchHistoryDetailPage(matchId: id);
          },
        ),
      ],
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
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es', 'ES'),
              Locale('en', 'US'),
            ],
            locale: const Locale('es', 'ES'),
          );
        },
      ),
    );

  }
}
