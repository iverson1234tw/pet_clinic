// lib/views/map/map_page.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_clinic_app/views/map/map_view_model.dart';
import 'package:provider/provider.dart';

import 'widgets/clinic_info_card.dart'; // 匯入你寫好的卡片元件

/// 地圖主畫面：整合 Google Map 並由 ViewModel 提供診所座標資料與定位邏輯
class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewModel>(
      create: (_) => MapViewModel()..initialize(),
      child: Consumer<MapViewModel>(
        builder: (context, vm, _) {
          final currentLocation = vm.currentLocation;

          if (currentLocation == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return Stack(
            children: [
              GoogleMap(
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
                onTap: (_) => vm.clearSelectedClinic(), // 點地圖其他處可清除選擇
              ),

              // 底部卡片區塊
              Align(
                alignment: Alignment.bottomCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: vm.selectedClinic == null
                      ? const SizedBox.shrink()
                      : ClinicInfoCard(
                          key: ValueKey(vm.selectedClinic!.name),
                          name: vm.selectedClinic!.name,
                          address: vm.selectedClinic!.address,
                          phone: vm.selectedClinic!.phone,
                          onNavigate: () {
                            // TODO: 開啟導航功能（後續補上）
                          },
                          onCall: () {
                            // TODO: 撥打電話功能（後續補上）
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
