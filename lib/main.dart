import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';

import 'views/map/map_page.dart';
import 'views/clinic/clinic_list_page.dart';
import 'views/member/member_page.dart';
import 'views/map/map_view_model.dart';
import 'package:pet_clinic_app/services/favorite_clinic_manager.dart';
import 'package:pet_clinic_app/views/fave/fave_page.dart';
import 'package:pet_clinic_app/repository/clinic_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize(); // ✅ 廣告功能初始化
  await FavoriteClinicManager().initialize(); // ✅ 收藏功能初始化  
  await ClinicRepository().fetchClinics(); // ✅ 💥 加這一行：初始化診所清單，只做一次
  runApp(const PetClinicApp());
}

class PetClinicApp extends StatelessWidget {
  const PetClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewModel>(
      create: (_) => MapViewModel(),
      child: MaterialApp(
        title: 'Pet Clinic App',
        theme: ThemeData(primarySwatch: Colors.teal),
        home: const MainPage(),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  // ✅ 收藏頁 GlobalKey，用來呼叫 refresh()
  final GlobalKey<FavePageState> _favePageKey = GlobalKey<FavePageState>();

  // ✅ 保留頁面並可透過 key 呼叫內部狀態
  late final List<Widget> _pages = [
    const MapPage(),
    const ClinicListPage(),
    FavePage(key: _favePageKey),
  ];

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: bool.fromEnvironment('dart.vm.product')
          ? 'ca-app-pub-7071828845077001/4854442637'
          : getBannerAdUnitId(), // 🧪 測試 ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, error) {
          debugPrint('❌ 廣告載入失敗: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  String getBannerAdUnitId() {
    return 'ca-app-pub-3940256099942544/6300978111'; // 測試橫幅 ID
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // ✅ 每次切換到收藏頁就刷新
      if (index == 2) {
        _favePageKey.currentState?.refresh();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showBanner = _selectedIndex == 0 && _isBannerAdReady;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? '附近的寵物醫院'
              : _selectedIndex == 1
                  ? '寵物醫療清單'
                  : '毛孩健康收藏',
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (showBanner)
            Container(
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/map_tab_icon.png', width: 40, height: 40),
            activeIcon: Image.asset('assets/images/map_tab_selected_icon.png', width: 46, height: 46),
            label: '地圖',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/list_tab_icon.png', width: 30, height: 30),
            activeIcon: Image.asset('assets/images/list_tab_selected_icon.png', width: 36, height: 36),
            label: '清單',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/images/like_tab_icon.png', width: 40, height: 40),
            activeIcon: Image.asset('assets/images/like_tab_selected_icon.png', width: 36, height: 36),
            label: '收藏',
          ),
        ],
      ),
    );
  }
}