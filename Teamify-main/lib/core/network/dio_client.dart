import 'package:dio/dio.dart';
import 'package:teamify/core/constants/app_constants.dart';
import '../storage/token_storage.dart';
import '../di/service_locator.dart';

class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          "Content-Type": "application/json",
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token =
              await sl<TokenStorage>().getToken();

          if (token != null) {
            options.headers["Authorization"] =
                "Bearer $token";
          }

          return handler.next(options);
        },
      ),
    );
  }
}
