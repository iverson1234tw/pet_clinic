// lib/views/map/map_page.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_clinic_app/views/map/map_view_model.dart';
import 'package:provider/provider.dart';
import 'package:pet_clinic_app/models/clinic_model.dart';
import 'widgets/clinic_info_card.dart'; // 匯入你寫好的卡片元件
import 'package:url_launcher/url_launcher.dart';

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
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            );
          }

          return Stack(
            children: [
              // ✅ Google Map
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
                onTap: (_) => vm.clearSelectedClinic(),
              ),

              // ✅ 診所資訊卡片
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
                            _launchGoogleMapsNavigation(vm.selectedClinic!);
                          },
                          onCall: () {
                            _launchPhoneCall(vm.selectedClinic!.phone);
                          },
                        ),
                ),
              ),
                            // ✅ 載入遮罩：淡黑背景 + 橘色轉圈圈
              if (vm.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.2),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.orangeAccent,
                    ),
                  ),
                ),

            ],
          );
        },
      ),
    );
  }

  /// ✅ 導航
  void _launchGoogleMapsNavigation(Clinic clinic) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${clinic.lat},${clinic.lng}&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ 無法開啟 Google Maps');
    }
  }

  /// ✅ 撥打電話
  void _launchPhoneCall(String phone) async {
    final tel = Uri.parse('tel:$phone');
    if (await canLaunchUrl(tel)) {
      await launchUrl(tel);
    } else {
      debugPrint('❌ 無法撥打電話');
    }
  }
}
