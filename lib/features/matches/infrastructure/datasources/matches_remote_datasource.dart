import '../../../../core/network/network_robot.dart';
import '../../../../core/error/api_error_handler.dart';
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
  Future<MatchModel> proposeTerms(int matchId, DateTime fecha, double costo, String moneda);
  Future<MatchModel> configureMatch(int matchId, DateTime fecha, double costo, String moneda, String banco, String cedula, String telefono);
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
    try {
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
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al obtener la lista de partidos');
    }
  }

  @override
  Future<MatchModel> createMatch(MatchModel match) async {
    try {
      final response = await network.post('/matches/', data: match.toJson());
      return MatchModel.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al crear el partido');
    }
  }

  @override
  Future<MatchModel> getMatchDetails(int id) async {
    try {
      final response = await network.get('/matches/$id');
      return MatchModel.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al obtener detalles del partido');
    }
  }

  @override
  Future<MatchModel> acceptEncounter(int matchId, int teamId) async {
    try {
      final response = await network.post('/matches/$matchId/accept/$teamId');
      return MatchModel.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al aceptar el encuentro');
    }
  }

  @override
  Future<MatchModel> proposeTerms(int matchId, DateTime fecha, double costo, String moneda) async {
    try {
      final response = await network.post('/matches/$matchId/propose-terms', data: {
        'fecha_acordada': fecha.toIso8601String(),
        'costo_total': costo,
        'moneda': moneda,
      });
      return MatchModel.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al proponer términos');
    }
  }

  @override
  Future<MatchModel> configureMatch(int matchId, DateTime fecha, double costo, String moneda, String banco, String cedula, String telefono) async {
    try {
      final response = await network.put('/matches/$matchId/configure', data: {
        'fecha_acordada': fecha.toIso8601String(),
        'costo_total_partida': costo,
        'moneda': moneda,
        'banco_receptor': banco,
        'cedula_receptor': cedula,
        'telefono_receptor': telefono,
      });
      return MatchModel.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al configurar el partido');
    }
  }

  @override
  Future<MatchModel> markTeamReady(int matchId) async {
    try {
      final response = await network.post('/matches/$matchId/ready');
      return MatchModel.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al marcar equipo como listo');
    }
  }

  @override
  Future<void> registerResult(int matchId, int golesA, int golesB) async {
    try {
      await network.post('/matches/$matchId/results', data: {
        'goles_a': golesA,
        'goles_b': golesB,
      });
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al registrar el resultado');
    }
  }

  @override
  Future<void> joinMatch(int matchId, {int? teamId}) async {
    try {
      await network.post('/matches/$matchId/join', queryParameters: {
        'team_id': teamId,
      }..removeWhere((_, v) => v == null));
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al unirse al partido');
    }
  }

  @override
  Future<List<MatchPlayerModel>> getMatchPlayers(int matchId) async {
    try {
      final response = await network.get('/matches/$matchId/players');
      return (response.data as List).map((e) => MatchPlayerModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al obtener jugadores del partido');
    }
  }

  @override
  Future<void> cancelMatch(int matchId) async {
    try {
      await network.delete('/matches/$matchId');
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al cancelar el partido');
    }
  }

  @override
  Future<MatchModel> updateMatch(MatchModel match) async {
    try {
      final response = await network.put('/matches/${match.id}', data: match.toJson());
      return MatchModel.fromJson(response.data);
    } catch (e) {
      throw ApiErrorHandler.handle(e, 'Error al actualizar el partido');
    }
  }
}
