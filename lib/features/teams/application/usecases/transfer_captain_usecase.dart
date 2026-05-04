import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_repository.dart';

/// Caso de uso para transferir la capitanía de un equipo a otro miembro.
class TransferCaptainUseCase {
  final ITeamsRepository repository;

  TransferCaptainUseCase(this.repository);

  /// Realiza el cambio de capitán en el equipo [teamId] asignando a [newCaptainId].
  Future<Either<Failure, void>> call({required int teamId, required int newCaptainId}) {
    return repository.transferCaptain(teamId: teamId, newCaptainId: newCaptainId);
  }
}
