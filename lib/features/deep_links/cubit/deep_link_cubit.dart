import 'dart:async';

import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/features/deep_links/cubit/deep_link_state.dart';
import 'package:daily_water_tracker/features/deep_links/models/water_link_purpose.dart';
import 'package:daily_water_tracker/features/deep_links/services/auth_deep_link_parser.dart';
import 'package:daily_water_tracker/features/deep_links/services/water_deep_link_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeepLinkCubit extends Cubit<DeepLinkState> {
  DeepLinkCubit({
    required WaterDeepLinkService service,
  }) : _service = service,
       super(DeepLinkState.initial()) {
    unawaited(initialize());
  }

  final WaterDeepLinkService _service;
  StreamSubscription<Uri>? _sub;

  String? _debouncedUri;
  DateTime? _debouncedAt;
  static const _duplicateIntentWindow = Duration(milliseconds: 900);

  Future<void> initialize() async {
    try {
      final initial = await _service.getInitialUri();
      await _sub?.cancel();
      _sub = _service.uriStream.listen(_handleUri);

      if (initial != null) {
        _handleUri(initial);
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
    final passwordReset = parseAuthPasswordResetLink(uri);
    if (passwordReset != null) {
      _emitIfNotDuplicate(
        _normalizeUri(uri),
        state.copyWith(
          purpose: WaterLinkPurposePasswordReset(
            oobCode: passwordReset.oobCode,
          ),
          passwordResetDeliveryId: state.passwordResetDeliveryId + 1,
        ),
      );
      return;
    }

    final sharePurpose = _parseSharePurpose(uri);
    if (sharePurpose is! WaterLinkPurposeShareProgress) return;

    _emitIfNotDuplicate(
      _normalizeUri(uri),
      state.copyWith(
        purpose: sharePurpose,
        shareDeliveryId: state.shareDeliveryId + 1,
      ),
    );
  }

  void _emitIfNotDuplicate(String normalized, DeepLinkState next) {
    final now = DateTime.now();
    if (_debouncedUri == normalized &&
        _debouncedAt != null &&
        now.difference(_debouncedAt!) < _duplicateIntentWindow) {
      return;
    }

    _debouncedUri = normalized;
    _debouncedAt = now;
    emit(next);
  }

  WaterLinkPurpose _parseSharePurpose(Uri uri) {
    final path = _normalizedPath(uri.path);
    if (path != '/share') return const WaterLinkPurposeNone();

    final mlStr = uri.queryParameters['ml'];
    final ml = int.tryParse((mlStr ?? '').trim());
    if (ml == null || ml <= 0) return const WaterLinkPurposeNone();

    return WaterLinkPurposeShareProgress(ml: ml);
  }

  String _normalizeUri(Uri uri) {
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      path: _normalizedPath(uri.path),
      queryParameters: uri.queryParameters.isEmpty ? null : uri.queryParameters,
    ).toString();
  }

  String _normalizedPath(String path) {
    if (path.endsWith('/') && path.length > 1) {
      return path.substring(0, path.length - 1);
    }
    return path;
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
