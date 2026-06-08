import 'dart:async';

import 'package:daily_water_tracker/features/vibration/cubit/vibration_cubit.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract final class VibrationFeedback {
  static Future<void> tap(BuildContext context) {
    return context.read<VibrationCubit>().lightTap();
  }

  static void run(BuildContext context, VoidCallback action) {
    unawaited(tap(context));
    action();
  }
}
