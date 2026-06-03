import 'dart:async';

import 'package:dio/dio.dart';

import '../../common/services/secure_cache.dart';
import 'package:daily_water_tracker/common/services/logger.dart';

const headers = <String, String>{'Content-type': 'application/json'};
const String headerAccessToken = 'authorization';
//TODO(username): must be replaced with a real path.
const String refreshTokenPath = 'refreshTokenPath';

class DioTokenRequestRetrier with SecureStorageMixin {
  final Dio _dio;

  DioTokenRequestRetrier(this._dio);

  Future<Response<dynamic>> retryRequest(RequestOptions requestOptions) async {
    final responseCompleter = Completer<Response<dynamic>>();

    final options = Options(
      method: requestOptions.method,
      headers: await _setupHeaders(headers),
    );

    responseCompleter.complete(
      _dio.request<dynamic>(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        options: options,
      ),
    );

    return responseCompleter.future;
  }

  Future<Map<String, String>> _setupHeaders(Map<String, String>? newHeaders) async {
    final updatedHeaders = <String, String>{};

    updatedHeaders.addAll(headers);
    if (newHeaders != null) {
      updatedHeaders.addAll(newHeaders);
    }

    final authToken = await readAuthToken();
    if (authToken != null) {
      updatedHeaders.addAll({headerAccessToken: 'Bearer:$authToken'});
    }
    return updatedHeaders;
  }

  Future<bool> handleTokensChange() async {
    final refreshToken = await readRefreshToken();
    try {
      final response = await _dio.post<dynamic>(refreshTokenPath, queryParameters: {'token': refreshToken});
      if (response.statusCode == 200) {
        ///TODO(username): uncomment strings below with real tokens
        //writeAuthToken(response[authToken]);
        //writeRefreshToken(response[refreshToken]);
        return true;
      } else {
        return false;
      }
    } catch (e, st) {
      logCaughtError('DioTokenRequestRetrier', e, st);
      return false;
    }
  }
}
