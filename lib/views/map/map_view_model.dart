// lib/views/map/map_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/clinic_model.dart';
import '../../repository/clinic_repository.dart';

/// ViewModel 負責處理地圖顯示的診所資料、標記與狀態邏輯
class MapViewModel extends ChangeNotifier {
  final ClinicRepository _repository = ClinicRepository();

  late GoogleMapController mapController;

  final List<Marker> _clinicMarkers = [];

  /// 使用者目前位置
  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  /// 被點選的大頭針診所
  Clinic? _selectedClinic;
  Clinic? get selectedClinic => _selectedClinic;

  /// 對外提供標記清單
  List<Marker> get clinicMarkers => List.unmodifiable(_clinicMarkers);

  /// 初始化：取得定位並載入診所資料
  Future<void> initialize() async {
    await getCurrentLocation();
    await loadClinics();
  }

  /// 取得使用者定位
  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _currentLocation = LatLng(position.latitude, position.longitude);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("❌ 取得定位失敗：$e");
      }
    }
  }

  /// 載入診所並建立大頭針
  Future<void> loadClinics() async {
    try {
      final List<Clinic> clinics = await _repository.fetchClinics();

      _clinicMarkers.clear();

      for (final clinic in clinics) {
        final lat = clinic.lat;
        final lng = clinic.lng;

        // 忽略無效座標
        if (lat != null && lng != null) {
          final marker = Marker(
            markerId: MarkerId(clinic.name),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow.noText, // 我們自製 info 卡片，不使用預設
            onTap: () {
              selectClinic(clinic);
            },
          );
          _clinicMarkers.add(marker);
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("❌ 載入診所資料失敗：$e");
      }
    }
  }

  /// 設定被選中的診所（點 marker 時）
  void selectClinic(Clinic clinic) {
    _selectedClinic = clinic;
    notifyListeners();
  }

  /// 清除被選中的診所（可用於點地圖其他區域）
  void clearSelectedClinic() {
    _selectedClinic = null;
    notifyListeners();
  }
}
