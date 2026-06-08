import 'dart:math';

import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';

/// Localized rotating copy for scheduled hydration reminders.
class ReminderMessages {
  ReminderMessages._();

  static final _random = Random();

  static const List<({String titleKey, String bodyKey})> _entries = [
    (titleKey: LocaleKeys.reminder_msg_01_title, bodyKey: LocaleKeys.reminder_msg_01_body),
    (titleKey: LocaleKeys.reminder_msg_02_title, bodyKey: LocaleKeys.reminder_msg_02_body),
    (titleKey: LocaleKeys.reminder_msg_03_title, bodyKey: LocaleKeys.reminder_msg_03_body),
    (titleKey: LocaleKeys.reminder_msg_04_title, bodyKey: LocaleKeys.reminder_msg_04_body),
    (titleKey: LocaleKeys.reminder_msg_05_title, bodyKey: LocaleKeys.reminder_msg_05_body),
    (titleKey: LocaleKeys.reminder_msg_06_title, bodyKey: LocaleKeys.reminder_msg_06_body),
    (titleKey: LocaleKeys.reminder_msg_07_title, bodyKey: LocaleKeys.reminder_msg_07_body),
    (titleKey: LocaleKeys.reminder_msg_08_title, bodyKey: LocaleKeys.reminder_msg_08_body),
    (titleKey: LocaleKeys.reminder_msg_09_title, bodyKey: LocaleKeys.reminder_msg_09_body),
    (titleKey: LocaleKeys.reminder_msg_10_title, bodyKey: LocaleKeys.reminder_msg_10_body),
    (titleKey: LocaleKeys.reminder_msg_11_title, bodyKey: LocaleKeys.reminder_msg_11_body),
    (titleKey: LocaleKeys.reminder_msg_12_title, bodyKey: LocaleKeys.reminder_msg_12_body),
  ];

  static ({String title, String body}) pick() {
    final entry = _entries[_random.nextInt(_entries.length)];
    return (title: entry.titleKey.tr(), body: entry.bodyKey.tr());
  }
}
