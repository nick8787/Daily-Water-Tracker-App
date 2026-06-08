import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:dio/dio.dart';

import '../../common/services/secure_cache.dart';
import 'dio_token_request_retrier.dart';

const timeOut = 10000;

class RefreshTokenInterceptor extends Interceptor with SecureStorageMixin {
  final DioTokenRequestRetrier requestRetrier;

  RefreshTokenInterceptor({required this.requestRetrier});

  bool _isRefreshing = false;

  final _requestsNeedRetry = <({RequestOptions options, ErrorInterceptorHandler handler})>[];

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers['authorization'] = 'Bearer:${await readAuthToken()}';
    return handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response != null && await _shouldRefreshToken(err)) {
      if (!_isRefreshing) {
        _isRefreshing = true;

        _requestsNeedRetry.add((options: response.requestOptions, handler: handler));

        if (await requestRetrier.handleTokensChange()) {
          for (final requestNeedRetry in _requestsNeedRetry) {
            if (requestNeedRetry.options.data is FormData) {
              await retryFormDataRequest(requestNeedRetry.options, requestNeedRetry.handler);
            } else {
              try {
                requestNeedRetry.handler.resolve(await requestRetrier.retryRequest(requestNeedRetry.options));
              } on DioException catch (e, st) {
                logCaughtError('RefreshTokenInterceptor: retry after refresh', e, st);
                handler.reject(e);
              }
            }
          }

          _requestsNeedRetry.clear();
          _isRefreshing = false;
        } else {
          _isRefreshing = false;
          _requestsNeedRetry.clear();
          await deleteTokens();

          ///Insert your own specific DioException here(instead of "e") to be able to handle "session expired" in UI
          handler.next(err);
        }
      } else {
        _requestsNeedRetry.add((options: response.requestOptions, handler: handler));
      }
    } else {
      handler.next(err);
    }
  }

  Future<bool> _shouldRefreshToken(DioException err) async {
    return err.response?.statusCode == 401 &&
        await isStayLogged() &&
        !err.response!.requestOptions.path.contains(
          refreshTokenPath,
        );
  }

  ///This method is used for retry requests that contain files (eg photos)
  Future<void> retryFormDataRequest(RequestOptions requestOptions, ErrorInterceptorHandler handler) async {
    final formData = FormData();
    formData.fields.addAll(requestOptions.data.fields);
    for (final MapEntry<dynamic, dynamic> mapFile in requestOptions.data.files) {
      formData.files.add(
        MapEntry(
          mapFile.key,
          MultipartFile.fromFileSync(requestOptions.headers['path'], filename: mapFile.value.filename),
        ),
      );
    }
    final options = RequestOptions(
      data: formData,
      method: requestOptions.method,
      sendTimeout: const Duration(milliseconds: timeOut),
      receiveTimeout: const Duration(milliseconds: timeOut),
      extra: requestOptions.extra,
      headers: requestOptions.headers,
      path: requestOptions.path,
    );

    try {
      handler.resolve(await requestRetrier.retryRequest(options));
    } on DioException catch (e, st) {
      logCaughtError('RefreshTokenInterceptor.retryFormDataRequest', e, st);
      return handler.reject(e);
    }
  }
}
