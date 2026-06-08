import 'package:daily_water_tracker/features/account/models/account_logout_ui_freeze.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';

export 'package:daily_water_tracker/features/account/models/account_logout_ui_freeze.dart';

enum AccountFeedback { none, success, error }

enum AccountSessionAction { none, logout, deleteAccount }

enum AccountSessionPhase { idle, inProgress, succeeded, failed }

class AccountState extends Equatable {
  const AccountState({
    this.isNotificationsEnabled = false,
    this.isNotificationPermissionBusy = true,
    this.isPhotoBusy = false,
    this.feedback = AccountFeedback.none,
    this.feedbackMessageKey,
    this.sessionAction = AccountSessionAction.none,
    this.sessionPhase = AccountSessionPhase.idle,
    this.logoutUiFreeze,
    this.sessionErrorMessageKey,
    this.sessionErrorMessage,
  });

  final bool isNotificationsEnabled;
  final bool isNotificationPermissionBusy;
  final bool isPhotoBusy;
  final AccountFeedback feedback;
  final String? feedbackMessageKey;
  final AccountSessionAction sessionAction;
  final AccountSessionPhase sessionPhase;
  final AccountLogoutUiFreeze? logoutUiFreeze;
  final String? sessionErrorMessageKey;
  final String? sessionErrorMessage;

  bool get hasFeedback =>
      feedback != AccountFeedback.none && feedbackMessageKey != null;

  bool get isSessionActionInProgress =>
      sessionPhase == AccountSessionPhase.inProgress;

  bool get isLogoutInProgress =>
      sessionAction == AccountSessionAction.logout && isSessionActionInProgress;

  bool get isDeleteAccountInProgress =>
      sessionAction == AccountSessionAction.deleteAccount &&
      isSessionActionInProgress;

  bool get sessionSucceeded => sessionPhase == AccountSessionPhase.succeeded;

  bool get sessionFailed => sessionPhase == AccountSessionPhase.failed;

  String localizedFeedbackMessage() => feedbackMessageKey!.tr();

  String sessionErrorText() {
    final raw = sessionErrorMessage?.trim();
    if (raw != null && raw.isNotEmpty) return raw;
    if (sessionErrorMessageKey != null) return sessionErrorMessageKey!.tr();
    return '';
  }

  AccountState copyWith({
    bool? isNotificationsEnabled,
    bool? isNotificationPermissionBusy,
    bool? isPhotoBusy,
    AccountFeedback? feedback,
    String? feedbackMessageKey,
    bool clearFeedback = false,
    AccountSessionAction? sessionAction,
    AccountSessionPhase? sessionPhase,
    AccountLogoutUiFreeze? logoutUiFreeze,
    String? sessionErrorMessageKey,
    String? sessionErrorMessage,
    bool clearSession = false,
    bool clearLogoutUiFreeze = false,
  }) {
    return AccountState(
      isNotificationsEnabled:
          isNotificationsEnabled ?? this.isNotificationsEnabled,
      isNotificationPermissionBusy:
          isNotificationPermissionBusy ?? this.isNotificationPermissionBusy,
      isPhotoBusy: isPhotoBusy ?? this.isPhotoBusy,
      feedback: clearFeedback ? AccountFeedback.none : (feedback ?? this.feedback),
      feedbackMessageKey:
          clearFeedback ? null : (feedbackMessageKey ?? this.feedbackMessageKey),
      sessionAction: clearSession
          ? AccountSessionAction.none
          : (sessionAction ?? this.sessionAction),
      sessionPhase: clearSession
          ? AccountSessionPhase.idle
          : (sessionPhase ?? this.sessionPhase),
      logoutUiFreeze: clearSession || clearLogoutUiFreeze
          ? null
          : (logoutUiFreeze ?? this.logoutUiFreeze),
      sessionErrorMessageKey: clearSession
          ? null
          : (sessionErrorMessageKey ?? this.sessionErrorMessageKey),
      sessionErrorMessage: clearSession
          ? null
          : (sessionErrorMessage ?? this.sessionErrorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isNotificationsEnabled,
    isNotificationPermissionBusy,
    isPhotoBusy,
    feedback,
    feedbackMessageKey,
    sessionAction,
    sessionPhase,
    logoutUiFreeze,
    sessionErrorMessageKey,
    sessionErrorMessage,
  ];
}
