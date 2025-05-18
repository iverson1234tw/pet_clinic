// repository/clinic_repository.dart

import '../api/clinic_api_service.dart';
import '../models/clinic_model.dart';

/// Repository 層負責封裝 API 的存取邏輯
/// 提供統一的方法給 ViewModel 呼叫
class ClinicRepository {
  final ClinicApiService _apiService = ClinicApiService();

  /// 取得所有診所資料
  Future<List<Clinic>> fetchClinics() async {
    try {
      return await _apiService.fetchClinics();
    } catch (e) {
      rethrow; // 可以考慮 log 或轉成自定義錯誤
    }
  }
}
