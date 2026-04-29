import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../teams_discovery/domain/entities/team_entity.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

class ProfileRepositoryImpl implements IProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserProfileEntity>> getUserProfile() async {
    try {
      final profile = await remoteDataSource.getUserProfile();
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, List<TeamEntity>>> getMyTeams() async {
    try {
      final teams = await remoteDataSource.getMyTeams();
      return Right(teams);
    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  @override
  Future<Either<Failure, UserProfileEntity>> updateUserProfile({
    String? name,
    String? phone,
    String? photoUrl,
    String? password,
  }) async {
    try {
      final profile = await remoteDataSource.updateUserProfile(
        name: name,
        phone: phone,
        photoUrl: photoUrl,
        password: password,
      );
      return Right(profile);

    } catch (e) {
      return Left(ServerFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}

