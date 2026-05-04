import '../../../../core/network/network_robot.dart';
import '../models/sport_model.dart';
import '../models/region_model.dart';
import '../models/cancha_model.dart';

abstract class CatalogsRemoteDataSource {
  Future<List<SportModel>> getSports();
  Future<List<RegionModel>> getRegions();
  Future<List<CanchaModel>> getCanchas({int? regionId});
  Future<CanchaModel> createCancha(CanchaModel cancha);
}

class CatalogsRemoteDataSourceImpl implements CatalogsRemoteDataSource {
  final NetworkRobot network;

  CatalogsRemoteDataSourceImpl(this.network);

  @override
  Future<List<SportModel>> getSports() async {
    final response = await network.get('/catalogs/sports');
    return (response.data as List).map((e) => SportModel.fromJson(e)).toList();
  }

  @override
  Future<List<RegionModel>> getRegions() async {
    final response = await network.get('/catalogs/regions');
    return (response.data as List).map((e) => RegionModel.fromJson(e)).toList();
  }

  @override
  Future<List<CanchaModel>> getCanchas({int? regionId}) async {
    final response = await network.get('/catalogs/canchas', queryParameters: {
      'region_id': regionId,
    }..removeWhere((_, v) => v == null));
    return (response.data as List).map((e) => CanchaModel.fromJson(e)).toList();
  }

  @override
  Future<CanchaModel> createCancha(CanchaModel cancha) async {
    final response = await network.post('/catalogs/canchas', data: cancha.toJson());
    return CanchaModel.fromJson(response.data);
  }
}
