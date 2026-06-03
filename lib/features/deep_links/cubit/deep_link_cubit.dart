import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/features/deep_links/cubit/deep_link_state.dart';
import 'package:daily_water_tracker/features/deep_links/models/water_link_purpose.dart';
import 'package:daily_water_tracker/features/deep_links/services/water_deep_link_service.dart';

class DeepLinkCubit extends Cubit<DeepLinkState> {
  DeepLinkCubit({
    required WaterDeepLinkService service,
  }) : _service = service,
       super(DeepLinkState.initial()) {
    unawaited(initialize());
  }

  final WaterDeepLinkService _service;
  StreamSubscription<Uri>? _sub;

  Future<void> initialize() async {
    try {
      final initial = await _service.getInitialUri();
      await _sub?.cancel();
      _sub = _service.uriStream.listen(_handleUri);

      if (initial != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _handleUri(initial);
        });
      }
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'DeepLinkCubit.initialize failed',
      );
    }
  }

  void resetPurpose() {
    if (state.purpose is WaterLinkPurposeNone) return;
    emit(state.copyWith(purpose: const WaterLinkPurposeNone()));
  }

  void _handleUri(Uri uri) {
    final normalized = uri.toString();
    if (normalized == state.lastHandledUri) return;

    final purpose = _parsePurpose(uri);
    emit(state.copyWith(purpose: purpose, lastHandledUri: normalized));
  }

  WaterLinkPurpose _parsePurpose(Uri uri) {
    if (uri.path != '/share') return const WaterLinkPurposeNone();

    final mlStr = uri.queryParameters['ml'];
    final ml = int.tryParse((mlStr ?? '').trim());
    if (ml == null || ml <= 0) return const WaterLinkPurposeNone();

    return WaterLinkPurposeShareProgress(ml: ml);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
