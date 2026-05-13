abstract class IFinanceRepository {
  Future<Map<String, dynamic>> getLatestRates();
}
