import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/firebase/models/user_model.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'signup_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthService _authService;
  final FirestoreRepository _firestoreRepository;
  static const Duration _postSignUpSyncTimeout = Duration(seconds: 3);

  SignUpCubit({
    required AuthService authService,
    required FirestoreRepository firestoreRepository,
  }) : _authService = authService,
       _firestoreRepository = firestoreRepository,
       super(const SignUpInitial());

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    emit(const SignUpLoading());

    try {
      await _authService.signUpWithEmailPassword(
        email: email,
        password: password,
      );
      await _saveDefaultProfile().timeout(
        _postSignUpSyncTimeout,
        onTimeout: () => null,
      );
      emit(const SignUpSuccess());
    } on FirebaseAuthException catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signUp: FirebaseAuthException',
      );
      emit(SignUpFailure(_mapAuthError(e)));
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signUp: unknown error',
      );
      emit(const SignUpFailure(LocaleKeys.auth_error_generic));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const SignUpLoading());
    try {
      await _authService.signInWithGoogle();
      await _saveDefaultProfile().timeout(
        _postSignUpSyncTimeout,
        onTimeout: () => null,
      );
      emit(const SignUpSuccess());
    } on FirebaseAuthException catch (e, st) {
if (e.code == 'sign-in-cancelled') {
        emit(const SignUpInitial());
        return;
      }
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signInWithGoogle: FirebaseAuthException',
      );
      emit(SignUpFailure(_mapAuthError(e)));
    } on PlatformException catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signInWithGoogle: PlatformException',
      );
      emit(
        SignUpFailure(
          LocaleKeys.auth_error_google_failed,
          namedArgs: {'error': e.message ?? e.code},
        ),
      );
    } catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signInWithGoogle: unknown error',
      );
      emit(
        SignUpFailure(
          LocaleKeys.auth_error_google_failed,
          namedArgs: {'error': '$e'},
        ),
      );
    }
  }

  Future<void> signInWithFacebook() async {
    emit(const SignUpLoading());
    try {
      await _authService.signInWithFacebook();
      await _saveDefaultProfile().timeout(
        _postSignUpSyncTimeout,
        onTimeout: () => null,
      );
      emit(const SignUpSuccess());
    } on FirebaseAuthException catch (e, st) {
if (e.code == 'sign-in-cancelled') {
        emit(const SignUpInitial());
        return;
      }
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signInWithFacebook: FirebaseAuthException',
      );
      emit(SignUpFailure(_mapAuthError(e)));
    } on PlatformException catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signInWithFacebook: PlatformException',
      );
      emit(
        SignUpFailure(
          LocaleKeys.auth_error_facebook_failed_dynamic,
          namedArgs: {'error': e.message ?? e.code},
        ),
      );
    } catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signInWithFacebook: unknown error',
      );
      emit(
        SignUpFailure(
          LocaleKeys.auth_error_facebook_failed_dynamic,
          namedArgs: {'error': '$e'},
        ),
      );
    }
  }

  Future<void> signInWithApple() async {
    emit(const SignUpLoading());
    try {
      await _authService.signInWithApple();
      await _saveDefaultProfile().timeout(
        _postSignUpSyncTimeout,
        onTimeout: () => null,
      );
      emit(const SignUpSuccess());
    } on FirebaseAuthException catch (e, st) {
if (e.code == 'sign-in-cancelled') {
        emit(const SignUpInitial());
        return;
      }
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signInWithApple: FirebaseAuthException',
      );
      emit(SignUpFailure(_mapAuthError(e)));
    } on PlatformException catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signInWithApple: PlatformException',
      );
      emit(
        SignUpFailure(
          LocaleKeys.auth_error_apple_failed_dynamic,
          namedArgs: {'error': e.message ?? e.code},
        ),
      );
    } catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'SignUpCubit.signInWithApple: unknown error',
      );
      emit(
        SignUpFailure(
          LocaleKeys.auth_error_apple_failed_dynamic,
          namedArgs: {'error': '$e'},
        ),
      );
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'sign-in-cancelled':
        return LocaleKeys.auth_error_sign_in_cancelled;
      case 'invalid-email':
        return LocaleKeys.auth_error_invalid_email;
      case 'email-already-in-use':
        return LocaleKeys.auth_error_email_in_use;
      case 'weak-password':
        return LocaleKeys.auth_error_weak_password;
      case 'operation-not-allowed':
        return LocaleKeys.auth_error_signup_not_allowed;
      case 'network-request-failed':
        return LocaleKeys.auth_error_network;
      case 'too-many-requests':
        return LocaleKeys.auth_error_too_many_requests;
      case 'missing-google-id-token':
        return LocaleKeys.auth_error_google_misconfigured;
      case 'facebook-login-failed':
        return LocaleKeys.auth_error_facebook_failed;
      case 'missing-apple-identity-token':
        return LocaleKeys.auth_error_apple_misconfigured;
      case 'apple-sign-in-not-supported':
        return LocaleKeys.auth_error_apple_ios_only;
      default:
        return LocaleKeys.auth_error_signup_failed;
    }
  }

  Future<void> _saveDefaultProfile() async {
    final authUser = _authService.currentUser;
    if (authUser == null) return;

    final email = (authUser.email ?? '').trim();
    final fallbackName = _nameFromEmail(email);
    final photoUrl = (authUser.photoURL ?? '').trim().isNotEmpty
        ? authUser.photoURL!.trim()
        : null;

    final profile = UserModel(
      id: authUser.uid,
      userName: (authUser.displayName ?? '').trim().isNotEmpty
          ? authUser.displayName!.trim()
          : fallbackName,
      email: email,
      photoUrl: photoUrl,
      dailyGoalMl: 3000,
    );

    await _firestoreRepository.saveUserProfile(profile);
  }

  String _nameFromEmail(String email) {
    if (email.isEmpty) return 'User';
    final at = email.indexOf('@');
    if (at <= 0) return email;
    return email.substring(0, at);
  }
}
