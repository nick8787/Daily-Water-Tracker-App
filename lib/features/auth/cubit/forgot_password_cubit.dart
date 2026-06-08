import 'package:daily_water_tracker/common/utils/crashlytics.dart';
import 'package:daily_water_tracker/firebase/services/auth_service.dart';
import 'package:daily_water_tracker/generated/locale_keys.g.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  ForgotPasswordCubit({
    required AuthService authService,
  }) : _authService = authService,
       super(const ForgotPasswordInitial());

  final AuthService _authService;

  Future<void> sendResetLink({required String email}) async {
    final trimmedEmail = email.trim();
    emit(const ForgotPasswordLoading());

    try {
      await _authService.sendPasswordResetEmail(email: trimmedEmail);
      emit(ForgotPasswordSuccess(trimmedEmail));
    } on FirebaseAuthException catch (e, st) {
      if (e.code == 'user-not-found') {
        emit(ForgotPasswordSuccess(trimmedEmail));
        return;
      }

      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'ForgotPasswordCubit.sendResetLink: FirebaseAuthException',
      );
      emit(ForgotPasswordFailure(_mapAuthError(e)));
    } catch (e, st) {
      recordCrashlyticsError(
        e,
        st,
        st,
        reason: 'ForgotPasswordCubit.sendResetLink: unknown error',
      );
      emit(const ForgotPasswordFailure(LocaleKeys.auth_forgot_password_error_generic));
    }
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return LocaleKeys.auth_error_invalid_email;
      case 'too-many-requests':
        return LocaleKeys.auth_error_too_many_requests;
      case 'network-request-failed':
        return LocaleKeys.auth_error_network;
      default:
        return LocaleKeys.auth_forgot_password_error_generic;
    }
  }
}
