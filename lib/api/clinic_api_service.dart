// api/clinic_api_service.dart

import 'package:dio/dio.dart';
import '../models/clinic_model.dart';
import 'api_client.dart';

class ClinicApiService {
  final Dio _dio = ApiClient().dio;

  Future<List<Clinic>> fetchClinics() async {
    try {
      final response = await _dio.get('clinics');
      List data = response.data;
      return data.map((e) => Clinic.fromJson(e)).toList();
    } catch (e) {
      rethrow; // 可日後加上自定義錯誤處理
    }
  }
}
