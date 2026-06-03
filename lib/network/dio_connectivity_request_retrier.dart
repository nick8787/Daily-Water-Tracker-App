import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

class DioConnectivityRequestRetrier {
  final Dio dio;
  final Connectivity connectivity;

  DioConnectivityRequestRetrier({
    required this.dio,
    required this.connectivity,
  });

  Future<Response<dynamic>> scheduleRequestRetry(RequestOptions requestOptions) {
    StreamSubscription<void>? streamSubscription;
    final responseCompleter = Completer<Response<dynamic>>();

    streamSubscription = connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> connectivityResult) {
        if (connectivityResult.contains(ConnectivityResult.none)) {
          streamSubscription?.cancel();
          // Complete the completer instead of returning
          responseCompleter.complete(
            dio.fetch(requestOptions),
          );
        }
      },
    );

    return responseCompleter.future;
  }
}
