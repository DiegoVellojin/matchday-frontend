import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../widgets/match_history_list.dart';
import '../widgets/match_history_skeleton.dart';

class MatchHistoryPage extends StatelessWidget {
  const MatchHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<MatchesBloc>()..add(LoadMatchesEvent(status: 'completada', mine: true)),
      child: const _MatchHistoryView(),
    );
  }
}

class _MatchHistoryView extends StatelessWidget {
  const _MatchHistoryView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final profileState = context.read<ProfileBloc>().state;
    int? currentUserId;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface, size: 20),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'HISTORIAL DE PARTIDOS',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          if (state is MatchesLoading) {
            return const MatchHistorySkeleton();
          } else if (state is MatchesError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 48, color: cs.error.withValues(alpha: 0.5)),
                    const SizedBox(height: 16),
                    Text(state.message, textAlign: TextAlign.center, style: TextStyle(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            );
          } else if (state is MatchesLoaded) {
            if (state.matches.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_rounded, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'No tienes partidos finalizados aún.',
                      style: TextStyle(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: MatchHistoryList(
                matches: state.matches,
                perspectiveUserId: currentUserId,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
