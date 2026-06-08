import 'package:daily_water_tracker/firebase/models/hydration_log_entry.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

enum HistoryStatus { loading, ready, failed }

class HistoryDaySection extends Equatable {
  const HistoryDaySection({
    required this.calendarDay,
    required this.entries,
  });

  final DateTime calendarDay;
  final List<HydrationLogEntry> entries;

  double get totalEffectiveMl =>
      entries.fold(0.0, (sum, e) => sum + e.record.effectiveHydrationMl);

  @override
  List<Object?> get props => [calendarDay, entries];
}

class HistoryState extends Equatable {
  const HistoryState({
    this.entries = const <HydrationLogEntry>[],
    this.profile,
    this.status = HistoryStatus.loading,
    this.hasLogSnapshot = false,
    this.errorMessageKey,
  });

  final List<HydrationLogEntry> entries;
  final UserModel? profile;
  final HistoryStatus status;
  final bool hasLogSnapshot;
  final String? errorMessageKey;

  bool get isLoading => status == HistoryStatus.loading;

  bool get hasError => status == HistoryStatus.failed;

  bool get isEmpty => status == HistoryStatus.ready && entries.isEmpty;

  bool get isReady => status == HistoryStatus.ready && entries.isNotEmpty;

  int get dailyGoalMl => profile?.dailyGoalMl ?? 0;

  List<HistoryDaySection> get sections => _groupByCalendarDay(entries);

  String localizedErrorMessage() => (errorMessageKey ?? '').tr();

  HistoryState copyWith({
    List<HydrationLogEntry>? entries,
    UserModel? profile,
    HistoryStatus? status,
    bool? hasLogSnapshot,
    String? errorMessageKey,
    bool clearError = false,
  }) {
    return HistoryState(
      entries: entries ?? this.entries,
      profile: profile ?? this.profile,
      status: status ?? this.status,
      hasLogSnapshot: hasLogSnapshot ?? this.hasLogSnapshot,
      errorMessageKey:
          clearError ? null : (errorMessageKey ?? this.errorMessageKey),
    );
  }

  static List<HistoryDaySection> _groupByCalendarDay(
    List<HydrationLogEntry> flat,
  ) {
    final map = <DateTime, List<HydrationLogEntry>>{};
    for (final e in flat) {
      final d = DateTime(
        e.calendarDay.year,
        e.calendarDay.month,
        e.calendarDay.day,
      );
      map.putIfAbsent(d, () => <HydrationLogEntry>[]).add(e);
    }
    final keys = map.keys.toList()..sort((a, b) => b.compareTo(a));
    return [
      for (final k in keys)
        HistoryDaySection(
          calendarDay: k,
          entries: map[k]!.toList()
            ..sort((a, b) => b.record.timestamp.compareTo(a.record.timestamp)),
        ),
    ];
  }

  @override
  List<Object?> get props => [
        entries,
        profile,
        status,
        hasLogSnapshot,
        errorMessageKey,
      ];
}
