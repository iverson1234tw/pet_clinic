import '../api/clinic_api_service.dart';
import '../models/clinic_model.dart';

/// Repository 層負責封裝 API 的存取邏輯
/// 提供統一的方法給 ViewModel 呼叫
class ClinicRepository {
  final ClinicApiService _apiService = ClinicApiService();

  List<Clinic> _cachedClinics = []; // ✅ 加入快取清單

  /// 外部取得快取診所資料（只讀）
  List<Clinic> get cachedClinics => _cachedClinics;

  /// 取得所有診所資料
  Future<List<Clinic>> fetchClinics() async {
    try {
      _cachedClinics = await _apiService.fetchClinics(); // ✅ 儲存快取
      return _cachedClinics;
    } catch (e) {
      rethrow;
    }
  }
}
