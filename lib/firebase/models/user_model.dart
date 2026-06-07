import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:daily_water_tracker/common/constants/hydration_defaults.dart';

/// User root document: `users/{uid}` (sub-collection [days] hangs here).
///
/// Firestore fields include `daily_goal_ml` / `daily_water_limit` (kept in sync),
/// `drink_presets`, optional reminder / quiet hours (future use).
class UserModel {
  const UserModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.dailyGoalMl,
    this.isAutoGoalEnabled = false,
    this.notificationsEnabled = true,
    this.firstName,
    this.lastName,
    this.weightKg,
    this.gender,
    this.photoId,
    this.photoUrl,
    this.fcmToken,
    this.lastLogin,
    this.drinkPresets = kDefaultDrinkPresetsMl,
    this.reminderIntervalHours,
    this.reminderIntervalMinutes,
    this.quietHoursStart,
    this.quietHoursEnd,
    this.lastCelebratedRankId,
  });

  final String id;
  final String userName;
  final String email;

  /// Target hydration per day (maps to `daily_goal_ml` and `daily_water_limit` in Firestore).
  final int dailyGoalMl;

  /// When true, [dailyGoalMl] is derived from [weightKg] (~35 ml/kg) and kept in sync.
  final bool isAutoGoalEnabled;

  /// When true, user wants reminder notifications (still requires OS permission).
  final bool notificationsEnabled;

  /// Legacy alias used by home / analytics paths (`daily_water_limit`).
  int get dailyWaterLimit => dailyGoalMl;

  /// Optional split name fields (for profile editing UI).
  final String? firstName;
  final String? lastName;

  /// Optional physical params.
  final int? weightKg;

  /// `male` | `female` | `other`
  final String? gender;

  /// Storage path / object id after Firebase Storage upload (see training schema).
  final String? photoId;

  /// Optional profile image URL (e.g. Google/Facebook `photoURL`) until replaced by Storage.
  final String? photoUrl;

  /// FCM device token; set when Cloud Messaging is integrated.
  final String? fcmToken;

  /// Last successful auth/session sync from server [Timestamp].
  final DateTime? lastLogin;

  /// Quick-add preset volumes (ml).
  final List<int> drinkPresets;

  /// Optional reminder interval (hours); null = not configured.
  final int? reminderIntervalHours;

  /// Optional short interval in minutes (DEV QA: e.g. 3). Ignored by prod scheduler.
  final int? reminderIntervalMinutes;

  /// Optional quiet window local times e.g. `"22:00"`.
  final String? quietHoursStart;
  final String? quietHoursEnd;

  /// Last hydration rank for which the ascension ceremony was shown.
  final String? lastCelebratedRankId;

  Map<String, dynamic> toFirestore() {
    return <String, dynamic>{
      'user_name': userName,
      'email': email,
      'daily_goal_ml': dailyGoalMl,
      'daily_water_limit': dailyGoalMl,
      'is_auto_goal_enabled': isAutoGoalEnabled,
      'notifications_enabled': notificationsEnabled,
      'drink_presets': drinkPresets,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (weightKg != null) 'weight_kg': weightKg,
      if (gender != null) 'gender': gender,
      if (photoId != null) 'photo_id': photoId,
      if (photoUrl != null) 'photo_url': photoUrl,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (reminderIntervalHours != null) 'reminder_interval_hours': reminderIntervalHours,
      if (reminderIntervalMinutes != null) 'reminder_interval_minutes': reminderIntervalMinutes,
      if (quietHoursStart != null) 'quiet_hours_start': quietHoursStart,
      if (quietHoursEnd != null) 'quiet_hours_end': quietHoursEnd,
      if (lastCelebratedRankId != null)
        'last_celebrated_rank_id': lastCelebratedRankId,
    };
  }

  static const Object _unset = Object();

  UserModel copyWith({
    String? id,
    String? userName,
    String? email,
    int? dailyGoalMl,
    bool? isAutoGoalEnabled,
    bool? notificationsEnabled,
    String? firstName,
    String? lastName,
    int? weightKg,
    String? gender,
    String? photoId,
    String? photoUrl,
    String? fcmToken,
    DateTime? lastLogin,
    List<int>? drinkPresets,
    Object? reminderIntervalHours = _unset,
    Object? reminderIntervalMinutes = _unset,
    Object? quietHoursStart = _unset,
    Object? quietHoursEnd = _unset,
    Object? lastCelebratedRankId = _unset,
  }) {
    return UserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      dailyGoalMl: dailyGoalMl ?? this.dailyGoalMl,
      isAutoGoalEnabled: isAutoGoalEnabled ?? this.isAutoGoalEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      weightKg: weightKg ?? this.weightKg,
      gender: gender ?? this.gender,
      photoId: photoId ?? this.photoId,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      lastLogin: lastLogin ?? this.lastLogin,
      drinkPresets: drinkPresets ?? this.drinkPresets,
      reminderIntervalHours: identical(reminderIntervalHours, _unset)
          ? this.reminderIntervalHours
          : reminderIntervalHours as int?,
      reminderIntervalMinutes: identical(reminderIntervalMinutes, _unset)
          ? this.reminderIntervalMinutes
          : reminderIntervalMinutes as int?,
      quietHoursStart: identical(quietHoursStart, _unset)
          ? this.quietHoursStart
          : quietHoursStart as String?,
      quietHoursEnd: identical(quietHoursEnd, _unset)
          ? this.quietHoursEnd
          : quietHoursEnd as String?,
      lastCelebratedRankId: identical(lastCelebratedRankId, _unset)
          ? this.lastCelebratedRankId
          : lastCelebratedRankId as String?,
    );
  }

  factory UserModel.fromFirestore({
    required String id,
    required Map<String, dynamic> data,
  }) {
    final goalMl =
        (data['daily_goal_ml'] as int?) ?? (data['daily_water_limit'] as int?) ?? kDefaultDailyGoalMl;

    return UserModel(
      id: id,
      userName: (data['user_name'] as String?)?.trim().isNotEmpty == true ? data['user_name'] as String : 'User',
      email: (data['email'] as String?) ?? '',
      dailyGoalMl: goalMl,
      isAutoGoalEnabled: data['is_auto_goal_enabled'] as bool? ?? false,
      notificationsEnabled: data['notifications_enabled'] as bool? ?? true,
      firstName: (data['first_name'] as String?)?.trim().isNotEmpty == true ? (data['first_name'] as String).trim() : null,
      lastName: (data['last_name'] as String?)?.trim().isNotEmpty == true ? (data['last_name'] as String).trim() : null,
      weightKg: data['weight_kg'] as int?,
      gender: (data['gender'] as String?)?.trim().isNotEmpty == true ? (data['gender'] as String).trim() : null,
      photoId: data['photo_id'] as String?,
      photoUrl: data['photo_url'] as String?,
      fcmToken: data['fcm_token'] as String?,
      lastLogin: _readDateTime(data['last_login']),
      drinkPresets: _readDrinkPresets(data['drink_presets']),
      reminderIntervalHours: _readReminderHours(data['reminder_interval_hours']),
      reminderIntervalMinutes: _readReminderMinutes(data['reminder_interval_minutes']),
      quietHoursStart: _trimOrNull(data['quiet_hours_start'] as String?),
      quietHoursEnd: _trimOrNull(data['quiet_hours_end'] as String?),
      lastCelebratedRankId: _trimOrNull(
        data['last_celebrated_rank_id'] as String?,
      ),
    );
  }

  static int? _readReminderHours(Object? raw) {
    if (raw == null) return null;
    final n = raw is int ? raw : (raw is num ? raw.round() : null);
    if (n == null || n <= 0) return null;
    return n;
  }

  static int? _readReminderMinutes(Object? raw) {
    if (raw == null) return null;
    final n = raw is int ? raw : (raw is num ? raw.round() : null);
    if (n == null || n <= 0) return null;
    return n;
  }

  static List<int> _readDrinkPresets(Object? raw) {
    if (raw is List) {
      final out = <int>[];
      for (final e in raw) {
        if (e is int) {
          out.add(e);
        } else if (e is num) {
          out.add(e.round());
        }
      }
      if (out.isNotEmpty) return out;
    }
    return kDefaultDrinkPresetsMl;
  }

  static String? _trimOrNull(String? s) {
    final t = (s ?? '').trim();
    return t.isEmpty ? null : t;
  }

  static DateTime? _readDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    return null;
  }
}
