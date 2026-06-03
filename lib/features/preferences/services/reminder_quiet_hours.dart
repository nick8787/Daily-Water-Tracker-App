class ReminderQuietHours {
  ReminderQuietHours._();

  static int? parseMinutes(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final parts = raw.trim().split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return h * 60 + m;
  }

  static bool isOvernight(int startMin, int endMin) => startMin > endMin;

  static bool _inQuiet(
    int minuteOfDay,
    int startMin,
    int endMin,
    bool overnight,
  ) {
    if (overnight) {
      return minuteOfDay >= startMin || minuteOfDay < endMin;
    }
    return minuteOfDay >= startMin && minuteOfDay < endMin;
  }

  static int _minuteOfDay(DateTime t) => t.hour * 60 + t.minute;

  static DateTime adjustIfInQuiet(
    DateTime t, {
    required int? quietStartMin,
    required int? quietEndMin,
  }) {
    if (quietStartMin == null || quietEndMin == null) return t;
    final overnight = isOvernight(quietStartMin, quietEndMin);
    var x = t;
    const maxSteps = 48 * 60;
    for (var i = 0; i < maxSteps; i++) {
      final mod = _minuteOfDay(x);
      if (!_inQuiet(mod, quietStartMin, quietEndMin, overnight)) return x;
      x = x.add(const Duration(minutes: 1));
    }
    return t;
  }
}
