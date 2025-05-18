// lib/views/map/map_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../models/clinic_model.dart';
import '../../repository/clinic_repository.dart';

/// ViewModel 負責處理地圖顯示的診所資料與標記邏輯
class MapViewModel extends ChangeNotifier {
  final ClinicRepository _repository = ClinicRepository();

  late GoogleMapController mapController;

  final List<Marker> _clinicMarkers = [];

  /// 使用者目前位置
  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  /// 對外提供標記清單
  List<Marker> get clinicMarkers => List.unmodifiable(_clinicMarkers);

  /// 初始化流程：先取得定位，再載入診所
  Future<void> initialize() async {
    await getCurrentLocation();
    await loadClinics();
  }

  /// 取得使用者當前位置
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

  /// 載入所有診所並轉換為地圖標記
  Future<void> loadClinics() async {
    try {
      final List<Clinic> clinics = await _repository.fetchClinics();

      _clinicMarkers.clear();

      for (final clinic in clinics) {
        final lat = clinic.lat;
        final lng = clinic.lng;

        // ignore: unnecessary_null_comparison
        if (lat != null && lng != null) {
          final marker = Marker(
            markerId: MarkerId(clinic.name),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: clinic.name,
              snippet: clinic.address,
            ),
          );
          _clinicMarkers.add(marker);
        }
      }

      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print("載入診所資料失敗：$e");
      }
    }
  }
}
