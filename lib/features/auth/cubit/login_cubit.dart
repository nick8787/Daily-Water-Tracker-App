import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/data/repositories/firestore_repository.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit({
    required AuthService authService,
    required FirestoreRepository firestoreRepository,
  }) : _authService = authService,
       _firestoreRepository = firestoreRepository,
       super(const LoginInitial());

  final AuthService _authService;
  final FirestoreRepository _firestoreRepository;
  static const Duration _postLoginSyncTimeout = Duration(seconds: 3);

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const LoginLoading());

    try {
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
      await _firestoreRepository.syncUserRootFromAuth().timeout(
        _postLoginSyncTimeout,
        onTimeout: () => null,
      );
      emit(const LoginSuccess());
    } on FirebaseAuthException catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signIn: FirebaseAuthException',
      );
      emit(LoginFailure(_mapAuthError(e)));
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signIn: unknown error',
      );
      emit(const LoginFailure(LocaleKeys.auth_error_generic));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(const LoginLoading());
    try {
      await _authService.signInWithGoogle();
      await _firestoreRepository.syncUserRootFromAuth().timeout(
        _postLoginSyncTimeout,
        onTimeout: () => null,
      );
      emit(const LoginSuccess());
    } on FirebaseAuthException catch (e, st) {
if (e.code == 'sign-in-cancelled') {
        emit(const LoginInitial());
        return;
      }
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signInWithGoogle: FirebaseAuthException',
      );
      emit(LoginFailure(_mapAuthError(e)));
    } on PlatformException catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signInWithGoogle: PlatformException',
      );
      emit(LoginFailure(_mapPlatformError(e)));
    } catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signInWithGoogle: unknown error',
      );
      emit(
        LoginFailure(
          LocaleKeys.auth_error_google_failed,
          namedArgs: {'error': '$e'},
        ),
      );
    }
  }

  Future<void> signInWithFacebook() async {
    emit(const LoginLoading());
    try {
      await _authService.signInWithFacebook();
      await _firestoreRepository.syncUserRootFromAuth().timeout(
        _postLoginSyncTimeout,
        onTimeout: () => null,
      );
      emit(const LoginSuccess());
    } on FirebaseAuthException catch (e, st) {
if (e.code == 'sign-in-cancelled') {
        emit(const LoginInitial());
        return;
      }
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signInWithFacebook: FirebaseAuthException',
      );
      emit(LoginFailure(_mapAuthError(e)));
    } on PlatformException catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signInWithFacebook: PlatformException',
      );
      emit(
        LoginFailure(
          LocaleKeys.auth_error_facebook_failed_dynamic,
          namedArgs: {'error': e.message ?? e.code},
        ),
      );
    } catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signInWithFacebook: unknown error',
      );
      emit(LoginFailure('Facebook sign-in failed: $e'));
    }
  }

  Future<void> signInWithApple() async {
    emit(const LoginLoading());
    try {
      await _authService.signInWithApple();
      await _firestoreRepository.syncUserRootFromAuth().timeout(
        _postLoginSyncTimeout,
        onTimeout: () => null,
      );
      emit(const LoginSuccess());
    } on FirebaseAuthException catch (e, st) {
if (e.code == 'sign-in-cancelled') {
        emit(const LoginInitial());
        return;
      }
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signInWithApple: FirebaseAuthException',
      );
      emit(LoginFailure(_mapAuthError(e)));
    } on PlatformException catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signInWithApple: PlatformException',
      );
      emit(
        LoginFailure(
          LocaleKeys.auth_error_apple_failed_dynamic,
          namedArgs: {'error': e.message ?? e.code},
        ),
      );
    } catch (e, st) {
recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'LoginCubit.signInWithApple: unknown error',
      );
      emit(
        LoginFailure(
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
      case 'invalid-credential':
      case 'user-not-found':
      case 'wrong-password':
        return LocaleKeys.auth_error_invalid_credentials;
      case 'user-disabled':
        return LocaleKeys.auth_error_account_disabled;
      case 'too-many-requests':
        return LocaleKeys.auth_error_too_many_requests;
      case 'network-request-failed':
        return LocaleKeys.auth_error_network;
      case 'account-exists-with-different-credential':
        return LocaleKeys.auth_error_credential_conflict;
      case 'missing-google-id-token':
        return LocaleKeys.auth_error_google_misconfigured;
      case 'facebook-login-failed':
        return LocaleKeys.auth_error_facebook_failed;
      case 'missing-apple-identity-token':
        return LocaleKeys.auth_error_apple_misconfigured;
      case 'apple-sign-in-not-supported':
        return LocaleKeys.auth_error_apple_ios_only;
      default:
        return LocaleKeys.auth_error_auth_failed;
    }
  }

  String _mapPlatformError(PlatformException e) {
    final message = e.message ?? e.code;

    if (message.contains('ApiException: 10') || message.contains('10:')) {
      return LocaleKeys.auth_error_google_api_10;
    }

    if (message.toLowerCase().contains('sign_in_failed')) {
      return LocaleKeys.auth_error_google_emulator;
    }

    return LocaleKeys.auth_error_google_failed;
  }
}
