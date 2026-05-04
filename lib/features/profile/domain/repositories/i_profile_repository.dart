import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../teams/domain/entities/team_entity.dart';
import '../entities/profile_entity.dart';

abstract class IProfileRepository {
  Future<Either<Failure, UserProfileEntity>> getUserProfile();
  Future<Either<Failure, List<TeamEntity>>> getMyTeams();
  Future<Either<Failure, UserProfileEntity>> updateUserProfile({
    String? name,
    String? phone,
    String? photoUrl,
    String? password,
  });
}


