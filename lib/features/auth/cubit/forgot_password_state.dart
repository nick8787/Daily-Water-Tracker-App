import 'package:easy_localization/easy_localization.dart';

sealed class ForgotPasswordState {
  const ForgotPasswordState();
}

class ForgotPasswordInitial extends ForgotPasswordState {
  const ForgotPasswordInitial();
}

class ForgotPasswordLoading extends ForgotPasswordState {
  const ForgotPasswordLoading();
}

class ForgotPasswordSuccess extends ForgotPasswordState {
  const ForgotPasswordSuccess(this.email);

  final String email;
}

class ForgotPasswordFailure extends ForgotPasswordState {
  const ForgotPasswordFailure(
    this.messageKey, {
    this.namedArgs,
  });

  final String messageKey;
  final Map<String, String>? namedArgs;

  String localizedMessage() => messageKey.tr(namedArgs: namedArgs);
}
