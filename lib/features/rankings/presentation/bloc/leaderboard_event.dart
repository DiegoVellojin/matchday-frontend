import 'package:equatable/equatable.dart';

abstract class LeaderboardEvent extends Equatable {
  const LeaderboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadLeaderboardEvent extends LeaderboardEvent {
  final int? sportId;
  final String period;

  const LoadLeaderboardEvent({
    this.sportId,
    this.period = 'all',
  });

  @override
  List<Object?> get props => [sportId, period];
}
