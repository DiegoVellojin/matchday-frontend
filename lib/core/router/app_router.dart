import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animations/animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/injection_container.dart' as di;
import '../../features/auth/presentation/pages/welcome_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/main_hub/presentation/pages/main_hub_page.dart';
import '../../features/teams/presentation/pages/create_team_page.dart';
import '../../features/teams/presentation/pages/team_dashboard_page.dart';
import '../../features/teams/presentation/pages/team_settings_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/matches/presentation/pages/create_match_page.dart';
import '../../features/matches/presentation/pages/match_details_page.dart';
import '../../features/matches/presentation/pages/captain_match_dashboard_page.dart';
import '../../features/matches/presentation/pages/configure_match_page.dart';
import '../../features/matches/presentation/pages/player_match_dashboard_page.dart';
import '../../features/matches/presentation/pages/register_match_result_page.dart';
import '../../features/matches/presentation/pages/accept_encounter_page.dart';
import '../../features/matches/presentation/pages/match_history_page.dart';
import '../../features/matches/presentation/pages/match_history_detail_page.dart';
import '../../features/payments/presentation/pages/payment_management_page.dart';
import '../../features/payments/presentation/pages/upload_receipt_page.dart';
import '../../features/matches/presentation/pages/confirm_result_page.dart';
import '../../features/matches/domain/repositories/matches_repository.dart';
import '../../features/matches/domain/entities/match_entity.dart';
import '../../features/teams/domain/entities/team_entity.dart';
import '../../features/profile/domain/entities/profile_entity.dart';
import '../../features/payments/domain/entities/payment_entity.dart';
import '../../features/matches/presentation/bloc/matches_bloc.dart';
import '../../features/teams/presentation/bloc/teams_bloc.dart';
import '../../features/teams/presentation/bloc/teams_event.dart';
import '../../features/teams/presentation/bloc/my_teams_bloc.dart';
import '../../features/teams/presentation/bloc/my_teams_event.dart';
import '../../features/payments/presentation/bloc/payments_bloc.dart';
import '../../features/payments/presentation/bloc/payments_event.dart';
import '../../features/rankings/presentation/bloc/leaderboard_bloc.dart';
import '../../features/rankings/presentation/bloc/leaderboard_event.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/bloc/profile_state.dart';

class AppRouter {
  static Page<T> _buildTransitionPage<T>({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<T>(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          child: child,
        );
      },
    );
  }

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const SplashPage())),
      GoRoute(path: '/welcome', pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const WelcomePage())),
      GoRoute(
        path: '/iniciar-sesion',
        pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const LoginPage()),
      ),
      GoRoute(
        path: '/crear-cuenta',
        pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const RegisterPage()),
      ),
      GoRoute(
        path: '/recuperar-contrasena',
        pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const ForgotPasswordPage()),
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) {
          final token = state.uri.queryParameters['token'] ?? '';
          return _buildTransitionPage(context: context, state: state, child: ResetPasswordPage(token: token));
        },
      ),
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
            pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const MainHubPage()),
          ),
          GoRoute(
            path: '/crear-equipo',
            pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const CreateTeamPage()),
          ),
          GoRoute(
            path: '/team-dashboard/:id',
            pageBuilder: (context, state) {
              final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
              return _buildTransitionPage(context: context, state: state, child: TeamDashboardPage(teamId: id));
            },
          ),
          GoRoute(
            path: '/team-settings/:id',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final team = extra?['team'] as TeamEntity;
              final currentUserId = extra?['currentUserId'] as int;
              return _buildTransitionPage(context: context, state: state, child: TeamSettingsPage(team: team, currentUserId: currentUserId));
            },
          ),
          GoRoute(
            path: '/notificaciones',
            pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const NotificationsPage()),
          ),
          GoRoute(
            path: '/perfil',
            pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const ProfilePage()),
          ),
          GoRoute(
            path: '/editar-perfil',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final profile = extra?['profile'] as UserProfileEntity?;
              return _buildTransitionPage(context: context, state: state, child: EditProfilePage(profile: profile!));
            },
          ),
          GoRoute(
            path: '/configuracion',
            pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const SettingsPage()),
          ),
          GoRoute(
            path: '/match-dashboard',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final matchEntity = extra?['matchEntity'];
              return _buildTransitionPage(context: context, state: state, child: CaptainMatchDashboardPage(matchEntity: matchEntity));
            },
          ),
          GoRoute(
            path: '/accept-encounter',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final match = extra?['match'];
              return _buildTransitionPage(context: context, state: state, child: AcceptEncounterPage(match: match));
            },
          ),
          GoRoute(
            path: '/payment-management',
            pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const PaymentManagementPage()),
          ),
          GoRoute(
            path: '/upload-receipt',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final payment = extra?['payment'] as PaymentEntity;
              return _buildTransitionPage(context: context, state: state, child: UploadReceiptPage(pago: payment));
            },
          ),
          GoRoute(
            path: '/crear-partido',
            pageBuilder: (context, state) {
              final match = state.extra as MatchEntity?;
              return _buildTransitionPage(context: context, state: state, child: CreateMatchPage(editMatch: match));
            },
          ),
          GoRoute(
            path: '/configure-match',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final matchEntity = extra?['matchEntity'];
              return _buildTransitionPage(context: context, state: state, child: ConfigureMatchPage(partido: matchEntity));
            },
          ),
          GoRoute(
            path: '/register-result',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final matchEntity = extra?['matchEntity'];
              return _buildTransitionPage(context: context, state: state, child: RegisterMatchResultPage(partido: matchEntity));
            },
          ),
          GoRoute(
            path: '/match-details/:id',
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return _buildTransitionPage(context: context, state: state, child: MatchDetailsPage(matchId: id));
            },
          ),
          GoRoute(
            path: '/player-match-dashboard',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final match = extra?['match'] as MatchEntity;
              return _buildTransitionPage(context: context, state: state, child: PlayerMatchDashboardPage(match: match));
            },
          ),
          GoRoute(
            path: '/match-history',
            pageBuilder: (context, state) => _buildTransitionPage(context: context, state: state, child: const MatchHistoryPage()),
          ),
          GoRoute(
            path: '/match-history-detail/:id',
            pageBuilder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return _buildTransitionPage(context: context, state: state, child: MatchHistoryDetailPage(matchId: id));
            },
          ),
          GoRoute(
            path: '/confirm-result',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final matchEntity = extra?['matchEntity'] as MatchEntity;
              final profileState = context.read<ProfileBloc>().state;
              final currentUserId = profileState is ProfileLoaded ? profileState.profile.id : 0;
              return _buildTransitionPage(
                context: context,
                state: state,
                child: ConfirmarResultadoPage(
                  match: matchEntity,
                  currentUserId: currentUserId,
                ),
              );
            },
          ),
        ],
      ),
    ],
  );
}
