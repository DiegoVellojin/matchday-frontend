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
  static MatchRole resolve(MatchEntity match, int currentUserId) {
    // 1. Verificamos si es el Capitán A (Organizador)
    if (match.idUsuarioOrg == currentUserId) {
      return MatchRole.captainA;
    }

    // 2. Verificamos si es el Capitán B
    // Para esto, validamos si idCapitanB coincide con el usuario actual
    if (match.idCapitanB == currentUserId) {
      return MatchRole.captainB;
    }

    // 3. Verificamos si pertenece a los equipos pero no es capitán
    // Esto se asume a través de un proveedor de estado que verifica si el
    // currentUserId pertenece al equipoA o equipoB de la base de datos local
    // de roles. Sin embargo, si tenemos match.idEquipoA y el usuario está ahí,
    // debemos identificarlo. Como MatchEntity no trae la lista completa de
    // jugadores, esta validación debe completarse al instanciar la UI o al obtener players.
    // Por diseño actual: external se usa por defecto hasta que la UI o un cubit extraiga 
    // su equipo exacto (por ej. si está en matchPlayers y matchPlayer.idEquipo == match.idEquipoA)
    // Pero lo dejaremos genérico para que las capas de UI puedan pasar el flag
    // `isPlayerTeamA` o `isPlayerTeamB` basado en los jugadores obtenidos del backend.
    
    // Si queremos ser puristas en el modelo:
    // Retornamos external, y la vista que carga a los jugadores validará 
    // "si MatchRole == external && _soyMiembro(equipoA) => playerTeamA"
    return MatchRole.external;
  }
}
