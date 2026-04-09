import 'package:dio/dio.dart';
import 'package:teamify/core/constants/app_constants.dart';
import 'package:teamify/core/storage/token_storage.dart';

class ApiClient {
  final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient(this.tokenStorage)
      : dio = Dio(
          BaseOptions(
            baseUrl: AppConstants.baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {"Content-Type": "application/json"},
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getToken();

          if (token != null) {
            options.headers["Authorization"] = "Bearer $token";
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Auto-refresh on 401
          if (error.response?.statusCode == 401) {
            final refreshToken = await tokenStorage.getRefreshToken();
            if (refreshToken != null) {
              try {
                final refreshDio = Dio(BaseOptions(
                  baseUrl: AppConstants.baseUrl,
                  headers: {"Content-Type": "application/json"},
                ));
                final resp = await refreshDio.post(
                  AppConstants.refreshPath,
                  options: Options(headers: {"Authorization": "Bearer $refreshToken"}),
                );
                final newAccessToken = resp.data['access_token'] as String;
                await tokenStorage.saveToken(newAccessToken);

                // Retry the original request with new token
                error.requestOptions.headers["Authorization"] = "Bearer $newAccessToken";
                final retryResponse = await dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              } catch (_) {
                await tokenStorage.clearAll();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Options? options,
  }) async {
    return await dio.post(path, data: data, options: options);
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return await dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}
