import 'package:flutter/material.dart';
import 'package:pet_clinic_app/models/clinic_model.dart';
import 'package:pet_clinic_app/views/clinic/widgets/clinic_list_item.dart';
import 'package:pet_clinic_app/services/favorite_clinic_manager.dart';
import 'package:pet_clinic_app/repository/clinic_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// 收藏頁面：展示使用者收藏的診所清單
class FavePage extends StatefulWidget {
  const FavePage({super.key});

  @override
  State<FavePage> createState() => FavePageState();
}

class FavePageState extends State<FavePage> {
  final _repository = ClinicRepository(); // ✅ 單例快取
  List<Clinic> _favoritedClinics = [];

  @override
  void initState() {
    super.initState();
    refresh(); // ✅ 初始載入
  }

  /// ✅ 外部可呼叫：刷新收藏清單
  void refresh() {
    final all = _repository.cachedClinics;
    final favKeys = FavoriteClinicManager().allKeys;

    setState(() {
      _favoritedClinics = all.where((clinic) {
        final key = '${clinic.name}_${clinic.address}';
        return favKeys.contains(key);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_favoritedClinics.isEmpty) {
      return const Center(child: Text('尚未收藏任何診所'));
    }

    return ListView.builder(
      itemCount: _favoritedClinics.length,
      itemBuilder: (context, index) {
        final clinic = _favoritedClinics[index];
        return ClinicListItem(
          clinic: clinic,
          onCall: () => _launchPhoneCall(clinic.phone),
          onNavigate: () => _launchGoogleMapsNavigation(clinic),
        );
      },
    );
  }

  void _launchPhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('❌ 無法撥打電話');
    }
  }

  void _launchGoogleMapsNavigation(Clinic clinic) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${clinic.lat},${clinic.lng}&travelmode=driving',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ 無法開啟導航');
    }
  }
}
