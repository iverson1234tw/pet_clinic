// lib/views/clinic/clinic_list_page.dart

import 'package:flutter/material.dart';
import 'package:pet_clinic_app/views/clinic/clinic_list_view_model.dart';
import 'package:pet_clinic_app/views/clinic/widgets/clinic_list_item.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pet_clinic_app/models/clinic_model.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart'; // ✅ 插頁廣告用

class ClinicListPage extends StatefulWidget {
  const ClinicListPage({super.key});

  @override
  State<ClinicListPage> createState() => _ClinicListPageState();
}

class _ClinicListPageState extends State<ClinicListPage> {
  InterstitialAd? _interstitialAd; // ✅ 插頁廣告實體
  Clinic? _pendingClinic; // ✅ 記錄點擊的診所，待廣告關閉後使用

  @override
  void initState() {
    super.initState();
    _loadAd(); // ✅ 預先載入插頁廣告
  }

  /// ✅ 插頁廣告載入邏輯
  void _loadAd() {
    InterstitialAd.load(
      adUnitId: bool.fromEnvironment('dart.vm.product')
          ? 'ca-app-pub-7071828845077001/3280447025' // TODO: 替換為你的正式插頁廣告 ID
          : 'ca-app-pub-3940256099942544/1033173712', // ✅ 測試 ID，開發期間使用
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

  /// ✅ 點擊導航時顯示插頁廣告 → 廣告結束後才執行導航
  void _showAdThenNavigate(Clinic clinic) {
    if (_interstitialAd != null) {
      _pendingClinic = clinic;

      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _launchGoogleMapsNavigation(_pendingClinic!); // 廣告關閉後執行導航
          _loadAd(); // 載下一個廣告
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _launchGoogleMapsNavigation(_pendingClinic!); // 廣告失敗也照常導航
          _loadAd(); // 載下一個廣告
        },
      );

      _interstitialAd!.show(); // ✅ 顯示插頁廣告
      _interstitialAd = null;
    } else {
      _launchGoogleMapsNavigation(clinic); // ❗廣告尚未載好 → 直接導航
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ClinicListViewModel>(
      create: (_) => ClinicListViewModel()..initialize(),
      child: Consumer<ClinicListViewModel>(
        builder: (context, vm, _) {
          return GestureDetector(
            // ✅ 點空白區自動收起鍵盤（提升 UX）
            onTap: () => FocusScope.of(context).unfocus(),
            child: Column(
              children: [
                // ✅ 搜尋框
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '搜尋診所名稱或地址',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: vm.search,
                  ),
                ),

                // ✅ 清單內容：載入中則顯示轉圈圈
                Expanded(
                  child: vm.isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.orange))
                      : ListView.builder(
                          itemCount: vm.filteredClinics.length,
                          itemBuilder: (context, index) {
                            final clinic = vm.filteredClinics[index];
                            return ClinicListItem(
                              clinic: clinic,
                              onCall: () => _launchPhoneCall(clinic.phone),
                              onNavigate: () => _showAdThenNavigate(clinic), // ✅ 改為先顯示插頁廣告
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ✅ 導航：使用 Google Maps 導向診所位置
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

  /// ✅ 撥打電話：跳轉原生撥號頁面
  void _launchPhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('❌ 無法撥打電話');
    }
  }
}
