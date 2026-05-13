import '../entities/match_entity.dart';

/// Define los posibles roles que un usuario puede tener en un partido.
enum MatchRole {
  /// Es el organizador del partido y capitán del Equipo A.
  captainA,

  /// Es el capitán del Equipo B.
  captainB,

  /// Es un jugador alineado en el Equipo A (pero no es el capitán).
  playerTeamA,

  /// Es un jugador alineado en el Equipo B (pero no es el capitán).
  playerTeamB,

  /// Es un espectador externo o no está asignado a ningún equipo en este partido.
  external,
}

/// Utilitario encargado de calcular el rol de un usuario en un partido específico.
/// Aplica el patrón Strategy para aislar las reglas de negocio de permisos.
class MatchRoleResolver {
  /// Retorna el [MatchRole] que corresponde al [currentUserId] dentro del [match].
  static MatchRole resolve(
    MatchEntity match,
    int currentUserId, {
    bool isPlayerInA = false,
    bool isPlayerInB = false,
  }) {
    // 1. Verificamos si es el Capitán A (Organizador)
    if (match.idUsuarioOrg == currentUserId) {
      return MatchRole.captainA;
    }

    // 2. Verificamos si es el Capitán B
    if (match.idCapitanB == currentUserId) {
      return MatchRole.captainB;
    }

    // 3. Verificamos si es un jugador regular (según flags externos)
    if (isPlayerInA) {
      return MatchRole.playerTeamA;
    }
    if (isPlayerInB) {
      return MatchRole.playerTeamB;
    }

    return MatchRole.external;
  }
}
