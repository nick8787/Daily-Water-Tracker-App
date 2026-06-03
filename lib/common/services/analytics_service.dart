import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';
import 'package:daily_water_tracker/common/services/logger.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;

  AnalyticsService({
    required FirebaseAnalytics analytics,
    required FirebaseCrashlytics crashlytics,
  }) : _analytics = analytics,
       _crashlytics = crashlytics;

  void setAnalyticAndCrashlyticsUser({required User? user}) {
    if (user == null) {
      _crashlytics.setUserIdentifier('');
      return;
    }
    _crashlytics.setUserIdentifier(user.uid);

    _crashlytics.setCustomKey('email', user.email ?? '');
    _crashlytics.setCustomKey('display_name', user.displayName ?? '');
  }

  /// Observers for [GoRouter] / [Navigator] — safely returned
  static List<NavigatorObserver> navigatorObservers() {
    return [FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)];
  }

  Future<void> _safe(String label, Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e, st) {
      logCaughtWarning('Analytics skipped: $label', e, st);
    }
  }

  /// Task: [drink_water] when user adds a drink; [value] = ml (GA4-style numeric value).
  Future<void> logDrinkWater({
    required int volumeMl,
    required String drinkTypeWire,
  }) {
    return _safe('drink_water', () async {
      await _analytics.logEvent(
        name: 'drink_water',
        parameters: <String, Object>{
          'volume_ml': volumeMl,
          'value': volumeMl.toDouble(),
          'drink_type': drinkTypeWire,
        },
      );
    });
  }

  /// When an existing day entry is saved after edit.
  Future<void> logWaterRecordUpdated({
    required int volumeMl,
    required String drinkTypeWire,
  }) {
    return _safe('water_record_updated', () async {
      await _analytics.logEvent(
        name: 'water_record_updated',
        parameters: <String, Object>{
          'volume_ml': volumeMl,
          'drink_type': drinkTypeWire,
        },
      );
    });
  }

  /// When a day entry is removed.
  Future<void> logWaterRecordDeleted() {
    return _safe('water_record_deleted', () async {
      await _analytics.logEvent(name: 'water_record_deleted');
    });
  }

  /// Task: profile photo changed (upload, URL set, or cleared).
  Future<void> logPhotoUpdated() {
    return _safe('photo_updated', () async {
      await _analytics.logEvent(name: 'photo_updated');
    });
  }

  /// Task: display name changed in Firestore profile.
  Future<void> logNameUpdated() {
    return _safe('name_updated', () async {
      await _analytics.logEvent(name: 'name_updated');
    });
  }
}
