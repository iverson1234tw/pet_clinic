import '../api/clinic_api_service.dart';
import '../models/clinic_model.dart';

/// Singleton 診所資料管理者：只打一次 API，其餘皆走快取
class ClinicRepository {
  ClinicRepository._internal();
  static final ClinicRepository _instance = ClinicRepository._internal();
  factory ClinicRepository() => _instance;

  final ClinicApiService _apiService = ClinicApiService();

  List<Clinic> _cachedClinics = [];
  bool _isInitialized = false; // ✅ 是否已打過 API 載入過資料

  /// ✅ 提供快取資料（如果尚未初始化會回空陣列）
  List<Clinic> get cachedClinics => _cachedClinics;

  /// ✅ App 開啟時呼叫一次，載入診所資料並快取
  Future<List<Clinic>> fetchClinics() async {
    if (_isInitialized) return _cachedClinics;

    try {
      _cachedClinics = await _apiService.fetchClinics();
      _isInitialized = true;
      return _cachedClinics;
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ 強制重抓 API 並更新快取（例：主動刷新診所列表）
  Future<List<Clinic>> forceRefresh() async {
    try {
      _cachedClinics = await _apiService.fetchClinics();
      _isInitialized = true;
      return _cachedClinics;
    } catch (e) {
      rethrow;
    }
  }
}
