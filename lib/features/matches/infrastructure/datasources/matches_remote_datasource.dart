import '../../../../core/network/network_robot.dart';
import '../models/match_model.dart';

abstract class MatchesRemoteDataSource {
  Future<List<MatchModel>> getMatches({
    int? sportId, 
    String? status,
    int? regionId,
    int? canchaId,
    DateTime? date,
    bool? mine,
    int? teamId,
  });
  Future<MatchModel> createMatch(MatchModel match);
  Future<MatchModel> getMatchDetails(int id);
  Future<MatchModel> acceptEncounter(int matchId, int teamId);
  Future<MatchModel> proposeTerms(int matchId, DateTime fecha, double costo);
  Future<MatchModel> configureMatch(int matchId, DateTime fecha, double costo, String banco, String cedula, String telefono);
  Future<MatchModel> markTeamReady(int matchId);
  Future<void> registerResult(int matchId, int golesA, int golesB);
  Future<void> joinMatch(int matchId, {int? teamId});
  Future<List<MatchPlayerModel>> getMatchPlayers(int matchId);
  Future<void> cancelMatch(int matchId);
  Future<MatchModel> updateMatch(MatchModel match);
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
    bool? mine,
    int? teamId,
  }) async {
    final response = await network.get('/matches/', queryParameters: {
      'sport_id': sportId,
      'status': status,
      'region_id': regionId,
      'cancha_id': canchaId,
      'fecha': date?.toIso8601String(),
      'mine': mine,
      'team_id': teamId,
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
  Future<MatchModel> configureMatch(int matchId, DateTime fecha, double costo, String banco, String cedula, String telefono) async {
    final response = await network.put('/matches/$matchId/configure', data: {
      'fecha_acordada': fecha.toIso8601String(),
      'costo_total_partida': costo,
      'banco_receptor': banco,
      'cedula_receptor': cedula,
      'telefono_receptor': telefono,
    });
    return MatchModel.fromJson(response.data);
  }

  @override
  Future<MatchModel> markTeamReady(int matchId) async {
    final response = await network.post('/matches/$matchId/ready');
    return MatchModel.fromJson(response.data);
  }

  @override
  Future<void> registerResult(int matchId, int golesA, int golesB) async {
    await network.post('/matches/$matchId/results', data: {
      'goles_a': golesA,
      'goles_b': golesB,
    });
  }

  @override
  Future<void> joinMatch(int matchId, {int? teamId}) async {
    await network.post('/matches/$matchId/join', queryParameters: {
      'team_id': teamId,
    }..removeWhere((_, v) => v == null));
  }

  @override
  Future<List<MatchPlayerModel>> getMatchPlayers(int matchId) async {
    final response = await network.get('/matches/$matchId/players');
    return (response.data as List).map((e) => MatchPlayerModel.fromJson(e)).toList();
  }

  @override
  Future<void> cancelMatch(int matchId) async {
    await network.delete('/matches/$matchId');
  }

  @override
  Future<MatchModel> updateMatch(MatchModel match) async {
    final response = await network.put('/matches/${match.id}', data: match.toJson());
    return MatchModel.fromJson(response.data);
  }
}
