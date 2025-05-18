import 'package:flutter/material.dart';
import 'views/map/map_page.dart';
import 'views/clinic/clinic_list_page.dart';
import 'views/member/member_page.dart';

void main() => runApp(const PetClinicApp());

class PetClinicApp extends StatelessWidget {
  const PetClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pet Clinic App',
      theme: ThemeData(
        primarySwatch: Colors.teal,
      ),
      home: const MainPage(),
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

  final List<Widget> _pages = [
    MapPage(),
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
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          // 地圖頁：使用自訂圖片
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
          // 清單頁：預設 Icon
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
          // 會員頁：預設 Icon
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
