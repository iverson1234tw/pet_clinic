// lib/view/map/map_page.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_clinic_app/views/map/map_view_model.dart';
import 'package:provider/provider.dart';

/// 地圖主畫面：整合 Google Map 並由 ViewModel 提供診所座標資料與定位邏輯
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  // final CameraPosition _defaultPosition = const CameraPosition(
  //   target: LatLng(25.0330, 121.5654), // 台北 101 預設位置（若無權限）
  //   zoom: 13,
  // );

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewModel>(
      create: (_) => MapViewModel()..initialize(), // 初始化：抓定位 + 載診所資料
      child: Consumer<MapViewModel>(
        builder: (context, vm, _) {
          final currentLocation = vm.currentLocation;

          return currentLocation == null
              ? const Center(child: CircularProgressIndicator()) // 尚未取得定位顯示 loading
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentLocation,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapType: MapType.normal,
                  markers: vm.clinicMarkers.toSet(),
                  onMapCreated: (controller) {
                    vm.mapController = controller;
                  },
                );
        },
      ),
    );
  }
}
