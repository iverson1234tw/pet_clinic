import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'views/map/map_page.dart';
import 'views/clinic/clinic_list_page.dart';
import 'views/member/member_page.dart';
import 'views/map/map_view_model.dart';

void main() => runApp(const PetClinicApp());

class PetClinicApp extends StatelessWidget {
  const PetClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MapViewModel>(
      create: (_) => MapViewModel(), // ✅ 提供 ViewModel，整個 app 只建一次
      child: MaterialApp(
        title: 'Pet Clinic App',
        theme: ThemeData(
          primarySwatch: Colors.teal,
        ),
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

  final List<Widget> _pages = const [
    MapPage(),         // ✅ 改為 const，可保留狀態
    ClinicListPage(),
    MemberPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? '附近的寵物醫院'
              : _selectedIndex == 1
                  ? '寵物醫療清單'
                  : '會員中心',
        ),
        centerTitle: true,
      ),

      // ✅ 使用 IndexedStack 保留頁面狀態
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/map_tab_icon.png',
              width: 40,
              height: 40,
            ),
            activeIcon: Image.asset(
              'assets/images/map_tab_selected_icon.png',
              width: 46,
              height: 46,
            ),
            label: '地圖',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/list_tab_icon.png',
              width: 30,
              height: 30,
            ),
            activeIcon: Image.asset(
              'assets/images/list_tab_selected_icon.png',
              width: 36,
              height: 36,
            ),
            label: '清單',
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/images/member_tab_icon.png',
              width: 30,
              height: 30,
            ),
            activeIcon: Image.asset(
              'assets/images/member_tab_selected_icon.png',
              width: 36,
              height: 36,
            ),
            label: '會員',
          ),
        ],
      ),
    );
  }
}
