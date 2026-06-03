import 'package:flutter/material.dart';

String formatQuietHours(TimeOfDay time) {
  final h = time.hour.toString().padLeft(2, '0');
  final m = time.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

TimeOfDay parseQuietHours(String? raw, TimeOfDay fallback) {
  if (raw == null || raw.trim().isEmpty) return fallback;
  final parts = raw.trim().split(':');
  if (parts.length != 2) return fallback;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return fallback;
  if (h < 0 || h > 23 || m < 0 || m > 59) return fallback;
  return TimeOfDay(hour: h, minute: m);
}
