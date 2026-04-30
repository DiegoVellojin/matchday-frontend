import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../teams_discovery/domain/entities/sport_entity.dart';
import '../../domain/entities/region_entity.dart';
import '../../domain/entities/cancha_entity.dart';

abstract class ICatalogsRepository {
  Future<Either<Failure, List<SportEntity>>> getSports();
  Future<Either<Failure, List<RegionEntity>>> getRegions();
  Future<Either<Failure, List<CanchaEntity>>> getCanchas({int? regionId});
}
