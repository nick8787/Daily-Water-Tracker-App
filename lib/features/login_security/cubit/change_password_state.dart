import 'package:easy_localization/easy_localization.dart';

sealed class ChangePasswordState {
  const ChangePasswordState();
}

class ChangePasswordInitial extends ChangePasswordState {
  const ChangePasswordInitial();
}

class ChangePasswordLoading extends ChangePasswordState {
  const ChangePasswordLoading();
}

class ChangePasswordSuccess extends ChangePasswordState {
  const ChangePasswordSuccess();
}

class ChangePasswordFailure extends ChangePasswordState {
  const ChangePasswordFailure(
    this.messageKey, {
    this.namedArgs,
  });

  final String messageKey;
  final Map<String, String>? namedArgs;

  String localizedMessage() => messageKey.tr(namedArgs: namedArgs);
}
