import 'package:FaceApp/services/config/LoggingInterceptor.dart';
import 'package:FaceApp/services/core/core.dart';
import 'package:FaceApp/services/keys/prod_keys.dart';
import 'package:FaceApp/utils/widgets/global_dialogs.dart';
import 'package:connectivity/connectivity.dart';
import 'package:dio/dio.dart';

Dio get dioClient {
  Dio _dio;
  if (_dio == null) {
    BaseOptions options = new BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 5000,
      baseUrl: Core().server,
      headers: {
        "app_id": ProdKeys.keys["app_id"],
        "app_key": ProdKeys.keys["app_key"],
        "Content-Type": "application/json",
      },
    );
    _dio = new Dio(options);
    _dio.interceptors.add(LoggingInterceptors());
  }
  return _dio;
}
