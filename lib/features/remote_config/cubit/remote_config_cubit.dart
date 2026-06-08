import 'dart:async';

import 'package:daily_water_tracker/features/remote_config/cubit/remote_config_state.dart';
import 'package:daily_water_tracker/firebase/services/remote_config_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RemoteConfigCubit extends Cubit<RemoteConfigState> {
  RemoteConfigCubit({
    required RemoteConfigService remoteConfig,
  }) : _remoteConfig = remoteConfig,
       super(RemoteConfigState.initial()) {
    unawaited(_initialize());
  }

  final RemoteConfigService _remoteConfig;
  StreamSubscription<ProgressIndicatorType>? _progressSub;
  StreamSubscription<dynamic>? _issuesSub;
  Timer? _periodicRefresh;

  static const Duration _refreshInterval = Duration(minutes: 5);

  Future<void> _initialize() async {
    await _remoteConfig.initialize();

    _progressSub = _remoteConfig.progressIndicatorTypeStream.listen(
      (type) => emit(state.copyWith(progressIndicatorType: type)),
    );

    _issuesSub = _remoteConfig.issueDisclaimersStream.listen(
      (items) => emit(state.copyWith(issueDisclaimers: items)),
    );

    unawaited(_remoteConfig.refresh());

    _periodicRefresh = Timer.periodic(_refreshInterval, (_) {
      unawaited(_remoteConfig.refresh());
    });
  }

  @override
  Future<void> close() async {
    _periodicRefresh?.cancel();
    await _progressSub?.cancel();
    await _issuesSub?.cancel();
    return super.close();
  }
}
