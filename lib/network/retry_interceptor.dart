import 'dart:io';

import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:dio/dio.dart';

import '../common/services/services.dart';
import 'dio_connectivity_request_retrier.dart';

class RetryOnConnectionChangeInterceptor extends Interceptor {
  final DioConnectivityRequestRetrier requestRetrier;

  RetryOnConnectionChangeInterceptor({
    required this.requestRetrier,
  });

  @override
  Future<dynamic> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      try {
        return requestRetrier.scheduleRequestRetry(err.requestOptions);
      } catch (e, st) {
        logCaughtError('RetryInterceptor', e, st);
        // Let any new error from the retrier pass through
        return e;
      }
    }
    // Let the error pass through if it's not the error we're looking for
    return err;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log.fine('onRequest: ${options.method}');
    return handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    log.fine('onResponse: ${response.data}');
    return handler.next(response);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.unknown && err.error != null && err.error is SocketException;
  }
}
