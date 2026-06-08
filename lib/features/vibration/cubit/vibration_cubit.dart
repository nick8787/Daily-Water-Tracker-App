import 'package:daily_water_tracker/common/services/vibration_box.dart';
import 'package:daily_water_tracker/features/vibration/cubit/vibration_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vibration/vibration.dart';

class VibrationCubit extends Cubit<VibrationState> {
  VibrationCubit(this._box) : super(const VibrationState(enabled: true)) {
    _restore();
  }

  static const int lightTapDurationMs = 4;

  final Box<dynamic> _box;

  void _restore() {
    final stored = _box.get(VibrationBox.enabledKey);
    if (stored is bool) {
      emit(state.copyWith(enabled: stored));
    }
  }

  Future<void> setEnabled(bool enabled) async {
    if (state.enabled == enabled) return;
    emit(state.copyWith(enabled: enabled));
    await _box.put(VibrationBox.enabledKey, enabled);
  }

  Future<void> lightTap() async {
    if (!state.enabled) return;

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator != true) return;

      await Vibration.vibrate(duration: lightTapDurationMs);
    } catch (_) {
      // Best-effort haptic; ignore unsupported platforms or missing hardware.
    }
  }
}
