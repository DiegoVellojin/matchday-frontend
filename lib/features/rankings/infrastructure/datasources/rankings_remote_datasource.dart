import '../../../../core/network/network_robot.dart';
import '../../domain/entities/leaderboard_entry_entity.dart';

class RankingsRemoteDataSource {
  final NetworkRobot networkRobot;

  const RankingsRemoteDataSource(this.networkRobot);

  Future<List<LeaderboardEntryEntity>> getTeamLeaderboard({
    int? sportId,
    String period = 'all',
  }) async {
    try {
      final response = await networkRobot.get(
        '/rankings/team-leaderboard',
        queryParameters: {
          if (sportId != null) 'sport_id': sportId,
          'period': period,
        },
      );
      final List<dynamic> data = response.data;
      return data.map((json) => LeaderboardEntryEntity.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Error al obtener el ranking');
    }
  }
}
