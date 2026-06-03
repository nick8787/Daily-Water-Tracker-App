import 'package:easy_localization/easy_localization.dart';

sealed class LoginState {
  const LoginState();
}

class LoginInitial extends LoginState {
  const LoginInitial();
}

class LoginLoading extends LoginState {
  const LoginLoading();
}

class LoginSuccess extends LoginState {
  const LoginSuccess();
}

class LoginFailure extends LoginState {
  const LoginFailure(
    this.messageKey, {
    this.namedArgs,
  });

  /// [LocaleKeys] path, e.g. [LocaleKeys.auth_error_invalid_credentials].
  final String messageKey;
  final Map<String, String>? namedArgs;

  String localizedMessage() => messageKey.tr(namedArgs: namedArgs);
}
