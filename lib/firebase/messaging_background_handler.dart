import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Background push handler (Android).
///
/// Must be a top-level function and annotated as an entry-point.
/// Keep it lightweight: no UI, no navigation.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (e, st) {
    logCaughtError('firebaseMessagingBackgroundHandler', e, st);
    // Best-effort: if Firebase is already initialized, ignore.
  }
}

