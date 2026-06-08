import 'dart:async';
import 'dart:io';

import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/data/repositories/storage_repository.dart';
import 'package:daily_water_tracker/features/account/widgets/account_user_display.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/firebase/services/local_notifications_service.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:daily_water_tracker/firebase/services/user_account_deletion_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'account_state.dart';

class AccountCubit extends Cubit<AccountState> {
  AccountCubit({
    required AuthService authService,
    required FirestoreRepository firestoreRepository,
    required StorageRepository storageRepository,
    required ReminderSchedulerService reminderScheduler,
    required MessagingRepository messagingRepository,
    required LocalNotificationsService localNotifications,
    required UserAccountDeletionService accountDeletionService,
    ImagePicker? imagePicker,
  }) : _authService = authService,
       _firestoreRepository = firestoreRepository,
       _storageRepository = storageRepository,
       _reminderScheduler = reminderScheduler,
       _messagingRepository = messagingRepository,
       _localNotifications = localNotifications,
       _accountDeletionService = accountDeletionService,
       _imagePicker = imagePicker ?? ImagePicker(),
       super(const AccountState()) {
    _profileSub = _firestoreRepository.watchUserProfile().listen(
      _onProfile,
      onError: (_) {},
    );
    unawaited(_recomputeNotifications(null));
  }

  final AuthService _authService;
  final FirestoreRepository _firestoreRepository;
  final StorageRepository _storageRepository;
  final ReminderSchedulerService _reminderScheduler;
  final MessagingRepository _messagingRepository;
  final LocalNotificationsService _localNotifications;
  final UserAccountDeletionService _accountDeletionService;
  final ImagePicker _imagePicker;

  StreamSubscription<UserModel?>? _profileSub;

  static const Duration _logoutMinDisplay = Duration(seconds: 1);
  static const Duration _deleteMinDisplay = Duration(seconds: 1);
  static const Duration _logoutProfileTimeout = Duration(milliseconds: 450);

  void clearFeedback() {
    if (state.feedback == AccountFeedback.none) return;
    emit(state.copyWith(clearFeedback: true));
  }

  void clearSession() {
    if (state.sessionAction == AccountSessionAction.none &&
        state.sessionPhase == AccountSessionPhase.idle) {
      return;
    }
    emit(state.copyWith(clearSession: true));
  }

