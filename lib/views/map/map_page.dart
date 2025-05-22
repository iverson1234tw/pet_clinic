import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pet_clinic_app/views/map/map_view_model.dart';
import 'package:provider/provider.dart';
import 'package:pet_clinic_app/models/clinic_model.dart';
import 'widgets/clinic_info_card.dart'; // 匯入你寫好的卡片元件
import 'package:url_launcher/url_launcher.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ 插頁廣告用
import 'package:pet_clinic_app/services/favorite_clinic_manager.dart'; // 儲存最愛

/// 地圖主畫面：整合 Google Map 並由 ViewModel 提供診所座標資料與定位邏輯
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  InterstitialAd? _interstitialAd; // ✅ 插頁廣告物件
  Clinic? _pendingClinic; // ✅ 預先記住使用者點擊的診所（廣告後才執行導航）

  @override
  void initState() {
    super.initState();
    _loadAd(); // ✅ 預先載入插頁廣告，避免點擊導航時還沒準備好
  }

  /// ✅ 插頁廣告載入邏輯，建議在 initState 呼叫
  void _loadAd() {
    InterstitialAd.load(
      adUnitId: bool.fromEnvironment('dart.vm.product')
          ? 'ca-app-pub-7071828845077001/3280447025' // TODO: 替換為你的正式插頁廣告 ID
          : 'ca-app-pub-3940256099942544/1033173712', // ✅ 測試用 ID，開發時請用這個避免違規
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) {
          debugPrint('❌ 插頁廣告載入失敗: $error');
          _interstitialAd = null;
        },
      ),
    );
  }

  /// ✅ 當使用者按下「導航」按鈕時，先顯示插頁廣告，廣告結束後才執行導航行為
  void _showAdThenNavigate(Clinic clinic) {
    if (_interstitialAd != null) {
      _pendingClinic = clinic; // 記下要導航的診所

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _launchGoogleMapsNavigation(_pendingClinic!); // 廣告關閉後執行導航
          _loadAd(); // 廣告只可用一次 → 載下一個
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _launchGoogleMapsNavigation(_pendingClinic!); // 如果廣告顯示失敗也直接導航
          _loadAd(); // 重載廣告
        },
      );

      _interstitialAd!.show(); // ✅ 顯示插頁廣告
      _interstitialAd = null;
    } else {
      _launchGoogleMapsNavigation(clinic); // ❗若廣告尚未載好，直接導航
    }
  }

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

              // ✅ 診所資訊卡片：點大頭針後從下方淡入
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
                            _showAdThenNavigate(vm.selectedClinic!); // ✅ 改為先顯示廣告再導航
                          },
                          onCall: () {
                            _launchPhoneCall(vm.selectedClinic!.phone);
                          },
                          // ✅ 新增：傳入是否已收藏
                          isFavorited: FavoriteClinicManager().isFavorited(vm.selectedClinic!),
                          // ✅ 新增：按下愛心時切換收藏狀態並重建畫面
                          onFavorite: () async {
                            await FavoriteClinicManager().toggle(vm.selectedClinic!);
                            setState(() {}); // 重新渲染愛心圖示
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

  /// ✅ 導航：使用 Google Maps 跳轉至目標診所
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

  /// ✅ 撥打電話：跳出原生撥號畫面
  void _launchPhoneCall(String phone) async {
    final tel = Uri.parse('tel:$phone');
    if (await canLaunchUrl(tel)) {
      await launchUrl(tel);
    } else {
      debugPrint('❌ 無法撥打電話');
    }
  }
}
