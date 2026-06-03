import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';

import 'debug_state.dart';
import 'package:daily_water_tracker/common/services/logger.dart';

class DebugCubit extends Cubit<DebugState> {
  DebugCubit({required MessagingRepository messaging})
    : _messaging = messaging,
      super(const DebugState.initial());

  final MessagingRepository _messaging;

  Future<void> load() async {
    emit(state.copyWith(loadingToken: true));
    try {
      await _messaging.requestPermission().timeout(const Duration(seconds: 6));
      await _messaging.startTokenSync();
      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 6),
        onTimeout: () => null,
      );
      emit(
        state.copyWith(
          token: token,
          reminderSubscribed: _messaging.isReminderTopicSubscribed,
        ),
      );
    } catch (e, st) {
      logCaughtError('DebugCubit.load', e, st);
      emit(state.copyWith(token: null));
    } finally {
      emit(state.copyWith(loadingToken: false));
    }
  }

  Future<void> subscribeReminder() async {
    if (state.topicBusy) return;
    emit(state.copyWith(topicBusy: true));
    try {
      await _messaging.subscribeToTopic('reminder');
      emit(state.copyWith(reminderSubscribed: true));
    } finally {
      emit(state.copyWith(topicBusy: false));
    }
  }

  Future<void> unsubscribeReminder() async {
    if (state.topicBusy) return;
    emit(state.copyWith(topicBusy: true));
    try {
      await _messaging.unsubscribeFromTopic('reminder');
      emit(state.copyWith(reminderSubscribed: false));
    } finally {
      emit(state.copyWith(topicBusy: false));
    }
  }
}
