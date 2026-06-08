import 'dart:developer' as developer;
import 'dart:io';

import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:stack_trace/stack_trace.dart';

const _socketException = 'SocketException';
const _timeoutException = 'TimeoutException - Api client';

Future<void> recordCrashlyticsError(
  dynamic e,
  StackTrace currSt,
  StackTrace? st, {
  String? reason,
  dynamic message,
  String? source,
  bool fatal = false,
  bool withIntercom = true,
}) async {
  logCaughtError(reason ?? 'recordCrashlyticsError', e, st ?? currSt);
  try {
    String? blockListExceptionStackTrace;

    if (e is SocketException) {
      blockListExceptionStackTrace = _socketException;
    } else if (e.toString().contains('TimeoutException')) {
      blockListExceptionStackTrace = _timeoutException;
    }

    if (blockListExceptionStackTrace != null) {
      blockListExceptionStackTrace =
          '_____${blockListExceptionStackTrace}_____';
    }

    await FirebaseCrashlytics.instance.log('$e $message $reason');

    final mergedSt = _mergeStackTraces(
      blockListExceptionStackTrace,
      currSt,
      st ?? currSt,
    );

    await FirebaseCrashlytics.instance.recordError(
      e,
      mergedSt ?? st,
      reason: reason,
      printDetails: false,
      fatal: fatal,
    );
  } catch (e1, st1) {
    await basicRecordCrashlyticsError(e, st, reason: reason);
    await basicRecordCrashlyticsError(e1, st1, reason: reason);
  }
}

Future<void> basicRecordCrashlyticsError(
  dynamic e,
  StackTrace? st, {
  String? reason,
  bool fatal = false,
  Iterable<Object> information = const [],
}) async {
  logCaughtError(reason ?? 'basicRecordCrashlyticsError', e, st);
  try {
    await FirebaseCrashlytics.instance.recordError(
      e,
      st,
      reason: reason,
      printDetails: false,
      fatal: fatal,
      information: information,
    );
  } catch (fallbackError) {
    developer.log(
      'Critical failure in basicRecordCrashlyticsError',
      error: fallbackError,
    );
  }
}

StackTrace? _mergeStackTraces(
  String? blockListExceptionStackTrace,
  StackTrace currSt,
  StackTrace? st,
) {
  if (st == null) return null;

  try {
    final chain = Trace.from(currSt);
    final trace = Trace.from(st);

    final frames = [...trace.frames, ...chain.frames];
    if (blockListExceptionStackTrace != null) {
      frames.insert(
        0,
        Frame(
          Uri.parse(blockListExceptionStackTrace),
          0,
          0,
          blockListExceptionStackTrace,
        ),
      );
    }

    return Trace(frames);
  } catch (e, mergeSt) {
    logCaughtWarning('crashlytics._mergeStackTraces', e, mergeSt);
    return st;
  }
}
