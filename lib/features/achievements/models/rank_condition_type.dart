enum RankConditionType {
  /// At least one hydration log entry exists.
  logEntries,

  /// Calendar days where effective intake met the daily goal (not consecutive).
  goalDays,

  /// Cumulative effective hydration volume (ml).
  totalVolumeMl,
}
