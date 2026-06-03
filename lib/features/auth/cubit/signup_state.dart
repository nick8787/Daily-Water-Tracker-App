import 'package:easy_localization/easy_localization.dart';

sealed class SignUpState {
  const SignUpState();
}

class SignUpInitial extends SignUpState {
  const SignUpInitial();
}

class SignUpLoading extends SignUpState {
  const SignUpLoading();
}

class SignUpSuccess extends SignUpState {
  const SignUpSuccess();
}

class SignUpFailure extends SignUpState {
  const SignUpFailure(
    this.messageKey, {
    this.namedArgs,
  });

  final String messageKey;
  final Map<String, String>? namedArgs;

  String localizedMessage() => messageKey.tr(namedArgs: namedArgs);
}
