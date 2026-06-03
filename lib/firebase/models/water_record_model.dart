import 'package:daily_water_tracker/firebase/models/drink_type.dart';

/// One intake row for a calendar day document in Firestore.
///
/// Firestore shape per timestamp key:
/// `{ "amount": <int>, "type": "<wireName>", "coefficient": <double> }`
///
/// Legacy (dev-only) shape `{ "<timestamp>": <int ml> }` is still parsed as plain water.
class WaterRecordModel {
  const WaterRecordModel({
    required this.recordKey,
    required this.timestamp,
    required this.volumeMl,
    required this.drinkType,
    required this.coefficient,
  });

  /// Firestore map key under `users/.../days/{yyyy-MM-dd}` for this entry.
  final String recordKey;

  /// Event time (includes hours/minutes; date inferred from parent day doc).
  final DateTime timestamp;

  /// Physical volume consumed.
  final int volumeMl;

  /// Drink category at write time (defaults used when migrating legacy ints).
  final DrinkType drinkType;

  /// Coefficient snapshot at write time — historical rows stay stable if enum defaults change.
  final double coefficient;

  /// Contribution toward the daily progress ring: `volume × coefficient`.
  double get effectiveHydrationMl => volumeMl * coefficient;

  Map<String, dynamic> toFirestoreEntryMap() {
    return <String, dynamic>{
      'amount': volumeMl,
      'type': drinkType.wireName,
      'coefficient': coefficient,
    };
  }

  /// Builds a new record using enum defaults for coefficient (normal add / edit flow).
  factory WaterRecordModel.fromInput({
    required String recordKey,
    required DateTime timestamp,
    required int volumeMl,
    required DrinkType drinkType,
  }) {
    return WaterRecordModel(
      recordKey: recordKey,
      timestamp: timestamp,
      volumeMl: volumeMl,
      drinkType: drinkType,
      coefficient: drinkType.defaultCoefficient,
    );
  }

  /// Parses one field from a day document: key = time id, value = int legacy or map entry.
  static WaterRecordModel? parseDayField({
    required String key,
    required dynamic value,
    required DateTime calendarDay,
    required DateTime? Function(String key, DateTime calendarDay) parseTimeKey,
  }) {
    final timestamp = parseTimeKey(key, calendarDay);
    if (timestamp == null) return null;

    if (value is int) {
      return WaterRecordModel(
        recordKey: key,
        timestamp: timestamp,
        volumeMl: value,
        drinkType: DrinkType.water,
        coefficient: DrinkType.water.defaultCoefficient,
      );
    }

    if (value is! Map) return null;

    final map = Map<String, dynamic>.from(value);
    final amountRaw = map['amount'];
    final volume = amountRaw is int ? amountRaw : int.tryParse('$amountRaw');
    if (volume == null || volume <= 0) return null;

    final typeRaw = map['type'];
    final typeStr = typeRaw is String ? typeRaw : '$typeRaw';
    final drinkType = DrinkType.fromWireName(typeStr);

    final coeffRaw = map['coefficient'] ?? map['coeff'];
    double coefficient;
    if (coeffRaw is num) {
      coefficient = coeffRaw.toDouble();
    } else {
      coefficient = double.tryParse('$coeffRaw') ?? drinkType.defaultCoefficient;
    }

    return WaterRecordModel(
      recordKey: key,
      timestamp: timestamp,
      volumeMl: volume,
      drinkType: drinkType,
      coefficient: coefficient,
    );
  }
}
