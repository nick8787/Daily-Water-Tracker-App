import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/services/credentials_loader.dart';
import 'package:daily_water_tracker/common/services/logger.dart';

part 'connectivity_state.dart';

const _testConnectionHost = 'https://www.google.com';
const networkLookUpTimeout = Duration(seconds: 20);

class ConnectivityCubit extends Cubit<ConnectivityState> {
  final Credentials credentials;

  late final StreamSubscription<void> _connectionSubscription;

  ConnectivityCubit({required this.credentials})
    : super(const ConnectivityState()) {
    _initializeConnectionSubscription();
  }

  void _initializeConnectionSubscription() {
    _connectionSubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.contains(ConnectivityResult.none)) {
        emit(state.copyWith(status: ConnectivityStatus.noConnection));
      } else {
        _checkConnection();
      }
    });
  }

  Future<void> _checkConnection() async {
    try {
      emit(state.copyWith(status: ConnectivityStatus.loading));
      final hasConnection = await _checkConnectionByHost(
        credentials.apiBaseUrl,
      );
      emit(
        state.copyWith(
          status: hasConnection
              ? ConnectivityStatus.hasConnection
              : ConnectivityStatus.noConnection,
        ),
      );
    } catch (e, st) {
      logCaughtError('ConnectivityCubit._init', e, st);
      emit(state.copyWith(status: ConnectivityStatus.noConnection));
    }
  }

  Future<bool> _checkConnectionByHost(String appUrlDomain) async {
    bool hasInternet = false;

    /// Check by test host.
    try {
      final lookupResultByTestHost = await InternetAddress.lookup(
        Uri.parse(_testConnectionHost).host,
      ).timeout(networkLookUpTimeout);
      hasInternet =
          lookupResultByTestHost.isNotEmpty &&
          lookupResultByTestHost[0].rawAddress.isNotEmpty;
    } catch (e, st) {
      logCaughtWarning('ConnectivityCubit: connectivity check', e, st);
      hasInternet = false;
    }

    if (hasInternet) {
      return hasInternet;
    }

    /// Check by project host.
    try {
      final lookupResultProjectHost = await InternetAddress.lookup(
        Uri.parse(appUrlDomain).host,
      ).timeout(networkLookUpTimeout);

      hasInternet =
          lookupResultProjectHost.isNotEmpty &&
          lookupResultProjectHost[0].rawAddress.isNotEmpty;
    } catch (e, st) {
      logCaughtWarning('ConnectivityCubit: project host lookup', e, st);
      hasInternet = false;
    }

    return hasInternet;
  }

  @override
  Future<void> close() {
    _connectionSubscription.cancel();
    return super.close();
  }
}
