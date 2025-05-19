// lib/views/map/map_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

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

  /// 自訂大頭針 BitmapDescriptor（初始化後會指派）
  BitmapDescriptor? _customMarker;

  /// 對外提供標記清單（不可修改）
  List<Marker> get clinicMarkers => List.unmodifiable(_clinicMarkers);

  /// 是否正在載入（用於顯示遮罩）
  bool isLoading = false;

  /// 初始化流程：抓定位 → 載入大頭針圖示 → 載入診所資料
  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    await getCurrentLocation();
    await _loadCustomMarkerIcon();
    await loadClinics();

    isLoading = false;
    notifyListeners();
  }

  /// 取得使用者當前定位座標
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
      debugPrint("❌ 取得定位失敗：$e");
    }
  }

  /// 載入並縮放自訂的大頭針圖片（圖片來源 assets/images/map_dot_dog.png）
  Future<void> _loadCustomMarkerIcon() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/map_dot_dog.png');

      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 80,
        targetHeight: 80,
      );

      final frame = await codec.getNextFrame();
      final imageData = await frame.image.toByteData(format: ui.ImageByteFormat.png);

      final Uint8List resizedBytes = imageData!.buffer.asUint8List();
      _customMarker = BitmapDescriptor.fromBytes(resizedBytes);
    } catch (e) {
      debugPrint("❌ 載入自訂大頭針圖片失敗：$e");
    }
  }

  /// 載入診所並建立 marker 標記（使用自訂 icon）
  Future<void> loadClinics() async {
    try {
      final List<Clinic> clinics = await _repository.fetchClinics();

      _clinicMarkers.clear();

      for (final clinic in clinics) {
        final lat = clinic.lat;
        final lng = clinic.lng;

        if (lat != null && lng != null) {
          final marker = Marker(
            markerId: MarkerId(clinic.name),
            position: LatLng(lat, lng),
            icon: _customMarker ?? BitmapDescriptor.defaultMarker,
            infoWindow: InfoWindow.noText,
            onTap: () => selectClinic(clinic),
          );
          _clinicMarkers.add(marker);
        }
      }
    } catch (e) {
      debugPrint("❌ 載入診所資料失敗：$e");
    }
  }

  /// 設定被點選的診所資料（用於下方展示卡片）
  void selectClinic(Clinic clinic) {
    _selectedClinic = clinic;
    notifyListeners();
  }

  /// 清除被選中的診所（用於關閉 info 卡片）
  void clearSelectedClinic() {
    _selectedClinic = null;
    notifyListeners();
  }
}