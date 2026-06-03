part of '../common/di/injector_module.dart';

class _DioBootstrapper {
  Future<Dio> setupDio({required Credentials credentials}) async {
    final dio = Dio(BaseOptions(baseUrl: credentials.apiBaseUrl));
    dio.interceptors.addAll([
      RetryOnConnectionChangeInterceptor(
        requestRetrier: DioConnectivityRequestRetrier(
          dio: dio,
          connectivity: Connectivity(),
        ),
      ),
      RefreshTokenInterceptor(requestRetrier: DioTokenRequestRetrier(dio)),
    ]);

    return dio;
  }
}
