class DebugState {
  const DebugState({
    required this.token,
    required this.loadingToken,
    required this.topicBusy,
    required this.reminderSubscribed,
  });

  const DebugState.initial()
    : token = null,
      loadingToken = true,
      topicBusy = false,
      reminderSubscribed = false;

  final String? token;
  final bool loadingToken;
  final bool topicBusy;
  final bool reminderSubscribed;

  DebugState copyWith({
    String? token,
    bool? loadingToken,
    bool? topicBusy,
    bool? reminderSubscribed,
  }) {
    return DebugState(
      token: token ?? this.token,
      loadingToken: loadingToken ?? this.loadingToken,
      topicBusy: topicBusy ?? this.topicBusy,
      reminderSubscribed: reminderSubscribed ?? this.reminderSubscribed,
    );
  }
}
