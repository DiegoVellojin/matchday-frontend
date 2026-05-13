import 'package:dio/dio.dart';
import '../../domain/repositories/i_finance_repository.dart';

class FinanceRepositoryImpl implements IFinanceRepository {
  final Dio _dio;

  FinanceRepositoryImpl(this._dio);

  @override
  Future<Map<String, dynamic>> getLatestRates() async {
    try {
      final response = await _dio.get('/api/v1/config/rates/latest');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Error al obtener las tasas de cambio');
    } catch (e) {
      rethrow;
    }
  }
}
