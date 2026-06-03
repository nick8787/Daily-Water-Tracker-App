import 'package:equatable/equatable.dart';
import 'package:daily_water_tracker/firebase/models/water_record_model.dart';

/// One drink row in the global hydration log with its calendar day document.
class HydrationLogEntry extends Equatable {
  const HydrationLogEntry({
    required this.record,
    required this.calendarDay,
  });

  final WaterRecordModel record;

  /// Normalized calendar date (`users/.../days/{yyyy-MM-dd}`).
  final DateTime calendarDay;

  @override
  List<Object?> get props => [record, calendarDay];
}
