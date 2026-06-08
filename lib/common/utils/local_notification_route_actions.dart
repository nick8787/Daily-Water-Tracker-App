import 'dart:async';

import 'package:daily_water_tracker/common/router.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> routeFromLocalNotificationTap(String? route) async {
  switch ((route ?? '').trim()) {
    case ReminderSchedulerService.hydrationReminderRoute:
      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null) {
        unawaited(ctx.read<ReminderSchedulerService>().rescheduleReminders());
      }
      goRouter.go(homeRoute);
      return;
    case 'account':
    case '':
      goRouter.go(accountRoute);
      return;
    default:
      goRouter.go(accountRoute);
  }
}
