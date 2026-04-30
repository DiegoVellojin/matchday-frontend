import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/i_teams_discovery_repository.dart';

class CreateTeamUseCase {
  final ITeamsDiscoveryRepository repository;
  CreateTeamUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String name,
    required int sportId,
    required String? logoUrl,
    required String description,
    required bool isRecruiting,
    required int maxMembers,
    String? chatUrl,
  }) async {
    return await repository.createTeam(
      name: name,
      sportId: sportId,
      logoUrl: logoUrl,
      description: description,
      isRecruiting: isRecruiting,
      maxMembers: maxMembers,
      chatUrl: chatUrl,
    );
  }
}
