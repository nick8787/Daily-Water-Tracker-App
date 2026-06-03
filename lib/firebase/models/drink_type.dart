/// Static catalog for drink kinds: UI label, default hydration coefficient, asset icon.
///
/// Coefficients match the training design (water 1.0, coffee 0.8, green tea 1.0, milk 1.35).
/// [wireName] is persisted to Firestore (`type` field).
enum DrinkType {
  water(
    wireName: 'water',
    displayLabel: 'Water',
    defaultCoefficient: 1.0,
    assetPath: 'assets/images/glass_of_water.png',
  ),
  coffee(
    wireName: 'coffee',
    displayLabel: 'Coffee',
    defaultCoefficient: 0.8,
    assetPath: 'assets/images/glass_of_water.png',
  ),
  greenTea(
    wireName: 'green_tea',
    displayLabel: 'Green tea',
    defaultCoefficient: 1.0,
    assetPath: 'assets/images/glass_of_water.png',
  ),
  milk(
    wireName: 'milk',
    displayLabel: 'Milk',
    defaultCoefficient: 1.35,
    assetPath: 'assets/images/glass_of_water.png',
  );

  const DrinkType({
    required this.wireName,
    required this.displayLabel,
    required this.defaultCoefficient,
    required this.assetPath,
  });

  /// Serializable token stored in Firestore under `type`.
  final String wireName;

  /// Short English label for lists / bottom sheet (localize later via easy_localization).
  final String displayLabel;

  /// Default hydration multiplier applied when creating a record (snapshot stored on write).
  final double defaultCoefficient;

  /// Raster asset for list / picker icons (replace duplicates with distinct art when available).
  final String assetPath;

  /// Parses [raw] from Firestore; unknown or empty values fall back to [water].
  static DrinkType fromWireName(String? raw) {
    if (raw == null || raw.isEmpty) return DrinkType.water;
    for (final v in DrinkType.values) {
      if (v.wireName == raw) return v;
    }
    return DrinkType.water;
  }
}
