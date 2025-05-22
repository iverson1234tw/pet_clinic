import 'package:shared_preferences/shared_preferences.dart';
import '../models/clinic_model.dart';

class FavoriteClinicManager {
  static final FavoriteClinicManager _instance = FavoriteClinicManager._internal();
  factory FavoriteClinicManager() => _instance;
  FavoriteClinicManager._internal();

  static const String _prefsKey = 'favorite_clinics';
  final Set<String> _favoriteKeys = {};

  bool _initialized = false;

  /// ✅ 初始化：從 SharedPreferences 載入資料
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? [];
    _favoriteKeys.addAll(list);
  }

  /// ✅ 判斷診所是否已收藏
  bool isFavorited(Clinic clinic) {
    return _favoriteKeys.contains(_generateKey(clinic));
  }

  Future<void> toggleFavorite(Clinic clinic) async {
    await toggle(clinic);
  }

  /// ✅ 加入收藏
  Future<void> add(Clinic clinic) async {
    _favoriteKeys.add(_generateKey(clinic));
    await _save();
  }

  /// ✅ 取消收藏
  Future<void> remove(Clinic clinic) async {
    _favoriteKeys.remove(_generateKey(clinic));
    await _save();
  }

  /// ✅ 切換收藏狀態
  Future<void> toggle(Clinic clinic) async {
    final key = _generateKey(clinic);
    if (_favoriteKeys.contains(key)) {
      _favoriteKeys.remove(key);
    } else {
      _favoriteKeys.add(key);
    }
    await _save();
  }

  /// ✅ 取得全部收藏的唯一 key
  Set<String> get allKeys => _favoriteKeys;

  /// ✅ 寫入 SharedPreferences
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, _favoriteKeys.toList());
  }

  /// ✅ 使用地區與地址產生唯一 key
  String _generateKey(Clinic clinic) {
    return '${clinic.name}_${clinic.address}';
  }
}