  Future<void> logOut() async {
    if (state.isSessionActionInProgress) return;

    final user = _authService.currentUser;
    if (user == null) return;

    UserModel? profile;
    try {
      profile = await _firestoreRepository.getUserProfile().timeout(
        _logoutProfileTimeout,
        onTimeout: () => null,
      );
    } catch (e, st) {
      logCaughtWarning('AccountCubit.logOut: profile load', e, st);
      profile = null;
    }

    final email = (profile?.email ?? user.email ?? '').trim();
    final displayName = (profile?.userName ?? accountDisplayNameFromUser(user))
        .trim();
    final avatarUrl = ((profile?.photoUrl ?? user.photoURL) ?? '').trim();
    final hasCustomPhoto = (profile?.photoId ?? '').trim().isNotEmpty;
    final photoUrl = avatarUrl.isEmpty ? null : avatarUrl;

    emit(
      state.copyWith(
        sessionAction: AccountSessionAction.logout,
        sessionPhase: AccountSessionPhase.inProgress,
        logoutUiFreeze: AccountLogoutUiFreeze(
          displayName: displayName,
          email: email,
          photoUrl: photoUrl,
          hasCustomPhoto: hasCustomPhoto,
        ),
        clearFeedback: true,
      ),
    );

    try {
      await Future.wait<void>([
        _authService.signOut(),
        Future<void>.delayed(_logoutMinDisplay),
      ]);
      emit(
        state.copyWith(
          sessionPhase: AccountSessionPhase.succeeded,
        ),
      );
    } catch (e, st) {
      await recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'account sign out',
      );
      emit(
        state.copyWith(
          sessionPhase: AccountSessionPhase.failed,
          sessionErrorMessageKey: LocaleKeys.account_snackbar_sign_out_failed,
          clearLogoutUiFreeze: true,
        ),
      );
    }
  }

  Future<void> deleteAccount() async {
    if (state.isSessionActionInProgress) return;

    emit(
      state.copyWith(
        sessionAction: AccountSessionAction.deleteAccount,
        sessionPhase: AccountSessionPhase.inProgress,
        clearFeedback: true,
        clearLogoutUiFreeze: true,
      ),
    );

    try {
      await Future.wait<void>([
        _accountDeletionService.deleteCurrentUserAccount(),
        Future<void>.delayed(_deleteMinDisplay),
      ]);
      emit(
        state.copyWith(
          sessionPhase: AccountSessionPhase.succeeded,
        ),
      );
    } on UserAccountDeletionException catch (e, st) {
      logCaughtWarning('AccountCubit.deleteAccount', e, st);
      emit(
        state.copyWith(
          sessionPhase: AccountSessionPhase.failed,
          sessionErrorMessage: e.message,
        ),
      );
    } catch (e, st) {
      await recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'account deletion',
      );
      emit(
        state.copyWith(
          sessionPhase: AccountSessionPhase.failed,
          sessionErrorMessageKey: LocaleKeys.account_snackbar_delete_failed,
        ),
      );
    }
  }

  void _onProfile(UserModel? profile) {
    unawaited(_recomputeNotifications(profile));
  }

  Future<void> _recomputeNotifications(UserModel? profile) async {
    final p = profile ?? await _firestoreRepository.getUserProfile();
    final os = await _localNotifications.areOsNotificationsEnabled();
    final pref = p?.notificationsEnabled ?? true;
    final effective = pref && os;
    emit(
      state.copyWith(
        isNotificationsEnabled: effective,
        isNotificationPermissionBusy: false,
      ),
    );
    unawaited(_messagingRepository.syncReminderTopicWithPreferences());
  }

  Future<void> refreshOsNotificationSync() async {
    emit(state.copyWith(isNotificationPermissionBusy: true));
    await _recomputeNotifications(null);
  }

  Future<bool> setAppNotificationsEnabled(bool enable) async {
    emit(state.copyWith(isNotificationPermissionBusy: true));

    try {
      if (!enable) {
        await _firestoreRepository.updateUserProfile(notificationsEnabled: false);
        await _reminderScheduler.cancelAllReminders();
        await _recomputeNotifications(null);
        return false;
      }

      var osGranted = await _localNotifications.areOsNotificationsEnabled();
      if (!osGranted) {
        osGranted = await _localNotifications.requestOsNotificationPermissions();
      }
      if (!osGranted && !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        final settings = await _messagingRepository.requestPermission();
        osGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
        if (osGranted) {
          osGranted = await _localNotifications.areOsNotificationsEnabled();
        }
      }

      if (osGranted) {
        await _firestoreRepository.updateUserProfile(notificationsEnabled: true);
        await _messagingRepository.syncTokenNow();
        await _reminderScheduler.rescheduleReminders();
        await _messagingRepository.syncReminderTopicWithPreferences();
        await _recomputeNotifications(null);
        return false;
      }

      await _recomputeNotifications(null);
      return true;
    } catch (e, st) {
      await recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'setAppNotificationsEnabled',
      );
      await _recomputeNotifications(null);
      return true;
    }
  }

  Future<void> pickAndUploadPhoto({required ImageSource source}) async {
    emit(state.copyWith(isPhotoBusy: true, clearFeedback: true));
    try {
      final user = _authService.currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            isPhotoBusy: false,
            feedback: AccountFeedback.error,
            feedbackMessageKey: LocaleKeys.account_error_not_authenticated,
          ),
        );
        return;
      }

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile == null) {
        emit(state.copyWith(isPhotoBusy: false));
        return;
      }

      final file = File(pickedFile.path);

      final upload = await _storageRepository.uploadProfilePhoto(
        uid: user.uid,
        file: file,
      );

      await _firestoreRepository.updateUserProfile(
        photoId: upload.objectPath,
        photoUrl: upload.downloadUrl,
      );

      emit(
        state.copyWith(
          isPhotoBusy: false,
          feedback: AccountFeedback.success,
          feedbackMessageKey: LocaleKeys.account_success_photo_updated,
        ),
      );
    } catch (e, st) {
      await recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'pickAndUploadPhoto',
      );
      emit(
        state.copyWith(
          isPhotoBusy: false,
          feedback: AccountFeedback.error,
          feedbackMessageKey: LocaleKeys.account_error_photo_upload,
        ),
      );
    }
  }

  Future<void> removePhoto() async {
    emit(state.copyWith(isPhotoBusy: true, clearFeedback: true));
    try {
      final user = _authService.currentUser;
      if (user == null) {
        emit(
          state.copyWith(
            isPhotoBusy: false,
            feedback: AccountFeedback.error,
            feedbackMessageKey: LocaleKeys.account_error_not_authenticated,
          ),
        );
        return;
      }

      const objectPathTemplate = 'users/{uid}/profile_{uid}.jpg';
      final objectPath = objectPathTemplate.replaceAll('{uid}', user.uid);
      await _storageRepository.removeProfilePhoto(objectPath: objectPath);

      await _firestoreRepository.updateUserProfile(
        clearPhotoId: true,
        clearPhotoUrl: true,
      );

      emit(
        state.copyWith(
          isPhotoBusy: false,
          feedback: AccountFeedback.success,
          feedbackMessageKey: LocaleKeys.account_success_photo_removed,
        ),
      );
    } catch (e, st) {
      await recordCrashlyticsError(
        e,
        StackTrace.current,
        st,
        reason: 'removePhoto',
      );
      emit(
        state.copyWith(
          isPhotoBusy: false,
          feedback: AccountFeedback.error,
          feedbackMessageKey: LocaleKeys.account_error_photo_remove,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _profileSub?.cancel();
    return super.close();
  }
}
