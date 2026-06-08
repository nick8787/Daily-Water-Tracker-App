import 'dart:async';
import 'dart:convert';

import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/features/remote_config/models/issue_disclaimer.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

enum ProgressIndicatorType {
  circular,
  linear;

  static ProgressIndicatorType fromWire(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'linear':
        return ProgressIndicatorType.linear;
      case 'circular':
      default:
        return ProgressIndicatorType.circular;
    }
  }
}

class RemoteConfigService {
  RemoteConfigService({
    required FirebaseRemoteConfig remoteConfig,
  }) : _remoteConfig = remoteConfig;

  static const String progressIndicatorTypeKey = 'progress_indicator_type';
  static const String issueDisclaimersKey = 'issue_disclaimers';
  static const ProgressIndicatorType fallbackProgressIndicatorType =
      ProgressIndicatorType.circular;

  final FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;

  final StreamController<ProgressIndicatorType> _progressTypeController =
      StreamController<ProgressIndicatorType>.broadcast();
  final StreamController<List<IssueDisclaimer>> _issueDisclaimersController =
      StreamController<List<IssueDisclaimer>>.broadcast();

  Stream<ProgressIndicatorType> get progressIndicatorTypeStream =>
      _progressTypeController.stream;
  Stream<List<IssueDisclaimer>> get issueDisclaimersStream =>
      _issueDisclaimersController.stream;

  ProgressIndicatorType get progressIndicatorType {
    return ProgressIndicatorType.fromWire(
      _remoteConfig.getString(progressIndicatorTypeKey),
    );
  }

  List<IssueDisclaimer> get issueDisclaimers {
    final raw = _remoteConfig.getString(issueDisclaimersKey);
    if (raw.trim().isEmpty) return const <IssueDisclaimer>[];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const <IssueDisclaimer>[];
      final result = <IssueDisclaimer>[];
      for (final item in decoded) {
        if (item is Map) {
          result.add(IssueDisclaimer.fromJson(Map<String, dynamic>.from(item)));
        }
      }
      return result.where((d) => d.isActive).toList(growable: false);
    } catch (e, st) {
      unawaited(
        recordCrashlyticsError(
          e,
          st,
          st,
          reason: 'RemoteConfigService: invalid JSON for $issueDisclaimersKey',
        ),
      );
      return const <IssueDisclaimer>[];
    }
  }

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        // For training/dev UX we want RC changes to take effect immediately after publish.
        // If you later need stricter caching for prod, raise this value.
        minimumFetchInterval: Duration.zero,
      ),
    );

    // Application-side fallback when offline / fetch fails.
    await _remoteConfig.setDefaults(<String, Object>{
      progressIndicatorTypeKey: fallbackProgressIndicatorType.name,
      issueDisclaimersKey: '[]',
    });

    // Load cached activated values (if any), then emit immediately.
    await _remoteConfig.ensureInitialized();
    _progressTypeController.add(progressIndicatorType);
    _issueDisclaimersController.add(issueDisclaimers);

    // Best-effort fetch; failures should not break app startup.
    await refresh();

    _remoteConfig.onConfigUpdated.listen((_) async {
      try {
        await _remoteConfig.activate();
      } finally {
        _progressTypeController.add(progressIndicatorType);
        _issueDisclaimersController.add(issueDisclaimers);
      }
    });
  }

  Future<void> refresh() async {
    try {
      await _remoteConfig.fetchAndActivate();
    } catch (e, st) {
      // Keep defaults/cached values; record for visibility.
      unawaited(
        recordCrashlyticsError(
          e,
          st,
          st,
          reason: 'RemoteConfigService: fetchAndActivate failed',
        ),
      );
    } finally {
      _progressTypeController.add(progressIndicatorType);
      _issueDisclaimersController.add(issueDisclaimers);
    }
  }

  @visibleForTesting
  Future<void> dispose() async {
    await _progressTypeController.close();
    await _issueDisclaimersController.close();
  }
}

