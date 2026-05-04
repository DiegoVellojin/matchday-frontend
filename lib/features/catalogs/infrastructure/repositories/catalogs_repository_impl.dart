import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../teams/domain/entities/sport_entity.dart';
import '../../domain/entities/region_entity.dart';
import '../../domain/entities/cancha_entity.dart';
import '../../domain/repositories/i_catalogs_repository.dart';
import '../datasources/catalogs_remote_datasource.dart';
import '../models/cancha_model.dart';

class CatalogsRepositoryImpl implements ICatalogsRepository {
  final CatalogsRemoteDataSource remoteDataSource;

  CatalogsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SportEntity>>> getSports() async {
    try {
      final result = await remoteDataSource.getSports();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RegionEntity>>> getRegions() async {
    try {
      final result = await remoteDataSource.getRegions();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CanchaEntity>>> getCanchas({int? regionId}) async {
    try {
      final result = await remoteDataSource.getCanchas(regionId: regionId);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CanchaEntity>> createCancha(CanchaEntity cancha) async {
    try {
      final CanchaModel model = CanchaModel(
        id: cancha.id,
        name: cancha.name,
        address: cancha.address,
        regionId: cancha.regionId,
        latitude: cancha.latitude,
        longitude: cancha.longitude,
      );
      final result = await remoteDataSource.createCancha(model);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
