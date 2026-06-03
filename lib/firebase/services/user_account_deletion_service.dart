import 'package:firebase_auth/firebase_auth.dart';
import 'package:daily_water_tracker/common/services/logger.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/data/repositories/messaging_repository.dart';
import 'package:daily_water_tracker/firebase/services/reminder_scheduler_service.dart';
import 'package:daily_water_tracker/data/repositories/storage_repository.dart';

/// Permanently removes the signed-in user's cloud data and Firebase Auth account.
class UserAccountDeletionService {
  UserAccountDeletionService({
    required AuthService authService,
    required FirestoreRepository firestoreRepository,
    required StorageRepository storageRepository,
    required MessagingRepository messagingRepository,
    required ReminderSchedulerService reminderScheduler,
  }) : _authService = authService,
       _firestoreRepository = firestoreRepository,
       _storageRepository = storageRepository,
       _messagingRepository = messagingRepository,
       _reminderScheduler = reminderScheduler;

  final AuthService _authService;
  final FirestoreRepository _firestoreRepository;
  final StorageRepository _storageRepository;
  final MessagingRepository _messagingRepository;
  final ReminderSchedulerService _reminderScheduler;

  Future<void> deleteCurrentUserAccount() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw const UserAccountDeletionException(
        'You are not signed in.',
        code: UserAccountDeletionException.notSignedIn,
      );
    }

    final uid = user.uid;

    await _reminderScheduler.cancelAllReminders();
    await _messagingRepository.teardownPushForSignedOutUser();

    await _firestoreRepository.deleteUserAccountData(uid: uid);
    await _storageRepository.deleteUserStorage(uid: uid);

    try {
      await _authService.deleteCurrentUser();
    } on FirebaseAuthException catch (e, st) {
      if (e.code == 'requires-recent-login') {
        logCaughtWarning('UserAccountDeletionService: requires-recent-login', e, st);
        throw const UserAccountDeletionException(
          'For security, sign in again and retry deleting your account.',
          code: UserAccountDeletionException.requiresRecentLogin,
        );
      }
      logCaughtError('UserAccountDeletionService.deleteAccount', e, st);
      rethrow;
    }

    await _authService.signOut();
  }
}

class UserAccountDeletionException implements Exception {
  const UserAccountDeletionException(this.message, {this.code});

  final String message;
  final String? code;

  static const notSignedIn = 'not-signed-in';
  static const requiresRecentLogin = 'requires-recent-login';

  @override
  String toString() => message;
}
