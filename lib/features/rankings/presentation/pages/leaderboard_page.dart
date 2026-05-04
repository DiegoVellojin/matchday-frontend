import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/leaderboard_bloc.dart';
import '../bloc/leaderboard_event.dart';
import '../bloc/leaderboard_state.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Si el BLoC está provisto globalmente o inyectado vía un BlocProvider superior
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Clasificación General', style: TextStyle(color: AppColors.textMain)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocBuilder<LeaderboardBloc, LeaderboardState>(
        builder: (context, state) {
          if (state is LeaderboardInitial) {
            context.read<LeaderboardBloc>().add(LoadLeaderboardEvent());
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is LeaderboardLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          } else if (state is LeaderboardError) {
            return Center(child: Text(state.message, style: const TextStyle(color: AppColors.error)));
          } else if (state is LeaderboardLoaded) {
            if (state.leaderboard.isEmpty) {
              return const Center(
                child: Text(
                  'No hay equipos en la clasificación.',
                  style: TextStyle(color: AppColors.textMuted),
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<LeaderboardBloc>().add(LoadLeaderboardEvent());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.leaderboard.length,
                itemBuilder: (context, index) {
                  final team = state.leaderboard[index];
                  final isTop3 = team.posicion <= 3;
                  
                  return Card(
                    color: isTop3 ? AppColors.surface.withValues(alpha: 0.8) : AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isTop3 ? const BorderSide(color: AppColors.primary, width: 1) : BorderSide.none,
                    ),
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isTop3 ? AppColors.primary : AppColors.border,
                        child: Text(
                          '${team.posicion}',
                          style: TextStyle(
                            color: isTop3 ? Colors.black : AppColors.textMain,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(team.nombreEquipo, style: const TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        'Puntos: ${team.puntosTotales} | V: ${team.victorias} | E: ${team.empates} | D: ${team.derrotas}',
                        style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                      ),
                      trailing: team.urlLogoEquipo != null 
                          ? CircleAvatar(backgroundImage: NetworkImage(team.urlLogoEquipo!))
                          : const Icon(Icons.shield, color: AppColors.textMuted),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
