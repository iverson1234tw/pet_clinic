// lib/views/clinic/clinic_list_view_model.dart

import 'package:flutter/material.dart';
import 'package:pet_clinic_app/models/clinic_model.dart';
import 'package:pet_clinic_app/repository/clinic_repository.dart';
import 'package:url_launcher/url_launcher.dart';

/// ViewModel 負責處理清單頁診所資料、搜尋邏輯與撥號/導航行為
class ClinicListViewModel extends ChangeNotifier {
  final ClinicRepository _repository = ClinicRepository();

  List<Clinic> _allClinics = [];
  List<Clinic> _filteredClinics = [];
  List<Clinic> get filteredClinics => _filteredClinics;

  bool isLoading = false;

  Future<void> initialize() async {
    isLoading = true;
    notifyListeners();

    try {
      _allClinics = await _repository.fetchClinics();
      _filteredClinics = _allClinics;
    } catch (e) {
      debugPrint("❌ 診所資料載入失敗：$e");
    }

    isLoading = false;
    notifyListeners();
  }

  /// 關鍵字搜尋：名稱或地址模糊比對
  void search(String keyword) {
    final query = keyword.trim();
    if (query.isEmpty) {
      _filteredClinics = _allClinics;
    } else {
      _filteredClinics = _allClinics.where((clinic) {
        return clinic.name.contains(query) || clinic.address.contains(query);
      }).toList();
    }
    notifyListeners();
  }

  /// ✅ 撥打電話
  Future<void> callClinic(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      debugPrint('❌ 無法撥打電話');
    }
  }

  /// ✅ 導航至診所（開啟 Google Maps）
  Future<void> navigateToClinic(Clinic clinic) async {
    final uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${clinic.lat},${clinic.lng}&travelmode=driving');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('❌ 無法開啟 Google Maps');
    }
  }
}
