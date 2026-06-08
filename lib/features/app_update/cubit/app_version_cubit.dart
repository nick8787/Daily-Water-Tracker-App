import 'dart:io';

import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/features/app_update/mixin/app_version_mixin.dart';
import 'package:daily_water_tracker/features/app_update/models/app_version.dart';
import 'package:daily_water_tracker/features/app_update/models/app_version_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:pub_semver/pub_semver.dart';

class AppVersionCubit extends Cubit<AppVersionStatus> with AppVersionMixin {
  final Version currentAppVersion;
  AppVersionCubit({required this.currentAppVersion})
    : super(AppVersionStatus.none);

  Future<void> initializeAndCheckVersion() async {
    try {
      emit(AppVersionStatus.loading);

      if (kIsWeb) {
        emit(AppVersionStatus.loaded);
        return;
      }

      /// TODO: get this version from back-end.
      final appVersions = AppVersions(
        minIosVersion: Version.parse('0.0.1'),
        minAndroidVersion: Version.parse('0.0.1'),
      );

      final isMinVersionInstalled = checkIsMinVersionInstalled(
        appVersions: appVersions,
        currentAppVersion: currentAppVersion,
      );

      emit(
        isMinVersionInstalled
            ? AppVersionStatus.loaded
            : AppVersionStatus.updateRequired,
      );
    } catch (e, st) {
      logCaughtError('AppVersionCubit.initializeAndCheckVersion', e, st);
      emit(AppVersionStatus.error);
    }
  }

  Future<void> updateApp() async {
    if (Platform.isAndroid) {
      await InAppUpdate.checkForUpdate();
      await InAppUpdate.performImmediateUpdate();
    }
    if (Platform.isIOS) {
      final storeId = getStoreId();
      await launchToInstallApp(storeId: storeId);
    }
  }
}
