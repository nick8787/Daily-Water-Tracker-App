import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:daily_water_tracker/common/services/analytics_service.dart';
import 'package:daily_water_tracker/common/utils/auto_goal_ml.dart';
import 'package:daily_water_tracker/firebase/models/drink_type.dart';
import 'package:daily_water_tracker/firebase/models/hydration_log_entry.dart';
import 'package:daily_water_tracker/firebase/models/statistics_week_data.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';
import 'package:daily_water_tracker/firebase/models/water_record_model.dart';
import 'package:daily_water_tracker/common/services/logger.dart';

/// Firestore-backed persistence for user profile, hydration logs and statistics
class FirestoreRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final AnalyticsService _analytics;

  FirestoreRepository({
    required FirebaseFirestore firestore,
    required FirebaseAuth auth,
    required AnalyticsService analytics,
  }) : _firestore = firestore,
       _auth = auth,
       _analytics = analytics;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  String? get _uidOrNull => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDocOrNull {
    final uid = _uidOrNull;
    if (uid == null) return null;
    return _usersCollection.doc(uid);
  }

  CollectionReference<Map<String, dynamic>>? get _daysCollectionOrNull =>
      _userDocOrNull?.collection('days');

  /// Writes profile fields and optionally sets [last_login] to server time (sign-up / profile save).
  Future<void> saveUserProfile(
    UserModel user, {
    bool setLastLoginNow = true,
  }) async {
    final payload = user.toFirestore();
    if (setLastLoginNow) {
      payload['last_login'] = FieldValue.serverTimestamp();
    }
    await _usersCollection.doc(user.id).set(payload, SetOptions(merge: true));
  }

  /// Merges Auth identity into `users/{uid}` and bumps [last_login]
  Future<void> syncUserRootFromAuth() async {
    final user = _auth.currentUser;
    final doc = _userDocOrNull;
    if (user == null || doc == null) return;

    final email = (user.email ?? '').trim();
    final displayName = (user.displayName ?? '').trim();
    final fallbackName = _shortNameFromEmail(email);
    final authPhotoUrl = (user.photoURL ?? '').trim();

    // Do not overwrite a custom uploaded photo.
    // Custom photo is identified by `photo_id` (Storage object path) being present.
    final snapshot = await doc.get();
    final data = snapshot.data();
    final hasCustomPhoto =
        (data?['photo_id'] as String?)?.trim().isNotEmpty == true;

    await doc.set(
      <String, dynamic>{
        'email': email,
        'user_name': displayName.isNotEmpty ? displayName : fallbackName,
        'last_login': FieldValue.serverTimestamp(),
        if (!hasCustomPhoto && authPhotoUrl.isNotEmpty)
          'photo_url': authPhotoUrl,
      },
      SetOptions(merge: true),
    );
  }

  static String _shortNameFromEmail(String email) {
    if (email.isEmpty) return LocaleKeys.common_user_default.tr();
    final at = email.indexOf('@');
    if (at <= 0) return email;
    return email.substring(0, at);
  }

  Future<UserModel?> getUserProfile() async {
    final doc = _userDocOrNull;
    if (doc == null) return null;

    final snapshot = await doc.get();
    if (!snapshot.exists) return null;

    final data = snapshot.data();
    if (data == null) return null;

    return UserModel.fromFirestore(id: snapshot.id, data: data);
  }

  Stream<UserModel?> watchUserProfile() {
    final doc = _userDocOrNull;
    if (doc == null) return Stream<UserModel?>.value(null);

    return doc.snapshots().map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return UserModel.fromFirestore(id: snapshot.id, data: data);
    });
  }

  Future<void> updateUserProfile({
    String? userName,
    String? email,
    String? firstName,
    String? lastName,
    bool clearFirstName = false,
    bool clearLastName = false,
    int? weightKg,
    bool clearWeightKg = false,
    String? gender,
    String? photoId,
    String? photoUrl,
    String? fcmToken,
    bool clearPhotoId = false,
    bool clearPhotoUrl = false,
    bool clearFcmToken = false,
    int? dailyGoalMl,
    List<int>? drinkPresets,
    int? reminderIntervalHours,
    bool clearReminderIntervalHours = false,
    int? reminderIntervalMinutes,
    bool clearReminderIntervalMinutes = false,
    String? quietHoursStart,
    String? quietHoursEnd,
    bool clearQuietHoursStart = false,
    bool clearQuietHoursEnd = false,
    bool? isAutoGoalEnabled,
    bool? notificationsEnabled,
    String? lastCelebratedRankId,
    bool clearLastCelebratedRankId = false,
  }) async {
    final doc = _userDocOrNull;
    if (doc == null) return;

    final payload = <String, dynamic>{};

    if (userName != null) payload['user_name'] = userName;
    if (email != null) payload['email'] = email;
    if (dailyGoalMl != null) {
      payload['daily_goal_ml'] = dailyGoalMl;
      payload['daily_water_limit'] = dailyGoalMl;
    }
    if (isAutoGoalEnabled != null) {
      payload['is_auto_goal_enabled'] = isAutoGoalEnabled;
    }
    if (notificationsEnabled != null) {
      payload['notifications_enabled'] = notificationsEnabled;
    }
    if (drinkPresets != null) payload['drink_presets'] = drinkPresets;
    if (reminderIntervalHours != null) {
      payload['reminder_interval_hours'] = reminderIntervalHours;
    } else if (clearReminderIntervalHours) {
      payload['reminder_interval_hours'] = FieldValue.delete();
    }
    if (reminderIntervalMinutes != null) {
      payload['reminder_interval_minutes'] = reminderIntervalMinutes;
    } else if (clearReminderIntervalMinutes) {
      payload['reminder_interval_minutes'] = FieldValue.delete();
    }
    if (quietHoursStart != null) {
      payload['quiet_hours_start'] = quietHoursStart;
    } else if (clearQuietHoursStart) {
      payload['quiet_hours_start'] = FieldValue.delete();
    }
    if (quietHoursEnd != null) {
      payload['quiet_hours_end'] = quietHoursEnd;
    } else if (clearQuietHoursEnd) {
      payload['quiet_hours_end'] = FieldValue.delete();
    }
    if (firstName != null) {
      payload['first_name'] = firstName;
    } else if (clearFirstName) {
      payload['first_name'] = FieldValue.delete();
    }
    if (lastName != null) {
      payload['last_name'] = lastName;
    } else if (clearLastName) {
      payload['last_name'] = FieldValue.delete();
    }
    if (clearWeightKg) {
      payload['weight_kg'] = FieldValue.delete();
    } else if (weightKg != null) {
      payload['weight_kg'] = weightKg;
    }
    if (gender != null) payload['gender'] = gender;
    if (photoId != null) payload['photo_id'] = photoId;
    if (photoUrl != null) payload['photo_url'] = photoUrl;
    if (fcmToken != null) payload['fcm_token'] = fcmToken;
    if (clearPhotoId) payload['photo_id'] = FieldValue.delete();
    if (clearPhotoUrl) payload['photo_url'] = FieldValue.delete();
    if (clearFcmToken) payload['fcm_token'] = FieldValue.delete();
    if (lastCelebratedRankId != null) {
      payload['last_celebrated_rank_id'] = lastCelebratedRankId;
    } else if (clearLastCelebratedRankId) {
      payload['last_celebrated_rank_id'] = FieldValue.delete();
    }

    if (payload.isEmpty) return;
    await doc.set(payload, SetOptions(merge: true));

    final trimmedName = (userName ?? '').trim();
    if (trimmedName.isNotEmpty) {
      unawaited(_analytics.logNameUpdated());
    }
    if (photoId != null || photoUrl != null || clearPhotoId || clearPhotoUrl) {
      unawaited(_analytics.logPhotoUpdated());
    }
  }

  Future<void> updateLastCelebratedRankId(String rankId) async {
    await updateUserProfile(lastCelebratedRankId: rankId);
  }

  Future<void> clearLastCelebratedRankId() async {
    await updateUserProfile(clearLastCelebratedRankId: true);
  }

  /// When auto-goal is on, rewrite [daily_goal_ml] if weight implies a different snapped target.
  Future<void> reconcileAutoDailyGoalIfNeeded(UserModel profile) async {
    if (!profile.isAutoGoalEnabled) return;
    final w = profile.weightKg;
    if (w == null || w <= 0) {
      await updateUserProfile(isAutoGoalEnabled: false);
      return;
    }
    final computed = goalMlFromWeightKg(w);
    if (computed == profile.dailyGoalMl) return;
    await updateUserProfile(dailyGoalMl: computed);
  }

  /// Persists one intake under the day doc as `<msKey>: { amount, type, coefficient }`.
  Future<void> addWaterRecord({
    required int volumeMl,
    required DrinkType drinkType,
  }) async {
    if (volumeMl <= 0) {
      throw ArgumentError.value(volumeMl, 'volumeMl', 'Value must be > 0');
    }

    final days = _daysCollectionOrNull;
    if (days == null) {
      throw StateError('User must be authenticated.');
    }

    final now = DateTime.now();
    final dayDocId = _dayDocId(now);
    final timeKey = now.millisecondsSinceEpoch.toString();

    final entry = WaterRecordModel.fromInput(
      recordKey: timeKey,
      timestamp: now,
      volumeMl: volumeMl,
      drinkType: drinkType,
    );

    await days.doc(dayDocId).set(
      <String, dynamic>{timeKey: entry.toFirestoreEntryMap()},
      SetOptions(merge: true),
    );
  }

  /// Overwrites one intake field on the day doc (same [recordKey]; snapshot coefficient follows [drinkType]).
  Future<void> updateDayWaterEntry({
    required DateTime calendarDay,
    required String recordKey,
    required int volumeMl,
    required DrinkType drinkType,
    required DateTime timestamp,
  }) async {
    if (volumeMl <= 0) {
      throw ArgumentError.value(volumeMl, 'volumeMl', 'Value must be > 0');
    }
    final days = _daysCollectionOrNull;
    if (days == null) {
      throw StateError('User must be authenticated.');
    }

    final day = DateTime(calendarDay.year, calendarDay.month, calendarDay.day);
    final dayDocId = _dayDocId(day);
    final entry = WaterRecordModel.fromInput(
      recordKey: recordKey,
      timestamp: timestamp,
      volumeMl: volumeMl,
      drinkType: drinkType,
    );

    await days.doc(dayDocId).set(
      <String, dynamic>{recordKey: entry.toFirestoreEntryMap()},
      SetOptions(merge: true),
    );
  }

  /// Removes a single intake key from the day document.
  Future<void> deleteDayWaterEntry({
    required DateTime calendarDay,
    required String recordKey,
  }) async {
    final days = _daysCollectionOrNull;
    if (days == null) {
      throw StateError('User must be authenticated.');
    }
    final day = DateTime(calendarDay.year, calendarDay.month, calendarDay.day);
    final dayDocId = _dayDocId(day);
    await days.doc(dayDocId).update(<String, dynamic>{
      recordKey: FieldValue.delete(),
    });
  }

  /// Real-time updates for a single calendar day (local date parts of [day]).
  Stream<List<WaterRecordModel>> watchDayRecords(DateTime day) {
    final days = _daysCollectionOrNull;
    if (days == null)
      return Stream<List<WaterRecordModel>>.value(const <WaterRecordModel>[]);

    final calendarDay = DateTime(day.year, day.month, day.day);
    final dayDocId = _dayDocId(calendarDay);

    return days.doc(dayDocId).snapshots().map((snapshot) {
      final records = List<WaterRecordModel>.from(
        _recordsFromDaySnapshot(snapshot.data(), calendarDay),
      );
      records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return records;
    });
  }

  /// Parses `users/{uid}/days/{yyyy-MM-dd}` map into records (same rules as [watchDayRecords]).
  List<WaterRecordModel> _recordsFromDaySnapshot(
    Map<String, dynamic>? data,
    DateTime calendarDay,
  ) {
    if (data == null || data.isEmpty) return <WaterRecordModel>[];

    final records = <WaterRecordModel>[];
    data.forEach((key, value) {
      final record = WaterRecordModel.parseDayField(
        key: key,
        value: value,
        calendarDay: calendarDay,
        parseTimeKey: _parseTimeKeyForDay,
      );
      if (record != null) records.add(record);
    });
    return records;
  }

  static double _effectiveHydrationTotalMl(List<WaterRecordModel> records) {
    var sum = 0.0;
    for (final r in records) {
      sum += r.effectiveHydrationMl;
    }
    return sum;
  }

  /// All drink entries across every day document, newest first (by event time).
  Stream<List<HydrationLogEntry>> watchHydrationLog() {
    final days = _daysCollectionOrNull;
    if (days == null) {
      return Stream<List<HydrationLogEntry>>.value(const <HydrationLogEntry>[]);
    }

    return days.snapshots().map((snapshot) {
      final out = <HydrationLogEntry>[];
      for (final doc in snapshot.docs) {
        final calendarDay = _calendarDayFromDayDocId(doc.id);
        if (calendarDay == null) continue;
        final records = _recordsFromDaySnapshot(doc.data(), calendarDay);
        for (final r in records) {
          out.add(HydrationLogEntry(record: r, calendarDay: calendarDay));
        }
      }
      out.sort((a, b) => b.record.timestamp.compareTo(a.record.timestamp));
      return out;
    });
  }

  DateTime? _calendarDayFromDayDocId(String docId) {
    try {
      final parts = docId.split('-');
      if (parts.length != 3) return null;
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      return DateTime(y, m, d);
    } catch (e, st) {
      logCaughtWarning('FirestoreRepository._calendarDayFromDayDocId: $docId', e, st);
      return null;
    }
  }

  /// Per-day totals + drink mix for the statistics screen (oldest day first).
  Future<StatisticsWeekData> fetchStatisticsWeekData({int dayCount = 7}) async {
    if (dayCount <= 0) {
      throw ArgumentError.value(dayCount, 'dayCount', 'Must be positive');
    }

    final days = _daysCollectionOrNull;
    if (days == null) {
      throw StateError('User must be authenticated.');
    }

    final profile = await getUserProfile();
    if (profile == null) {
      throw StateError('User profile not found.');
    }

    final snap = await days.get();
    return _buildStatisticsWeekData(
      profile: profile,
      daysSnapshot: snap,
      dayCount: dayCount,
    );
  }

  /// Live updates when `users/{uid}` profile or `days` sub-collection documents change.
  Stream<StatisticsWeekData> watchStatisticsWeekData({int dayCount = 7}) {
    final daysCol = _daysCollectionOrNull;
    final userDoc = _userDocOrNull;
    if (daysCol == null || userDoc == null) {
      return const Stream.empty();
    }

    UserModel? profile;
    QuerySnapshot<Map<String, dynamic>>? daysSnap;

    late final StreamController<StatisticsWeekData> controller;

    void emit() {
      if (profile == null || daysSnap == null) return;
      try {
        controller.add(
          _buildStatisticsWeekData(
            profile: profile!,
            daysSnapshot: daysSnap!,
            dayCount: dayCount,
          ),
        );
      } catch (e, st) {
        logCaughtError('FirestoreRepository.watchStatisticsWeekData', e, st);
        controller.addError(e, st);
      }
    }

    StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? subUser;
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? subDays;

    controller = StreamController<StatisticsWeekData>(
      onListen: () {
        subUser = userDoc.snapshots().listen(
          (snap) {
            final data = snap.data();
            if (!snap.exists || data == null) return;
            profile = UserModel.fromFirestore(id: snap.id, data: data);
            emit();
          },
          onError: controller.addError,
        );
        subDays = daysCol.snapshots().listen(
          (snap) {
            daysSnap = snap;
            emit();
          },
          onError: controller.addError,
        );
      },
      onCancel: () async {
        await subUser?.cancel();
        await subDays?.cancel();
      },
    );

    return controller.stream;
  }

  StatisticsWeekData _buildStatisticsWeekData({
    required UserModel profile,
    required QuerySnapshot<Map<String, dynamic>> daysSnapshot,
    required int dayCount,
  }) {
    final goalMl = profile.dailyGoalMl;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final byDocId = <String, Map<String, dynamic>>{
      for (final d in daysSnapshot.docs) d.id: d.data(),
    };

    final dayBars = <StatisticsDayBar>[];
    final drinkAgg = <DrinkType, double>{
      for (final t in DrinkType.values) t: 0.0,
    };

    for (var k = dayCount - 1; k >= 0; k--) {
      final calendarDay = today.subtract(Duration(days: k));
      final dayDocId = _dayDocId(calendarDay);
      final raw = byDocId[dayDocId];
      final records = _recordsFromDaySnapshot(raw, calendarDay);
      for (final r in records) {
        drinkAgg[r.drinkType] =
            (drinkAgg[r.drinkType] ?? 0) + r.effectiveHydrationMl;
      }
      final dayTotal = _effectiveHydrationTotalMl(records);

      dayBars.add(
        StatisticsDayBar(
          date: calendarDay,
          totalMl: dayTotal.round(),
          goalMl: goalMl,
        ),
      );
    }

    final drinkEffectiveTotals =
        drinkAgg.entries
            .map(
              (e) => DrinkEffectiveMlBucket(
                drinkType: e.key,
                effectiveMl: e.value.round(),
              ),
            )
            .where((b) => b.effectiveMl > 0)
            .toList()
          ..sort((a, b) => b.effectiveMl.compareTo(a.effectiveMl));

    return StatisticsWeekData(
      dailyGoalMl: goalMl,
      dayBars: dayBars,
      drinkEffectiveTotals: drinkEffectiveTotals,
    );
  }

  DateTime? _parseTimeKeyForDay(String key, DateTime calendarDay) {
    final millis = int.tryParse(key);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }

    final parts = key.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;

    return DateTime(
      calendarDay.year,
      calendarDay.month,
      calendarDay.day,
      hour,
      minute,
    );
  }

  String _dayDocId(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  /// Deletes `users/{uid}/days/*` in batches, then the root user document.
  Future<void> deleteUserAccountData({required String uid}) async {
    final userRef = _usersCollection.doc(uid);
    final daysRef = userRef.collection('days');

    while (true) {
      final snapshot = await daysRef.limit(450).get();
      if (snapshot.docs.isEmpty) break;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    await userRef.delete();
  }

  /// One-off retrieval of the entire record history (for achievements)
  Future<List<HydrationLogEntry>> fetchHydrationLog() async {
    final days = _daysCollectionOrNull;
    if (days == null) return const [];

    final snapshot = await days.get();
    final out = <HydrationLogEntry>[];

    for (final doc in snapshot.docs) {
      final calendarDay = _calendarDayFromDayDocId(doc.id);
      if (calendarDay == null) continue;

      final records = _recordsFromDaySnapshot(doc.data(), calendarDay);
      for (final r in records) {
        out.add(HydrationLogEntry(record: r, calendarDay: calendarDay));
      }
    }

    out.sort((a, b) => b.record.timestamp.compareTo(a.record.timestamp));
    return out;
  }
}
