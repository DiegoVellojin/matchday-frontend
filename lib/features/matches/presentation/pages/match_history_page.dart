import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/matches_bloc.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';
import '../widgets/match_history_list.dart';

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
    final colorScheme = theme.colorScheme;
    final profileState = context.read<ProfileBloc>().state;
    int? currentUserId;
    if (profileState is ProfileLoaded) {
      currentUserId = profileState.profile.id;
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Historial de Partidos',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          if (state is MatchesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is MatchesError) {
            return Center(child: Text(state.message));
          } else if (state is MatchesLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
