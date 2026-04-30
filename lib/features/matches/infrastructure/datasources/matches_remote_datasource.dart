import '../../../../core/network/network_robot.dart';
import '../models/match_model.dart';

abstract class MatchesRemoteDataSource {
  Future<List<MatchModel>> getMatches({
    int? sportId, 
    String? status,
    int? regionId,
    int? canchaId,
    DateTime? date,
  });
  Future<MatchModel> createMatch(MatchModel match);
  Future<MatchModel> getMatchDetails(int id);
  Future<MatchModel> acceptEncounter(int matchId, int teamId);
  Future<MatchModel> proposeTerms(int matchId, DateTime fecha, double costo);
  Future<void> joinMatch(int matchId, {int? teamId});
}

class MatchesRemoteDataSourceImpl implements MatchesRemoteDataSource {
  final NetworkRobot network;

  MatchesRemoteDataSourceImpl(this.network);

  @override
  Future<List<MatchModel>> getMatches({
    int? sportId, 
    String? status,
    int? regionId,
    int? canchaId,
    DateTime? date,
  }) async {
    final response = await network.get('/matches/', queryParameters: {
      'sport_id': sportId,
      'status': status,
      'region_id': regionId,
      'cancha_id': canchaId,
      'fecha': date?.toIso8601String(),
    }..removeWhere((_, v) => v == null));
    return (response.data as List).map((e) => MatchModel.fromJson(e)).toList();
  }

  @override
  Future<MatchModel> createMatch(MatchModel match) async {
    final response = await network.post('/matches/', data: match.toJson());
    return MatchModel.fromJson(response.data);
  }

  @override
  Future<MatchModel> getMatchDetails(int id) async {
    final response = await network.get('/matches/$id');
    return MatchModel.fromJson(response.data);
  }

  @override
  Future<MatchModel> acceptEncounter(int matchId, int teamId) async {
    final response = await network.post('/matches/$matchId/accept/$teamId');
    return MatchModel.fromJson(response.data);
  }

  @override
  Future<MatchModel> proposeTerms(int matchId, DateTime fecha, double costo) async {
    final response = await network.post('/matches/$matchId/propose-terms', data: {
      'fecha_acordada': fecha.toIso8601String(),
      'costo_total': costo,
    });
    return MatchModel.fromJson(response.data);
  }

  @override
  Future<void> joinMatch(int matchId, {int? teamId}) async {
    await network.post('/matches/$matchId/join', queryParameters: {
      'team_id': teamId,
    }..removeWhere((_, v) => v == null));
  }
}
