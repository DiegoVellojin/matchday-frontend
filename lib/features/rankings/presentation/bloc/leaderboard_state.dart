import 'package:equatable/equatable.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';

abstract class LeaderboardState extends Equatable {
  const LeaderboardState();
  
  @override
  List<Object> get props => [];
}

class LeaderboardInitial extends LeaderboardState {}

class LeaderboardLoading extends LeaderboardState {}

class LeaderboardLoaded extends LeaderboardState {
  final List<LeaderboardEntryEntity> leaderboard;

  const LeaderboardLoaded(this.leaderboard);

  @override
  List<Object> get props => [leaderboard];
}

class LeaderboardError extends LeaderboardState {
  final String message;

  const LeaderboardError(this.message);

  @override
  List<Object> get props => [message];
}
