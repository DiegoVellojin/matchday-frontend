import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_discovery_repository.dart';

/// Caso de uso encargado de actualizar la información de un equipo.
class UpdateTeamUseCase {
  final ITeamsDiscoveryRepository repository;

  UpdateTeamUseCase(this.repository);

  /// Ejecuta la actualización parcial de los datos del equipo.
  /// 
  /// [teamId] Identificador del equipo a modificar.
  /// [name] Nuevo nombre (opcional).
  /// [logoUrl] Nueva URL de logo o emoji (opcional).
  /// [description] Nueva descripción (opcional).
  /// [isRecruiting] Estado de reclutamiento (opcional).
  /// [maxMembers] Capacidad máxima de miembros (opcional).
  Future<Either<Failure, void>> call({
    required int teamId,
    String? name,
    String? logoUrl,
    String? description,
    bool? isRecruiting,
    int? maxMembers,
  }) {
    return repository.updateTeam(
      teamId: teamId,
      name: name,
      logoUrl: logoUrl,
      description: description,
      isRecruiting: isRecruiting,
      maxMembers: maxMembers,
    );
  }
}
