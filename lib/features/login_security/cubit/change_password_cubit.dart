import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  ChangePasswordCubit({
    required AuthService authService,
  }) : _authService = authService,
       super(const ChangePasswordInitial());

  final AuthService _authService;

  Future<void> submit({
    required String currentPassword,
    required String newPassword,
  }) async {
    emit(const ChangePasswordLoading());

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      emit(const ChangePasswordSuccess());
    } on FirebaseAuthException catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'ChangePasswordCubit.submit: FirebaseAuthException',
      );
      emit(ChangePasswordFailure(_mapAuthError(e)));
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'ChangePasswordCubit.submit: unknown error',
      );
      emit(const ChangePasswordFailure(LocaleKeys.login_security_error_generic));
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'no-current-user':
        return LocaleKeys.login_security_error_not_signed_in;
      case 'wrong-password':
      case 'invalid-credential':
        return LocaleKeys.login_security_error_wrong_password;
      case 'weak-password':
        return LocaleKeys.auth_error_weak_password;
      case 'requires-recent-login':
        return LocaleKeys.login_security_error_recent_login;
      case 'too-many-requests':
        return LocaleKeys.auth_error_too_many_requests;
      case 'network-request-failed':
        return LocaleKeys.auth_error_network;
      default:
        return LocaleKeys.login_security_error_generic;
    }
  }
}
