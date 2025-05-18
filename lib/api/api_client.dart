// api/api_client.dart

import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: 'https://pet-clinic-backend-1cb56118a66b.herokuapp.com/api/',
            connectTimeout: Duration(seconds: 10),
            receiveTimeout: Duration(seconds: 10),
          ),
        );

  Dio get dio => _dio;
}
