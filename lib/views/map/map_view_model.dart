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

  /// 是否已初始化過（避免重複載入資料）
  bool _initialized = false;

  /// 使用者目前位置
  LatLng? _currentLocation;
  LatLng? get currentLocation => _currentLocation;

  /// 被點選的大頭針診所
  Clinic? _selectedClinic;
  Clinic? get selectedClinic => _selectedClinic;

  /// 是否正在載入（用於顯示遮罩）
  bool isLoading = false;

  /// 自訂大頭針 BitmapDescriptor（預設與選中）
  BitmapDescriptor? _customMarker;
  BitmapDescriptor? _customMarkerSelected;

  /// 當前被選中的診所名稱（用來切換 marker 圖）
  String? _selectedMarkerId;

  /// 診所資料快取（只載入一次）
  List<Clinic> _cachedClinics = [];

  /// Marker 清單：根據是否選中動態建立（不重建整個 list）
  List<Marker> get clinicMarkers {
    return _cachedClinics.map((clinic) {
      final isSelected = _selectedMarkerId == clinic.name;
      return Marker(
        markerId: MarkerId(clinic.name),
        position: LatLng(clinic.lat, clinic.lng),
        icon: isSelected
            ? (_customMarkerSelected ?? BitmapDescriptor.defaultMarker)
            : (_customMarker ?? BitmapDescriptor.defaultMarker),
        infoWindow: InfoWindow.noText,
        onTap: () => selectClinic(clinic),
      );
    }).toList();
  }

  /// 初始化流程：抓定位 → 載入圖示 → 載入診所（只執行一次）
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    isLoading = true;
    notifyListeners();

    await getCurrentLocation();
    await _loadCustomMarkerIcons();
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

  /// 載入兩張 marker 圖片（預設與選中用）
  Future<void> _loadCustomMarkerIcons() async {
    _customMarker = await _loadMarkerImage('assets/images/map_dot_dog.png');
    _customMarkerSelected = await _loadMarkerImage('assets/images/map_dot_dog_selected.png');
  }

  /// 將圖片轉成 BitmapDescriptor
  Future<BitmapDescriptor> _loadMarkerImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 80,
      targetHeight: 80,
    );
    final frame = await codec.getNextFrame();
    final imageData = await frame.image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(imageData!.buffer.asUint8List());
  }

  /// 載入診所資料（只跑一次，存快取）
  Future<void> loadClinics() async {
    try {
      _cachedClinics = await _repository.fetchClinics();
    } catch (e) {
      debugPrint("❌ 載入診所資料失敗：$e");
    }
  }

  /// 設定被點選的診所資料（更新選中狀態 + 通知 UI）
  void selectClinic(Clinic clinic) {
    _selectedClinic = clinic;
    _selectedMarkerId = clinic.name;
    notifyListeners(); // ✅ 不重建 marker，只更新狀態
  }

  /// 清除被選中的診所（用於關閉 info 卡片）
  void clearSelectedClinic() {
    _selectedClinic = null;
    _selectedMarkerId = null;
    notifyListeners(); // ✅ 回復所有 marker 樣式
  }
}
