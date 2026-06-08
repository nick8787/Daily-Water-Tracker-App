import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';

import 'complete_password_reset_state.dart';

class CompletePasswordResetCubit extends Cubit<CompletePasswordResetState> {
  CompletePasswordResetCubit({
    required AuthService authService,
  }) : _authService = authService,
       super(const CompletePasswordResetInitial());

  final AuthService _authService;

  Future<void> verifyCode(String oobCode) async {
    final code = oobCode.trim();
    if (code.isEmpty) {
      emit(
        const CompletePasswordResetInvalidCode(
          LocaleKeys.auth_complete_password_reset_error_invalid_link,
        ),
      );
      return;
    }

    emit(const CompletePasswordResetVerifying());

    try {
      final email = await _authService.verifyPasswordResetCode(code);
      emit(CompletePasswordResetReady(email: email, oobCode: code));
    } on FirebaseAuthException catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'CompletePasswordResetCubit.verifyCode: FirebaseAuthException',
      );
      emit(
        CompletePasswordResetInvalidCode(_mapVerifyError(e)),
      );
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'CompletePasswordResetCubit.verifyCode: unknown error',
      );
      emit(
        const CompletePasswordResetInvalidCode(
          LocaleKeys.auth_complete_password_reset_error_invalid_link,
        ),
      );
    }
  }

  Future<void> submit({
    required String email,
    required String oobCode,
    required String newPassword,
  }) async {
    emit(CompletePasswordResetSubmitting(email: email, oobCode: oobCode));

    try {
      await _authService.confirmPasswordReset(
        code: oobCode,
        newPassword: newPassword,
      );
      emit(const CompletePasswordResetSuccess());
    } on FirebaseAuthException catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'CompletePasswordResetCubit.submit: FirebaseAuthException',
      );
      emit(
        CompletePasswordResetFailure(
          email: email,
          oobCode: oobCode,
          messageKey: _mapSubmitError(e),
        ),
      );
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'CompletePasswordResetCubit.submit: unknown error',
      );
      emit(
        CompletePasswordResetFailure(
          email: email,
          oobCode: oobCode,
          messageKey: LocaleKeys.auth_complete_password_reset_error_generic,
        ),
      );
    }
  }

  String _mapVerifyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'expired-action-code':
        return LocaleKeys.auth_complete_password_reset_error_expired_link;
      case 'invalid-action-code':
        return LocaleKeys.auth_complete_password_reset_error_invalid_link;
      case 'user-disabled':
        return LocaleKeys.auth_error_account_disabled;
      case 'user-not-found':
        return LocaleKeys.auth_complete_password_reset_error_invalid_link;
      case 'network-request-failed':
        return LocaleKeys.auth_error_network;
      default:
        return LocaleKeys.auth_complete_password_reset_error_invalid_link;
    }
  }

  String _mapSubmitError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return LocaleKeys.auth_error_weak_password;
      case 'expired-action-code':
        return LocaleKeys.auth_complete_password_reset_error_expired_link;
      case 'invalid-action-code':
        return LocaleKeys.auth_complete_password_reset_error_invalid_link;
      case 'too-many-requests':
        return LocaleKeys.auth_error_too_many_requests;
      case 'network-request-failed':
        return LocaleKeys.auth_error_network;
      default:
        return LocaleKeys.auth_complete_password_reset_error_generic;
    }
  }
}
