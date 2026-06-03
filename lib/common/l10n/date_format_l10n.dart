import 'package:intl/intl.dart';
import 'package:daily_water_tracker/common/services/logger.dart';

/// Language code for `intl` (`uk`, `en`), not a full BCP-47 tag like `uk_UA`.
String intlLanguageCode(String localeTag) {
  final tag = localeTag.trim();
  if (tag.isEmpty) return 'en';
  return tag.split(RegExp('[_-]')).first;
}

/// Single localized letter for a weekday on the statistics bar chart axis.
String formatWeekdayChartLetter(DateTime date, String localeTag) {
  final lang = intlLanguageCode(localeTag);
  try {
    final narrow = DateFormat('EEEEE', lang).format(date);
    if (narrow.isNotEmpty) {
      return _firstLetterUpper(narrow);
    }
  } catch (e, st) {
    logCaughtWarning('formatWeekdayChartLetter EEEEE', e, st);
  }
  try {
    final short = DateFormat('EEE', lang).format(date);
    if (short.isNotEmpty) {
      return _firstLetterUpper(short);
    }
  } catch (e, st) {
    logCaughtWarning('formatWeekdayChartLetter EEE', e, st);
  }
  return '?';
}

/// Full weekday name (e.g. Thursday / четвер).
String formatWeekdayLong(DateTime date, String localeTag) {
  final lang = intlLanguageCode(localeTag);
  return DateFormat('EEEE', lang).format(date);
}

String _firstLetterUpper(String value) {
  if (value.isEmpty) return value;
  final first = value[0];
  if (first == first.toUpperCase()) return first;
  return first.toUpperCase();
}
