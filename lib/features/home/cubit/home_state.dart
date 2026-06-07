import 'package:daily_water_tracker/common/constants/hydration_defaults.dart';
import 'package:daily_water_tracker/features/achievements/models/badge_model.dart';
import 'package:daily_water_tracker/firebase/models/water_record_model.dart';

class HomeState {
  const HomeState({
    required this.records,
    required this.dailyLimitMl,
    required this.drinkPresetsMl,
    required this.isLoading,
    required this.errorCode,
    required this.selectedDate,
    required this.totalRawMl,
    required this.totalEffectiveMl,
    required this.anchoredToLiveToday,
    required this.deferProgressUpdates,
    required this.pendingRecords,
    this.pendingRankCelebration,
  });

  final List<WaterRecordModel> records;
  final int dailyLimitMl;
  final List<int> drinkPresetsMl;
  final bool isLoading;
  final String? errorCode;

  final DateTime selectedDate;

  final int totalRawMl;

  final int totalEffectiveMl;

  final bool anchoredToLiveToday;

  final bool deferProgressUpdates;

  final List<WaterRecordModel>? pendingRecords;

  final BadgeModel? pendingRankCelebration;

  HomeState copyWith({
    List<WaterRecordModel>? records,
    int? dailyLimitMl,
    List<int>? drinkPresetsMl,
    bool? isLoading,
    String? errorCode,
    DateTime? selectedDate,
    int? totalRawMl,
    int? totalEffectiveMl,
    bool? anchoredToLiveToday,
    bool? deferProgressUpdates,
    List<WaterRecordModel>? pendingRecords,
    BadgeModel? pendingRankCelebration,
    bool clearPendingRecords = false,
    bool clearPendingRankCelebration = false,
  }) {
    return HomeState(
      records: records ?? this.records,
      dailyLimitMl: dailyLimitMl ?? this.dailyLimitMl,
      drinkPresetsMl: drinkPresetsMl ?? this.drinkPresetsMl,
      isLoading: isLoading ?? this.isLoading,
      errorCode: errorCode ?? this.errorCode,
      selectedDate: selectedDate ?? this.selectedDate,
      totalRawMl: totalRawMl ?? this.totalRawMl,
      totalEffectiveMl: totalEffectiveMl ?? this.totalEffectiveMl,
      anchoredToLiveToday: anchoredToLiveToday ?? this.anchoredToLiveToday,
      deferProgressUpdates: deferProgressUpdates ?? this.deferProgressUpdates,
      pendingRecords:
          clearPendingRecords ? null : (pendingRecords ?? this.pendingRecords),
      pendingRankCelebration: clearPendingRankCelebration
          ? null
          : (pendingRankCelebration ?? this.pendingRankCelebration),
    );
  }

  factory HomeState.initial() {
    final now = DateTime.now();
    return HomeState(
      records: const <WaterRecordModel>[],
      dailyLimitMl: 3000,
      drinkPresetsMl: List<int>.from(kDefaultDrinkPresetsMl),
      isLoading: true,
      errorCode: null,
      selectedDate: DateTime(now.year, now.month, now.day),
      totalRawMl: 0,
      totalEffectiveMl: 0,
      anchoredToLiveToday: true,
      deferProgressUpdates: false,
      pendingRecords: null,
      pendingRankCelebration: null,
    );
  }
}
